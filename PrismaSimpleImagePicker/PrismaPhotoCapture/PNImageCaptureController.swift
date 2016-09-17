//
//  PNImageCaptureController.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/24.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Photos
import CoreImage

class PNImageCaptureController: UIViewController, PMImagePickerControllerDelegate {
    
    
    @IBOutlet weak var captureButton: PMCaptureButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var flashBarItem: UIBarButtonItem!
    @IBOutlet weak var selectPhotoButton: UIButton!
    var session: AVCaptureSession! = AVCaptureSession()
    var deviceIntput: AVCaptureDeviceInput?
    var stillImageOutPut: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoGroups = [PHAssetCollection]()
    var photoAssets = [PHAsset]()
    var isUsingFrontFacingCamera: Bool = false
    var currentFlashMode: AVCaptureFlashMode = .Off
    let screenSize = ScreenSize()
    let orientationManger: PMDeviceOrientation = PMDeviceOrientation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init view
        initNavigationBar()
        
        // Auth
        PMImageManger.captureAuthorization { (canCapture: Bool) in
            if canCapture {
                self.initAVCapture()
                self.session.startRunning()
            }else {
                self.session.stopRunning()
            }
        }
        
        PMImageManger.photoAuthorization { (canAssets: Bool) in
            if canAssets {
                self.photoGroups = PMImageManger.photoLibrarys()
                self.photoAssets = PMImageManger.photoAssetsForAlbum(self.photoGroups.first!)
                PMImageManger.imageFromAsset(self.photoAssets.first!, isOriginal: false, toSize: CGSizeMake(150, 150), resultHandler: { (image: UIImage?) in
                    self.selectPhotoButton.setBackgroundImage(image, forState: .Normal)
                })
            }
        }
        
        // Tap header to change focus
        photoPisplayBoard?.singleTapHeaderAction = { (tap: UITapGestureRecognizer) in
            self.tapToChangeFocus(tap)
        }
    }
    
    func initNavigationBar() {
        // Navigation bar
        navigationBar.setBackgroundImage(UIImage.init(), forBarPosition: UIBarPosition.Top, barMetrics: UIBarMetrics.Default)
        navigationBar.shadowImage = UIImage.init()
        
        let navigationItem = navigationBar.topItem
        
        // Flash button
        let letButton = UIButton.init(type: UIButtonType.System)
        letButton.frame = CGRectMake(-10, 0, 44, 44)
        letButton.setImage(UIImage.init(named: "flash"), forState: UIControlState.Normal)
        letButton.addTarget(self, action: #selector(self.changeFlash(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let letBarItem = UIBarButtonItem.init(customView: letButton)
        letButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10)
        navigationItem!.leftBarButtonItem = letBarItem
        
        // Camera possion
        let image = UIImage.init(named: "flip")
        let hImage = image?.imageWithColor(UIColor.lightGrayColor())
        let titleButton = UIButton.init(type: UIButtonType.Custom)
        titleButton.setImage(image, forState: UIControlState.Normal)
        titleButton.setImage(hImage, forState: UIControlState.Selected)
        titleButton.setImage(hImage, forState: UIControlState.Highlighted)
        titleButton.sizeToFit()
        titleButton.addTarget(self, action: #selector(self.changeCameraPossion), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem!.titleView = titleButton
    }
    
    func initAVCapture() {
        // Device
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        try! device.lockForConfiguration()
        if device.hasFlash {
            device.flashMode = AVCaptureFlashMode.Off
        }
        if device.isFocusModeSupported(.AutoFocus) {
            device.focusMode = .AutoFocus
        }
        if device.isWhiteBalanceModeSupported(.AutoWhiteBalance) {
            device.whiteBalanceMode = .AutoWhiteBalance
        }
        if device.exposurePointOfInterestSupported {
            device.exposureMode = .ContinuousAutoExposure
        }
        device.unlockForConfiguration()
        
        // Input & Output
        // When init AVCaptureDeviceInput first, system will show alert to confirm the authentication from user.
        // But the best way is send the acces request manual. see `requestAccessForMediaType`
        deviceIntput = try! AVCaptureDeviceInput(device: device)
        stillImageOutPut = AVCaptureStillImageOutput()
        
        // Output settings
        stillImageOutPut?.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG, AVVideoScalingModeKey:AVVideoScalingModeResize]
        
        if session.canAddInput(deviceIntput) {
            session.addInput(deviceIntput)
        }
        if session.canAddOutput(stillImageOutPut) {
            session.addOutput(stillImageOutPut)
        }
        
        session.sessionPreset = AVCaptureSessionPresetPhoto
        // Preview
        previewLayer = AVCaptureVideoPreviewLayer.init(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // Set root vc avcapture preview layer
        photoPisplayBoard?.setAVCapturePreviewLayer(previewLayer!)
    }
    
    // MARK: Capture action
    
    @IBAction func capturePhoto(sender: AnyObject) {
        
        // Disable the capture button
        captureButton.enabled = false
        
        let stillImageConnection = stillImageOutPut?.connectionWithMediaType(AVMediaTypeVideo)
//        let curDeviceOrientation = UIDevice.currentDevice().orientation
//        let avCaptureOrientation = PMDeviceOrientation.avOrientationFromDeviceOrientation(curDeviceOrientation)
        let avCaptureOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.currentDevice().orientation.rawValue)!
        if stillImageConnection!.supportsVideoOrientation {
            stillImageConnection!.videoOrientation = avCaptureOrientation
        }
        stillImageConnection!.videoScaleAndCropFactor = 1
        
        stillImageOutPut?.captureStillImageAsynchronouslyFromConnection(stillImageConnection, completionHandler: { (imageDataSampleBuffer: CMSampleBufferRef!, error: NSError!) in
            let jpegData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
            
            if var image = UIImage(data: jpegData) {
                
                // Fix orientation & crop image
                image = image.fixOrientation()
                image = PMImageManger.cropImageAffterCapture(image,toSize: self.previewLayer!.frame.size)
                
                // Fix interface orientation
                if !self.orientationManger.deviceOrientationMatchesInterfaceOrientation() {
                    let interfaceOrientation = self.orientationManger.orientation()
                    image = image.rotateImageFromInterfaceOrientation(interfaceOrientation)
                }
                
                // Mirror the image
                if self.isUsingFrontFacingCamera {
                    image = UIImage.init(CGImage: image.CGImage!, scale: image.scale, orientation: UIImageOrientation.UpMirrored)
                }
                
                // Save photo
                let authorStatus = ALAssetsLibrary.authorizationStatus()
                if  authorStatus == ALAuthorizationStatus.Restricted || authorStatus == ALAuthorizationStatus.Denied {
                    return
                }
                
                let library = ALAssetsLibrary()
                if self.isUsingFrontFacingCamera {
                    library.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation.UpMirrored, completionBlock: { (url: NSURL!, error: NSError!) in
                        
                    })
                }else {
                    let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault,imageDataSampleBuffer,kCMAttachmentMode_ShouldPropagate)
//                    let attachments = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, nil)
                    library.writeImageToSavedPhotosAlbum(image.CGImage!, metadata: attachments as? [NSObject:AnyObject] , completionBlock: { (url: NSURL!, error: NSError!) in
                        
                    })
                }
                
                // Go to style vc
                self.photoPisplayBoard?.setState(.SingleShow, image: image, selectedRect: CGRectZero, zoomScale:1, animated: false)
                let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                let styleVC = storyBoard.instantiateViewControllerWithIdentifier("styleImageController") as? PMImageProcessController
                styleVC?.fromCapture = true
                self.navigationController?.pushViewController(styleVC!, animated: true)
            }
            
            // Stop session
            self.session.stopRunning()
        })
    }
    
    func changeCameraPossion() {
        
        var desiredPosition : AVCaptureDevicePosition?
        let navigationItem = navigationBar.topItem
        
        if (isUsingFrontFacingCamera){
            desiredPosition = AVCaptureDevicePosition.Back
            navigationItem!.leftBarButtonItem!.customView?.userInteractionEnabled = true
            navigationItem!.leftBarButtonItem!.highlighted = false
        }else{
            desiredPosition = AVCaptureDevicePosition.Front
            navigationItem!.leftBarButtonItem!.customView?.userInteractionEnabled = false
            navigationItem!.leftBarButtonItem!.highlighted = true
        }
        
        for device in AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) {
            let device = device as! AVCaptureDevice
            if device.position == desiredPosition {
                // Config device
                try! device.lockForConfiguration()
                if device.hasFlash {
                    device.flashMode = currentFlashMode
                }
                if device.isFocusModeSupported(.AutoFocus) {
                    device.focusMode = .ContinuousAutoFocus
                }
                if device.isWhiteBalanceModeSupported(.AutoWhiteBalance) {
                    device.whiteBalanceMode = .AutoWhiteBalance
                }
                if device.exposurePointOfInterestSupported {
                    device.exposureMode = .ContinuousAutoExposure
                }
                device.unlockForConfiguration()
                // Add device
                let input = try! AVCaptureDeviceInput(device: device)
                session.removeInput(deviceIntput)
                session.addInput(input)
                deviceIntput = input
                break;
            }
        }
        
        isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
    }
    
    // Tap header to focus
    func tapToChangeFocus(tap: UITapGestureRecognizer) {
        guard !isUsingFrontFacingCamera else {
            return
        }
        // Location
        let point = tap.locationInView(photoPisplayBoard?.displayHeaderView)
        
        // Show square
        showSquareBox(point)
        
        // Change focus
//        let pointInCamera = convertToPointOfInterestFromViewCoordinates(point)
        let pointInCamera = previewLayer!.captureDevicePointOfInterestForPoint(point)
        let device = deviceIntput?.device
        try! device!.lockForConfiguration()
        
        if device!.focusPointOfInterestSupported {
            device!.focusPointOfInterest = pointInCamera
        }
        if device!.isFocusModeSupported(.ContinuousAutoFocus) {
            device!.focusMode = .ContinuousAutoFocus
        }
        if device!.exposurePointOfInterestSupported {
            device?.exposureMode = .ContinuousAutoExposure
            device?.exposurePointOfInterest = pointInCamera
        }
        device?.subjectAreaChangeMonitoringEnabled = true
        device!.focusPointOfInterest = pointInCamera
        
        device!.unlockForConfiguration()
    }
    
    @IBAction func selectPhoto(sender: AnyObject) {
        let nav = PMImagePickerController.init()
        nav.pmDelegate = self
        nav.photoGroups = photoGroups
        nav.photoAssets = photoAssets
        weak var weakSelf = self
        self.presentViewController(nav, animated: true) {
            weakSelf!.session.stopRunning()
        }
    }
    
    @IBAction func changeFlash(sender: AnyObject) {
        var image: UIImage? = nil
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        try! device.lockForConfiguration()
        if device.hasFlash {
            switch device.flashMode {
            case .Off:
                device.flashMode = .On
                currentFlashMode = .On
                image = UIImage.init(named: "flash-on")
                break
            case .On:
                device.flashMode = .Auto
                currentFlashMode = .Auto
                image = UIImage.init(named: "flash-auto")
                break
            case .Auto:
                device.flashMode = .Off
                currentFlashMode = .Off
                image = UIImage.init(named: "flash")
                break
            }
            // Flash baritem
            let letButton = navigationBar.topItem!.leftBarButtonItem?.customView as? UIButton
            letButton?.setImage(image, forState: UIControlState.Normal)
        }
        device.unlockForConfiguration()
    }
    
    @IBAction func setting(sender: AnyObject) {
        
    }
    
    // Show focus square box
    private func showSquareBox(point: CGPoint) {
        // remove box
        guard let header = photoPisplayBoard?.displayHeaderView else {
            return
        }
        for layer in header.layer.sublayers!{
            if layer.name == "box" {
                layer.removeFromSuperlayer()
            }
        }
        // create a box layer
        let width = CGFloat(60)
        let box = CAShapeLayer.init()
        box.frame = CGRectMake(point.x - width/2, point.y - width/2, width, width)
        box.borderWidth = 1
        box.borderColor = UIColor.whiteColor().CGColor
        box.name = "box"
        header.layer.addSublayer(box)
        
        // animation
        let alphaAnimation = CABasicAnimation.init(keyPath: "opacity")
        alphaAnimation.fromValue = 1
        alphaAnimation.toValue = 0
        alphaAnimation.duration = 0.01
        alphaAnimation.beginTime = CACurrentMediaTime()
        
        let scaleAnimation = CABasicAnimation.init(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.2
        scaleAnimation.toValue = 1
        scaleAnimation.duration = 0.35
        scaleAnimation.beginTime = CACurrentMediaTime()
        
        box.addAnimation(alphaAnimation, forKey: nil)
        box.addAnimation(scaleAnimation, forKey: nil)
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64((0.35 + 0.2) * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            box.removeFromSuperlayer()
        }
    }
    
    // Convert the touch point to focus point of interest. The focus point of interest is from [0, 0] to [1, 1].
    private func convertToPointOfInterestFromViewCoordinates(point: CGPoint) -> CGPoint {
        var interestPoint = CGPointMake(0.5, 0.5)
        for _port in deviceIntput!.ports {
            if let port = _port as? AVCaptureInputPort {
                let cleanAperture = CMVideoFormatDescriptionGetCleanAperture(port.formatDescription, true)
                let apertureSize = cleanAperture.size
                let frameSize = previewLayer?.bounds.size
                let apertureRatio = apertureSize.height / apertureSize.width;
                let viewRatio = frameSize!.width / frameSize!.height;
                var xc = CGFloat(0.5)
                var yc = CGFloat(0.5)
                
                // Just calculate videoGravity of AVLayerVideoGravityResizeAspectFill mode
                if viewRatio > apertureRatio {
                    let y2 = apertureSize.width * (frameSize!.width / apertureSize.height)
                    xc = (point.y + ((y2 - frameSize!.height) / 2)) / y2
                    yc = (frameSize!.width - point.x) / frameSize!.width
                } else {
                    let x2 = apertureSize.height * (frameSize!.height / apertureSize.width)
                    yc = 1.0 - ((point.x + ((x2 - frameSize!.width) / 2)) / x2)
                    xc = point.y / frameSize!.height
                }
                interestPoint = CGPointMake(xc, yc)
                break
            }
        }
        return interestPoint
    }
    
    // MARK: PMImagePickerControllerDelegate
    
    func imagePickerController(picker: PMImagePickerController, didFinishPickingImage originalImage: UIImage, selectedRect: CGRect, zoomScale:CGFloat) {
        photoPisplayBoard?.setState(PMImageDisplayState.EditImage, image: originalImage, selectedRect: selectedRect, zoomScale:zoomScale, animated: false)
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let editVC = storyBoard.instantiateViewControllerWithIdentifier("imageEditController") as? PMImageEditController
        navigationController?.pushViewController(editVC!, animated: false)
    }
    
    func imagePickerController(picker: PMImagePickerController, didFinishPickingImage image: UIImage) {}
    
    func imagePickerControllerDidCancel(picker: PMImagePickerController) {
        session.startRunning()
    }
    
    override func viewWillAppear(animated: Bool) {
        session.startRunning()
        captureButton.enabled = true
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

extension UIBarButtonItem {
    
    var highlighted: Bool {
        set {
            if let button = customView as? UIButton {
                button.highlighted = newValue
            }
        }
        get {
            if let button = customView as? UIButton {
                return button.highlighted
            }
            return false
        }
    }
}


