//
//  XboxControllerListener.m
//  big-picture-launcher
//
//  Created by Qasim on 2016-01-30.
//  Copyright © 2016 Qasim Iqbal. All rights reserved.
//
//  This file is a modified version of
//  github.com/360Controller/360Controller/blob/master/360Daemon/360Daemon.m.
//
//  MICE Xbox 360 Controller driver for Mac OS X
//  Copyright (C) 2006-2013 Colin Munro
//
//  Xbox360Controller is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  Xbox360Controller is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

#import "XboxControllerListener.h"

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/IOCFPlugIn.h>
#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hid/IOHIDKeys.h>
#include <IOKit/usb/IOUSBLib.h>
#include <ForceFeedback/ForceFeedback.h>

#define DOM_DAEMON      CFSTR("com.mice.driver.Xbox360Controller.daemon")
#define DOM_CONTROLLERS CFSTR("com.mice.driver.Xbox360Controller.devices")

static mach_port_t masterPort;
static IONotificationPortRef notifyPort;
static CFRunLoopSourceRef notifySource;
static io_iterator_t onIteratorWired;
static io_iterator_t onIteratorWireless;
static io_iterator_t onIteratorOther;
static io_iterator_t offIteratorWired;
static io_iterator_t offIteratorWireless;
static BOOL foundWirelessReceiver;
static NSDate *launchDate;

// Supported device - connecting - set settings?
static void DeviceConnected(void *param, io_iterator_t iterator)
{
    @autoreleasepool {
        io_service_t object = 0;

        while ((object = IOIteratorNext(iterator)) != 0)
        {
            if (IOObjectConformsTo(object, "WirelessHIDDevice") || IOObjectConformsTo(object, "Xbox360ControllerClass"))
            {
                // Supported device
                if (launchDate.timeIntervalSinceNow < -3)
                {
                    LaunchBigPicture();
                }
            }
            else
            {
                NSNumber *vendorID = CFBridgingRelease(IORegistryEntrySearchCFProperty(object,kIOServicePlane,CFSTR("idVendor"),kCFAllocatorDefault,kIORegistryIterateRecursively | kIORegistryIterateParents));
                NSNumber *productID = CFBridgingRelease(IORegistryEntrySearchCFProperty(object,kIOServicePlane,CFSTR("idProduct"),kCFAllocatorDefault,kIORegistryIterateRecursively | kIORegistryIterateParents));
                if ((vendorID != NULL) && (productID != NULL))
                {
                    UInt32 idVendor = [vendorID unsignedIntValue];
                    UInt32 idProduct = [productID unsignedIntValue];
                    if (idVendor == 0x045e)
                    {
                        // Microsoft
                        switch (idProduct)
                        {
                            case 0x028f:    // Plug'n'charge cable
                            case 0x0719:    // Microsoft Wireless Gaming Receiver
                            case 0x0291:    // Third party Wireless Gaming Receiver
                                foundWirelessReceiver = YES;
                                break;
                        }

                        // Plug'n'charge or wireless receiver
                        if (foundWirelessReceiver && launchDate.timeIntervalSinceNow < -2) {
                            LaunchBigPicture();
                        }
                    }
                }
            }
            IOObjectRelease(object);
        }
    }
}

void ListenForControllers()
{
    @autoreleasepool {
        foundWirelessReceiver = NO;

        // Get master port, for accessing I/O Kit
        IOMasterPort(MACH_PORT_NULL,&masterPort);

        // Set up notification of USB device addition/removal
        notifyPort=IONotificationPortCreate(masterPort);
        notifySource=IONotificationPortGetRunLoopSource(notifyPort);
        CFRunLoopAddSource(CFRunLoopGetCurrent(),notifySource,kCFRunLoopCommonModes);

        // Start listening
        // USB devices
        IOServiceAddMatchingNotification(notifyPort, kIOFirstMatchNotification, IOServiceMatching(kIOUSBDeviceClassName), DeviceConnected, NULL, &onIteratorOther);
        DeviceConnected(NULL, onIteratorOther);
        // Wired 360 devices

        IOServiceAddMatchingNotification(notifyPort, kIOFirstMatchNotification, IOServiceMatching("Xbox360ControllerClass"), DeviceConnected, NULL, &onIteratorWired);
        DeviceConnected(NULL, onIteratorWired);

        // Wireless 360 devices
        IOServiceAddMatchingNotification(notifyPort, kIOFirstMatchNotification, IOServiceMatching("WirelessHIDDevice"), DeviceConnected, NULL, &onIteratorWireless);
        DeviceConnected(NULL, onIteratorWireless);

        // Store current time
        launchDate = [[NSDate alloc] init];

        // Run loop
        CFRunLoopRun();
    }
}

void StopListeningForControllers()
{
    IOObjectRelease(onIteratorOther);
    IOObjectRelease(onIteratorWired);
    IOObjectRelease(offIteratorWired);
    IOObjectRelease(onIteratorWireless);
    IOObjectRelease(offIteratorWireless);
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), notifySource, kCFRunLoopCommonModes);
    CFRunLoopSourceInvalidate(notifySource);
    IONotificationPortDestroy(notifyPort);
}

void LaunchBigPicture()
{
    NSURL *url = [NSURL URLWithString: @"steam://open/bigpicture"];
    [[NSWorkspace sharedWorkspace] openURL: url];
}