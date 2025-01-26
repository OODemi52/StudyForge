//
//  CameraManager.swift
//  StudyForge-macOS
//
//  Created by Demi Daniel on 1/25/25.
//

import AVFoundation
import Foundation
import Cocoa
import React

@objc(CameraManager)
class CameraManager: RCTEventEmitter {
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "camera.capture.queue")
    private var isCapturing = false
    private let backendURL = URL(string: "http://127.0.0.1:5000/detect")!
    
    override func supportedEvents() -> [String]? {
        return ["onDetectionResult"]
    }
    
    @objc(startCapture:rejecter:)
    func startCapture(_ resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                try self.configureCaptureSession()
                self.isCapturing = true
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    resolve(true)
                }
            } catch {
                DispatchQueue.main.async {
                    reject("CAMERA_ERROR", error.localizedDescription, error)
                }
            }
        }
    }
    
    @objc(stopCapture:rejecter:)
    func stopCapture(_ resolve: @escaping RCTPromiseResolveBlock,
                    rejecter reject: @escaping RCTPromiseRejectBlock) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.isCapturing = false
            self.captureSession.stopRunning()
            DispatchQueue.main.async {
                resolve(true)
            }
        }
    }
    
    private func configureCaptureSession() throws {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw NSError(domain: "CameraManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Camera not available"])
        }
        
        let input = try AVCaptureDeviceInput(device: camera)
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: sessionQueue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        captureSession.beginConfiguration()
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        captureSession.sessionPreset = .medium
        captureSession.commitConfiguration()
    }
    
    private func sendFrameToBackend(_ jpegData: Data) {
        let base64String = jpegData.base64EncodedString()
        
        var request = URLRequest(url: backendURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = ["image": base64String]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            
            self.sendEvent(withName: "onDetectionResult", body: result)
        }.resume()
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                      didOutput sampleBuffer: CMSampleBuffer,
                      from connection: AVCaptureConnection) {
        guard isCapturing,
              let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent),
              let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height)).tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: nsImage),
              let jpegData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.5]) else {
            return
        }
        
        sendFrameToBackend(jpegData)
    }
}
