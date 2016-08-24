//
//  PMDeviceOrientation.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/29.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class PMDeviceOrientation: NSObject {
    
    var motionManager: CMMotionManager = CMMotionManager()
    
    override init() {
        super.init()
        setupMotionManger()
    }
    
    // MARK: Actual orientation
    func orientation() -> UIDeviceOrientation {
        return actualDeviceOrientationFromAccelerometer()
    }
    
    func deviceOrientationMatchesInterfaceOrientation() -> Bool {
        return orientation() == UIDevice.currentDevice().orientation
    }
    
    /// Change UIDeviceOrientation to AVCaptureVideoOrientation
    class func avOrientationFromDeviceOrientation(deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        var result = AVCaptureVideoOrientation.Portrait
        if deviceOrientation == UIDeviceOrientation.LandscapeLeft {
            result = .LandscapeRight
        }else if deviceOrientation == UIDeviceOrientation.LandscapeRight {
            result = .LandscapeLeft
        }else if deviceOrientation == UIDeviceOrientation.PortraitUpsideDown {
            result = .PortraitUpsideDown
        }
        return result
    }
    
    // MARK: Privatte
    private func setupMotionManger() {
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        motionManager.accelerometerUpdateInterval = 0.005
        motionManager.startAccelerometerUpdates()
    }
    
    private func teardownMotionManager() {
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
        motionManager.stopAccelerometerUpdates()
    }
    
    private func actualDeviceOrientationFromAccelerometer() -> UIDeviceOrientation {
        let acceleration = motionManager.accelerometerData!.acceleration
        if acceleration.z < -0.75 {
            return UIDeviceOrientation.FaceUp
        }
        
        if acceleration.z > 0.75 {
            return UIDeviceOrientation.FaceDown
        }
        
        let scaling = 1.0 / (fabs(acceleration.x) + fabs(acceleration.y))
        
        let x = acceleration.x * scaling
        let y = acceleration.y * scaling
        
        if x < -0.5 {
            return UIDeviceOrientation.LandscapeLeft
        }
        
        if x > 0.5 {
            return UIDeviceOrientation.LandscapeRight
        }
        
        if y > 0.5 {
            return UIDeviceOrientation.PortraitUpsideDown
        }
        
        return UIDeviceOrientation.Portrait
    }
    
    deinit {
        teardownMotionManager()
    }
}
