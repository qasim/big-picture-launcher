//
//  AppDelegate.swift
//  big-picture-launcher
//
//  Created by Qasim on 2016-01-28.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "controllerDidConnect",
            name: "GCControllerDidConnectNotification",
            object: nil)
    }

    func controllerDidConnect() {
        // TODO: Launch Big Picture
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}
