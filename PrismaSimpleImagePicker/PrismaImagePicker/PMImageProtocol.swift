//
//  PMImageProtocol.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/29.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import AVFoundation

enum PMImageDisplayState : Int {
    
    case Preivew
}

protocol PMImageProtocol {
    // Set the AVCaptureVideoPreviewLayer
    func displayPreviewLayer(layer: AVCaptureVideoPreviewLayer)
    // Change state
    
}

extension UIViewController {
    
}
