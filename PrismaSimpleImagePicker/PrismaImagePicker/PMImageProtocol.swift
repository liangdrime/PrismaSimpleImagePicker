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
    case Preivew // Display AVCapturePreviewLayer
    case EditImage // Edit image, such as rotate, scale.
    case SingleShow // Just display image to make art photo
}

protocol PMImageProtocol {
    // Set the AVCaptureVideoPreviewLayer
    func displayPreviewLayer(layer: AVCaptureVideoPreviewLayer)
    
    // Change state
    func setState(state: PMImageDisplayState, image: UIImage, animated: Bool)
    
    // Rotate image
    func rotateDisplayImage(clockwise: Bool)
    
}

extension UIViewController {
    
}
