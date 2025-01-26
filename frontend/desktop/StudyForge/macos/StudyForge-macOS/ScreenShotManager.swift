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
    @objc static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc(takeScreenshots:resolve:rejecter:)
    func takeScreenshots(_ folderPath: String,
                        resolve: @escaping RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock) {
        // Create directory if it doesn't exist
        let folderURL = URL(fileURLWithPath: folderPath, isDirectory: true)
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

        // Request screen capture permission
        if !CGPreflightScreenCaptureAccess() {
            CGRequestScreenCaptureAccess()
            reject("PERMISSION_ERROR",
                  "Screen recording permission is required. Please grant permission in System Preferences and restart the app.",
                  nil)
            return
        }

        // Get active displays
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
        
        // Take screenshots
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
                                                        properties: [.compressionFactor: 1.0]) else {
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

        resolve(["files": savedFiles])
    }
}
