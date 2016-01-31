//
//  AppDelegate.swift
//  big-picture-launcher
//
//  Created by Qasim on 2016-01-28.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//

import Cocoa
import GameController

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        ListenForControllers()

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "launchBigPicture",
            name: "GCControllerDidConnectNotification",
            object: nil)
    }

    func launchBigPicture() {
        LaunchBigPicture();
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        StopListeningForControllers()
    }

}
