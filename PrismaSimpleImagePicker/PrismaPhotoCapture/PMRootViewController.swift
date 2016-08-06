//
//  PMRootViewController.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/24.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import AVFoundation

class PMRootViewController: UIViewController, PMImageProtocol {
    
    
    @IBOutlet weak var captureHeaderView: UIView!
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoHeaderView: PMPhotoHeaderView?
    var styleHeaderView: PMStyleHeaderView?
    var state: PMImageDisplayState = PMImageDisplayState.Preivew
    var imageAngle: CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureHeaderView.backgroundColor = UIColor.blackColor()
        captureHeaderView.layer.masksToBounds = true
        
        // Add navigation
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let baseNav = storyBoard.instantiateViewControllerWithIdentifier("mainNavigationController") as? PMNavigationController
        baseNav!.frameOrigin = CGPointMake(0, UIScreen.mainScreen().bounds.size.width)
        self.addChildViewController(baseNav!)
        view.addSubview(baseNav!.view)
        
        // Tap gesture to focus
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(PMRootViewController.tapHeader))
        tap.numberOfTapsRequired = 1
        captureHeaderView.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Preview
        if let layer = previewLayer {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.frame = captureHeaderView.bounds
            CATransaction.commit()
        }
    }
    
    // Tap header to focus
    func tapHeader(tap: UITapGestureRecognizer) {
        
        singleTapHeaderAction(tap: tap)
    }
    
    
    // MARK: PMImageProtocol
    
    // Display header view
    var displayHeaderView: UIView {
        return captureHeaderView
    }
    
    // Display image
    var displayImage: UIImage {
        get {
            if let style = styleHeaderView {
                return style.imageView.image!
            }
            return (photoHeaderView?.image)!
        }
    }
    
    // Tap header to focus
    private var _singleTapHeaderAction: ((tap: UITapGestureRecognizer)->Void) = {(tap: UITapGestureRecognizer) in}
    var singleTapHeaderAction: ((tap: UITapGestureRecognizer)->Void) {
        set {
            _singleTapHeaderAction = newValue
        }
        get {
            return _singleTapHeaderAction
        }
    }
    
    // Image orienttation affter rotated
    private var _rotatedImageOrientation: PMImageOrientation = .Up
    var rotatedImageOrientation: PMImageOrientation {
        get {
            return _rotatedImageOrientation
        }
        set {
            _rotatedImageOrientation = newValue
        }
    }
    
    // Set the AVCaptureVideoPreviewLayer
    func setAVCapturePreviewLayer(previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
        captureHeaderView.layer.insertSublayer(previewLayer, atIndex: 0)
    }
    
    // Change state
    func setState(state: PMImageDisplayState, image: UIImage?, selectedRect: CGRect, zoomScale:CGFloat, animated: Bool) {
        guard self.state != state else {
            return
        }
        let duration = animated ?0.25:0.0
        switch state {
        case .Preivew:
            captureHeaderView.backgroundColor = UIColor.blackColor()
            
            // Reset the angle
            imageAngle = 0
            // Hidden other header
            UIView.animateWithDuration(0.25, animations: {
                if let editHeader = self.photoHeaderView {
                    editHeader.alpha = 0
                }
                if let styleHeader = self.styleHeaderView {
                    styleHeader.alpha = 0
                }
                self.previewLayer?.opacity = 1
                }, completion: { (com: Bool) in
                    if com {
                        self.photoHeaderView?.removeFromSuperview()
                        self.photoHeaderView = nil
                        self.styleHeaderView?.removeFromSuperview()
                        self.styleHeaderView = nil
                    }
            })
            break
        case .EditImage:
            captureHeaderView.backgroundColor = UIColor.whiteColor()
            
            if self.state == .Preivew {
                // Go edit vc and add edit header
                let photoHeaderView = PMPhotoHeaderView.init(frame: captureHeaderView.bounds)
                photoHeaderView.backgroundColor = UIColor.whiteColor()
                photoHeaderView.alpha = 0
                photoHeaderView.alwaysShowGrid = true
                captureHeaderView.addSubview(photoHeaderView)
                // config the image rect
                var toRect = selectedRect
                if zoomScale == 1 {
                    toRect.origin.x = toRect.origin.x * (photoHeaderView.imageView.contentSize.width/(image?.size.width)!)
                    toRect.origin.y = toRect.origin.y * (photoHeaderView.imageView.contentSize.height/(image?.size.height)!)
                }
                
                toRect.size = photoHeaderView.bounds.size
                photoHeaderView.setImage(image!, scrollToRect: toRect, zoomScale:zoomScale)
                
                UIView.animateWithDuration(duration, animations: {
                    photoHeaderView.alpha = 1
                    self.previewLayer?.opacity = 0
                    }, completion: { (com: Bool) in
                        
                })
                self.photoHeaderView = photoHeaderView
            }else if self.state == .SingleShow {
                UIView.animateWithDuration(duration, animations: {
                    self.styleHeaderView?.alpha = 0
                    }, completion: { (com: Bool) in
                        self.styleHeaderView?.removeFromSuperview()
                        self.styleHeaderView = nil
                })
            }
            break
        case .SingleShow:
            // Go style vc
            let styleHeaderView = PMStyleHeaderView.init(frame: captureHeaderView.bounds)
            styleHeaderView.setImage(image!)
            styleHeaderView.alpha = 0
            captureHeaderView.addSubview(styleHeaderView)
            
            UIView.animateWithDuration(duration, animations: {
                styleHeaderView.alpha = 1
                self.previewLayer?.opacity = 0
                }, completion: { (com: Bool) in
                    
            })
            self.styleHeaderView = styleHeaderView
            
            break
        }
        self.state = state
    }
    
    // Rotate image
    func rotateDisplayImage(clockwise: Bool) {
        
        if clockwise {
            imageAngle += CGFloat(M_PI/2)
        }else {
            imageAngle -= CGFloat(M_PI/2)
        }
        photoHeaderView?.rotate(imageAngle, closeWise: clockwise)
    }
    
    // Cropped image affter edit
    func croppedImage() -> UIImage {
        let image = photoHeaderView?.cropImageAffterEdit()
        return image!
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
