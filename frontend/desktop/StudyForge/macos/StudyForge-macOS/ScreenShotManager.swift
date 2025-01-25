//
//  ScreenShotManager.swift
//  StudyForge
//
//  Created by Demi Daniel on 1/25/25.
//
// Based on: https://stackoverflow.com/questions/39691106/programmatically-screenshot-swift-3-macos

import Foundation
import Cocoa

@objc(ScreenShotManager)
class ScreenShotManager: NSObject {
  @objc static func requiresMainQueueSetup() -> Bool { true }
    
    var folderPath: String
    
    @objc init(folderPath: String) {
        self.folderPath = folderPath
        super.init()
    }

  @objc func takeScreenshots(_ folderPath: String,
                               resolver: @escaping RCTPromiseResolveBlock,
                               rejecter: @escaping RCTPromiseRejectBlock) {
        print("Starting screenshot capture process...")

        // Ensure the output directory exists
        let folderURL = URL(fileURLWithPath: folderPath, isDirectory: true)
        print("Output directory: \(folderURL.path)")
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            print("Output directory created or already exists.")
        } catch {
            let errorMessage = "Failed to create output directory: \(error.localizedDescription)"
            print(errorMessage)
            rejecter("DIRECTORY_ERROR", errorMessage, error)
            return
        }

        // Check for screen recording permission (macOS 10.15+)
        print("Checking screen recording permission...")
        guard CGPreflightScreenCaptureAccess() else {
            let errorMessage = "Screen recording permission is required. Please grant permission in System Preferences."
            print(errorMessage)
            rejecter("PERMISSION_ERROR", errorMessage, nil)
            return
        }
        print("Screen recording permission granted.")

        // Get the list of active displays
        print("Retrieving active displays...")
        var displayCount: UInt32 = 0
        var result = CGGetActiveDisplayList(0, nil, &displayCount)
        guard result == .success else {
            let errorMessage = "Failed to retrieve the number of active displays"
            print(errorMessage)
            rejecter("DISPLAY_ERROR", errorMessage, nil)
            return
        }
        print("Number of active displays: \(displayCount)")

        let allocated = Int(displayCount)
        let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
        defer { activeDisplays.deallocate() }
        print("Allocated memory for active displays.")

        result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
        guard result == .success else {
            let errorMessage = "Failed to retrieve active displays"
            print(errorMessage)
            rejecter("DISPLAY_ERROR", errorMessage, nil)
            return
        }
        print("Successfully retrieved active displays.")

        // Capture screenshots for each display
        let count = Int(displayCount)
        print("Starting screenshot capture for \(count) displays...")
        for index in 0..<count {
            let displayID = activeDisplays[index]
            let timestamp = createTimeStamp()
            let fileURL = folderURL.appendingPathComponent("\(timestamp)_\(index).jpg")
            print("Capturing screenshot for display \(index) at path: \(fileURL.path)")

            guard let screenshot = CGDisplayCreateImage(displayID) else {
                let errorMessage = "Failed to capture screenshot for display \(index)"
                print(errorMessage)
                rejecter("CAPTURE_ERROR", errorMessage, nil)
                return
            }
            print("Screenshot captured for display \(index).")

            let bitmapRep = NSBitmapImageRep(cgImage: screenshot)
            guard let jpegData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 1.0]) else {
                let errorMessage = "Failed to convert screenshot to JPEG for display \(index)"
                print(errorMessage)
                rejecter("CONVERSION_ERROR", errorMessage, nil)
                return
            }
            print("Screenshot converted to JPEG for display \(index).")

            do {
                try jpegData.write(to: fileURL, options: .atomic)
                print("Screenshot saved successfully for display \(index) at \(fileURL.path).")
            } catch {
                let errorMessage = "Failed to save screenshot for display \(index): \(error.localizedDescription)"
                print(errorMessage)
                rejecter("SAVE_ERROR", errorMessage, error)
                return
            }
        }

        let successMessage = "Screenshots saved successfully at \(folderURL.path)"
        print(successMessage)
        resolver(successMessage)
    }

    private func createTimeStamp() -> Int64 {
        let timestamp = Int64(Date().timeIntervalSince1970)
        print("Generated timestamp: \(timestamp)")
        return timestamp
    }
}
