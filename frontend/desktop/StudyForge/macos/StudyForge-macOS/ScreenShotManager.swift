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
    private static let maxRetryAttempts = 3
    private var retryCount = 0
    
    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc(takeScreenshots:resolve:rejecter:)
    func takeScreenshots(_ folderPath: String,
                        resolve: @escaping RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.handleScreenshotCapture(folderPath: folderPath, resolve: resolve, rejecter: reject)
        }
    }
    
    private func handleScreenshotCapture(folderPath: String,
                                       resolve: @escaping RCTPromiseResolveBlock,
                                       rejecter reject: @escaping RCTPromiseRejectBlock) {
        let folderURL = URL(fileURLWithPath: folderPath, isDirectory: true)
        
        // Create directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: folderURL,
                                                  withIntermediateDirectories: true,
                                                  attributes: nil)
        } catch {
            reject("DIRECTORY_ERROR",
                  "Failed to create output directory: \(error.localizedDescription)",
                  error)
            return
        }
        
        // Check screen capture permission
        if CGPreflightScreenCaptureAccess() {
            self.captureAndSaveScreenshots(folderURL: folderURL, resolve: resolve, rejecter: reject)
        } else {
            CGRequestScreenCaptureAccess()
            
            // Wait for permission dialog response
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if CGPreflightScreenCaptureAccess() {
                    self.captureAndSaveScreenshots(folderURL: folderURL, resolve: resolve, rejecter: reject)
                } else {
                    self.retryCount += 1
                    if self.retryCount <= ScreenShotManager.maxRetryAttempts {
                        self.handleScreenshotCapture(folderPath: folderPath, resolve: resolve, rejecter: reject)
                    } else {
                        self.retryCount = 0
                        reject("PERMISSION_ERROR",
                              "Screen recording permission required. Please enable in System Settings > Privacy & Security > Screen Recording.",
                              nil)
                    }
                }
            }
        }
    }
    
    private func captureAndSaveScreenshots(folderURL: URL,
                                         resolve: @escaping RCTPromiseResolveBlock,
                                         rejecter reject: @escaping RCTPromiseRejectBlock) {
        var displayCount: UInt32 = 0
        var result = CGGetActiveDisplayList(0, nil, &displayCount)
        guard result == .success else {
            reject("DISPLAY_ERROR",
                  "Failed to retrieve displays",
                  nil)
            return
        }
        
        let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: Int(displayCount))
        defer { activeDisplays.deallocate() }
        
        result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
        guard result == .success else {
            reject("DISPLAY_ERROR",
                  "Failed to get display list",
                  nil)
            return
        }
        
        var savedFiles: [String] = []
        
        for index in 0..<Int(displayCount) {
            let displayID = activeDisplays[index]
            let timestamp = Int64(Date().timeIntervalSince1970)
            let fileURL = folderURL.appendingPathComponent("\(timestamp)_\(index).jpg")
            
            guard let screenshot = CGDisplayCreateImage(displayID) else {
                reject("CAPTURE_ERROR",
                      "Failed to capture display \(index)",
                      nil)
                return
            }
            
            let bitmapRep = NSBitmapImageRep(cgImage: screenshot)
            guard let jpegData = bitmapRep.representation(using: .jpeg,
                                                        properties: [.compressionFactor: 0.9]) else {
                reject("CONVERSION_ERROR",
                      "Failed to convert screenshot \(index)",
                      nil)
                return
            }
            
            do {
                try jpegData.write(to: fileURL, options: .atomic)
                savedFiles.append(fileURL.path)
            } catch {
                reject("SAVE_ERROR",
                      "Failed to save screenshot \(index): \(error.localizedDescription)",
                      error)
                return
            }
        }
        
        self.retryCount = 0
        resolve(["files": savedFiles])
    }
}
