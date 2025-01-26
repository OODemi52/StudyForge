//
//  CameraManager.swift
//  StudyForge-macOS
//
//  Created by Demi Daniel on 1/25/25.
//

import AVFoundation
import Foundation
import Cocoa

@objc(CameraManager)
class CameraManager: NSObject {
    private let captureSession = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private var promiseResolver: RCTPromiseResolveBlock?
    private var promiseRejecter: RCTPromiseRejectBlock?
    
    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc(captureFrame:rejecter:)
    func captureFrame(_ resolve: @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
        self.promiseResolver = resolve
        self.promiseRejecter = reject
        
        DispatchQueue.main.async {
            self.setupCamera()
        }
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                 for: .video,
                                                 position: .front) else {
            self.promiseRejecter?("CAMERA_ERROR", "Camera not available", nil)
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)
            captureSession.addOutput(output)
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
            captureSession.startRunning()
        } catch {
            self.promiseRejecter?("CAMERA_ERROR", "Failed to initialize camera", error)
        }
    }
    
    deinit {
        captureSession.stopRunning()
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                      didOutput sampleBuffer: CMSampleBuffer,
                      from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        guard let tiffData = nsImage.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmapRep.representation(using: .jpeg, properties: [:]) else {
            promiseRejecter?("image_error", "Failed to convert image", nil)
            return
        }
        
        let base64String = jpegData.base64EncodedString()
        promiseResolver?(["base64": base64String])
        captureSession.stopRunning()
        promiseResolver = nil
    }
}

