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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        ListenForControllers()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        StopListeningForControllers()
    }

}
