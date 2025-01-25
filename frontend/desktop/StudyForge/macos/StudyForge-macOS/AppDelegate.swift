//
//  AppDelegate.swift
//  StudyForge
//
//  Created by Demi Daniel on 1/25/25.
//
import Cocoa
import Foundation
import React

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let jsBundlePath: URL
        
        #if DEBUG
            guard let jsBundlePath = RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index") else {
                fatalError("Failed to find JavaScript bundle URL for development")
            }
        #else
            guard let jsBundlePath = Bundle.main.url(forResource: "StudyForge", withExtension: "jsbundle") else {
                fatalError("Failed to find JavaScript bundle for production")
            }
        #endif

        let rootView = RCTRootView(bundleURL: jsBundlePath, moduleName: "StudyForge", initialProperties: nil, launchOptions: nil)

        let rootViewController = NSViewController()
        rootViewController.view = rootView
        
        _ = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        window = NSWindow(contentRect: NSMakeRect(0, 0, 800, 600),
                          styleMask: [.titled, .closable, .resizable, .miniaturizable],
                          backing: .buffered,
                          defer: false,
                          screen: NSScreen.main)
        
        window.contentViewController = rootViewController
        window.makeKeyAndOrderFront(nil)
        window.title = "StudyForge"
        window.center()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean-up code (if needed)
    }
}

