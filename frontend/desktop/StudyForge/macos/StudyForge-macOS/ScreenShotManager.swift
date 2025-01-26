//
//  ScreenShotManager.swift
//  StudyForge
//
//  Created by Demi Daniel on 1/25/25.
//
// Based on: https://stackoverflow.com/questions/39691106/programmatically-screenshot-swift-3-macos

import AVFoundation
import Foundation
import Cocoa

@objc(ScreenShotManager)
class ScreenShotManager: NSObject {
    @objc static func moduleName() -> String! {
        return "ScreenShotManager"
    }
    
    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc func takeScreenshots(_ folderPath: String,
                              resolver: @escaping RCTPromiseResolveBlock,
                              rejecter: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.captureScreenshots(folderPath, resolver: resolver, rejecter: rejecter)
        }
    }
    
    private func captureScreenshots(_ folderPath: String,
                                  resolver: @escaping RCTPromiseResolveBlock,
                                  rejecter: @escaping RCTPromiseRejectBlock) {
        // Create directory if it doesn't exist
        let folderURL = URL(fileURLWithPath: folderPath, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: folderURL,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
        } catch {
            rejecter("DIRECTORY_ERROR",
                    "Failed to create output directory: \(error.localizedDescription)",
                    error)
            return
        }

        // Request screen capture permission
        if !CGPreflightScreenCaptureAccess() {
            CGRequestScreenCaptureAccess()
            rejecter("PERMISSION_ERROR",
                    "Screen recording permission is required. Please grant permission in System Preferences and restart the app.",
                    nil)
            return
        }

        // Get active displays
        var displayCount: UInt32 = 0
        var result = CGGetActiveDisplayList(0, nil, &displayCount)
        guard result == .success else {
            rejecter("DISPLAY_ERROR",
                    "Failed to retrieve displays",
                    nil)
            return
        }

        let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: Int(displayCount))
        defer { activeDisplays.deallocate() }

        result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
        guard result == .success else {
            rejecter("DISPLAY_ERROR",
                    "Failed to get display list",
                    nil)
            return
        }

        // Take screenshots
        for index in 0..<Int(displayCount) {
            let displayID = activeDisplays[index]
            let timestamp = Int64(Date().timeIntervalSince1970)
            let fileURL = folderURL.appendingPathComponent("\(timestamp)_\(index).jpg")

            guard let screenshot = CGDisplayCreateImage(displayID) else {
                rejecter("CAPTURE_ERROR",
                        "Failed to capture display \(index)",
                        nil)
                return
            }

            let bitmapRep = NSBitmapImageRep(cgImage: screenshot)
            guard let jpegData = bitmapRep.representation(using: .jpeg,
                                                        properties: [.compressionFactor: 1.0]) else {
                rejecter("CONVERSION_ERROR",
                        "Failed to convert screenshot \(index)",
                        nil)
                return
            }

            do {
                try jpegData.write(to: fileURL, options: .atomic)
            } catch {
                rejecter("SAVE_ERROR",
                        "Failed to save screenshot \(index): \(error.localizedDescription)",
                        error)
                return
            }
        }

        resolver("Screenshots saved successfully at \(folderURL.path)")
    }
}

@objc(CameraManager)
class CameraManager: NSObject {
    private let captureSession = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private var promiseResolver: RCTPromiseResolveBlock?
    private var promiseRejecter: RCTPromiseRejectBlock?
    
    @objc func captureFrame(_ resolve: @escaping RCTPromiseResolveBlock,
                           reject: @escaping RCTPromiseRejectBlock) {
        self.promiseResolver = resolve
        self.promiseRejecter = reject
        
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                 for: .video,
                                                 position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            reject("camera_error", "Front camera not available", nil)
            return
        }
        
        captureSession.addInput(input)
        captureSession.addOutput(output)
        captureSession.startRunning()
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
    }
}
