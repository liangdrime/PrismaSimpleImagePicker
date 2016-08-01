//
//  PMImageProtocol.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/29.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import AVFoundation

@objc enum PMImageOrientation : Int {
    case Up // Normal affter rotated
    case Down // Down affter rotated
    case Left // Left affter rotated
    case Right // Right after rotated
}

@objc enum PMImageDisplayState : Int {
    case Preivew // Display AVCapturePreviewLayer
    case EditImage // Edit image, such as rotate, scale.
    case SingleShow // Just display image to make art photo
}

@objc protocol PMImageProtocol {
    // Display image
    optional var displayImage: UIImage { get }
    
    // Display header view
    var displayHeaderView: UIView { get }
    
    // Image orienttation affter rotated
    var rotatedImageOrientation: PMImageOrientation { get }
    
    // Tap header to focus
    var singleTapHeaderAction: ((tap: UITapGestureRecognizer)->Void) { get set }
    
    // Set the AVCaptureVideoPreviewLayer
    func setAVCapturePreviewLayer(layer: AVCaptureVideoPreviewLayer)
    
    // Change state
    func setState(state: PMImageDisplayState, image: UIImage?, selectedRect: CGRect, animated: Bool)
    
    // Rotate image
    func rotateDisplayImage(clockwise: Bool)
    
    // Cropped image affter edit
    func croppedImage() -> UIImage
    
}

extension UIViewController {
    var photoPisplayBoard: PMImageProtocol? {
        get {
            let vc = UIApplication.sharedApplication().keyWindow?.rootViewController
            if let rootVC = vc as? PMRootViewController {
                return rootVC
            }
            return nil
        }
    }
    
}
