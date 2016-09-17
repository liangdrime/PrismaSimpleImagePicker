//
//  PMImageManger.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/29.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import Photos
import CoreImage
import Accelerate


public enum RotateOrientation : Int {
    
    case Up // default orientation
    case Down // 180 deg rotation
    case Left // 90 deg CCW
    case Right // 90 deg CW
    case UpMirrored // as above but image mirrored along other axis. horizontal flip
    case DownMirrored // horizontal flip
    case LeftMirrored // vertical flip
    case RightMirrored // vertical flip
}

class PMImageManger: NSObject {
    /// Camera about
    
    // MARK: Authorizations
    /// Capture authorization
    class func captureAuthorization(shouldCapture: ((Bool)-> Void)!) {

        let captureStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch captureStatus {
        case.NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted:  Bool) -> Void in
                runOnMainQuene({ () -> Void in
                    shouldCapture(granted)
                })
            })
            break
        case.Authorized:
            shouldCapture(true)
            break
        default:
            shouldCapture(false)
            break
        }
    }
    
    // Run on main quene
    class func runOnMainQuene(callBack: (()->Void)?) {
        if NSThread.currentThread().isMainThread {
            if let call = callBack {
                call()
            }
        }else {
            dispatch_async(dispatch_get_main_queue(), {
                if let call = callBack {
                    call()
                }
            })
        }
    }
    
    /// Crop the image to target size, default crop in the middle
    class func cropImageAffterCapture(originImage: UIImage, toSize: CGSize) -> UIImage {
        
        let ratio = toSize.height/toSize.width
        let width = originImage.size.width
        let height = width * ratio
        let x = CGFloat(0)
        let y = (originImage.size.height - height)/2
        
        let finalRect = CGRectMake(x, y, width, height)
        let croppedImage = UIImage.init(CGImage: CGImageCreateWithImageInRect(originImage.CGImage!, finalRect)!, scale: originImage.scale, orientation: originImage.imageOrientation)
        
        return croppedImage
    }
    
    /// Crop the image to target rect
    class func cropImageToRect(originImage: UIImage, toRect: CGRect) -> UIImage {
        
        let croppedImage = UIImage.init(CGImage: CGImageCreateWithImageInRect(originImage.CGImage!, toRect)!, scale: originImage.scale, orientation: originImage.imageOrientation)
        
        return croppedImage
    }
    
    /// Photolibrary authorization
    class func photoAuthorization(canGoAssets: ((Bool)-> Void)!) {

        let PhotoStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch (PhotoStatus) {
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) in
                dispatch_async(dispatch_get_main_queue(), {
                    switch (status) {
                    case .Authorized:
                        canGoAssets(true)
                        break
                    default:
                        canGoAssets(false)
                        break
                    }
                })
            }
            break
        case .Authorized:
            canGoAssets(true)
            break
        default:
            canGoAssets(false)
            break
        }
    }
    
    // MARK: Photo libiary
    /// Get photo albums
    class func photoLibrarys() -> [PHAssetCollection] {
        var photoGroups:[PHAssetCollection] = [PHAssetCollection]()
        
        // Camera
        let cameraRoll: PHAssetCollection = (PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: nil).lastObject as? PHAssetCollection)!
        if cameraRoll.photosCount > 0 {
            photoGroups.append(cameraRoll)
        }
        
        // Favorites
        let favorites: PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumFavorites, options: nil)
        favorites.enumerateObjectsWithOptions(.Reverse) { (obj, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            let collection = obj as! PHAssetCollection
            guard collection.photosCount > 0 else {
                return
            }
            photoGroups.append(collection)
        }
        
        // ScreenShots
        if #available(iOS 9.0, *) {
            let screenShots: PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumScreenshots, options: nil)
            screenShots.enumerateObjectsWithOptions(.Reverse) { (obj, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                let collection = obj as! PHAssetCollection
                guard collection.photosCount > 0 else {
                    return
                }
                photoGroups.append(collection)
            }
        }
        
        // User photos
        let assetCollections: PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .AlbumRegular, options: nil)
        assetCollections.enumerateObjectsWithOptions(.Reverse) { (obj, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            let collection = obj as! PHAssetCollection
            guard collection.photosCount > 0 else {
                return
            }
            photoGroups.append(collection)
        }
        
        return photoGroups
    }
    
    /// Get photos from an album
    class func photoAssetsForAlbum(collection: PHAssetCollection) -> [PHAsset] {
        var photoAssets:[PHAsset] = [PHAsset]()

        let asstes: PHFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
        asstes.enumerateObjectsWithOptions(NSEnumerationOptions.Reverse) { (obj, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            photoAssets.append(obj as! PHAsset)
        }
        return photoAssets
    }
    
    // Get image from a PHAsset
    class func imageFromAsset(asset: PHAsset, isOriginal original: Bool, toSize: CGSize?, resultHandler: (UIImage?)->Void) {
        let options = PHImageRequestOptions()
        options.synchronous = true
        options.resizeMode = .Fast
        options.deliveryMode = .FastFormat
        
        var size = CGSizeMake(100, 100)
        if original {
            size = CGSizeMake(CGFloat(asset.pixelWidth), CGFloat(asset.pixelHeight))
        }else if let _toSize = toSize {
            size = _toSize
        }
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: options) { (image: UIImage?, info: [NSObject : AnyObject]?) in
            resultHandler(image)
        }
    }
    
    // Translate degress to image orientation
    class func imageOrientationFromDegress(angle: CGFloat) -> UIImageOrientation {
        var orientation = UIImageOrientation.Up
        let ratio = (angle/CGFloat(M_PI/2))%4
        switch ratio {
        case 0:
            orientation = .Up
            break
        case 1, -3:
            orientation = .Right
            break
        case 2, -2:
            orientation = .Down
            break
        case 3, -1:
            orientation = .Left
            break
        default:
            orientation = .Up
            break
        }
        return orientation
    }
    
}

// MARK: UIImage ectension
extension UIImage {
    // Get a image with color
    func imageWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context!, 0, self.size.height)
        CGContextScaleCTM(context!, 1.0, -1.0)
        CGContextSetBlendMode(context!, CGBlendMode.Normal)
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        CGContextClipToMask(context!, rect, self.CGImage!)
        color.setFill()
        CGContextFillRect(context!, rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    // Get a image with color & size
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage  {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context!, color.CGColor)
        CGContextFillRect(context!, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    /**
     Method to fix the orientation of an image.(The orientation of an image is just the orientation for the possion when take a photo)
     An image after capture, the orientation is not the correct possion(roated 90 degress), owing to the position of sensor. And the default possion of iPhone is landscape & home button on the right.
     AVPreviewLayer has fixed the possion of the image, so it display a correct image. But when we handle the image, the image is just original(not on the corrent possion).
     So, if we make a capture portrait, Actually the image landscape left and the orientation is right.
     e.g.
     
     |  _ |       __________
     | |_ |  -->            |
     | |  |  -->   |__|___  |  So, the image is `|_|__`
     | __ |       __________|  And orientation is right(the sensor orientation when take a photo)
     
     - returns: An image has been fixed oriention
     */
    func fixOrientation() -> UIImage {
        return fixOrientation(imageOrientation)
    }
    
    /**
     Rotate image to the target orientation.
     
     - parameter rotateOrientation: target orientation
     
     - returns: An image has been changed to the target orientaion
     */
    func rotateImageTo(rotateOrientation: RotateOrientation) -> UIImage {
        
        var imageOrientation = UIImageOrientation.Up
        switch rotateOrientation {
        case .Up:
            imageOrientation = .Up
            break
        case .UpMirrored:
            imageOrientation = .UpMirrored
            break
        case .Left:
            imageOrientation = .Right
            break
        case .LeftMirrored:
            imageOrientation = .RightMirrored
            break
        case .Right:
            imageOrientation = .Left
            break
        case .RightMirrored:
            imageOrientation = .LeftMirrored
            break
        case .Down:
            imageOrientation = .Down
            break
        case .DownMirrored:
            imageOrientation = .DownMirrored
            break
        }
        
        return fixOrientation(imageOrientation)
    }
    
    func rotateImageFromInterfaceOrientation(orientation: UIDeviceOrientation) -> UIImage {
        var rotateOrientation = RotateOrientation.Up
        switch orientation {
        case .Portrait:
            rotateOrientation = .Up
            break
        case .LandscapeLeft:
            rotateOrientation = .Right
            break
        case .LandscapeRight:
            rotateOrientation = .Left
            break
        case .PortraitUpsideDown:
            rotateOrientation = .Down
            break
        default:
            rotateOrientation = .Up
            break
        }
        return rotateImageTo(rotateOrientation)
    }
    
     func fixOrientation(imageOrientation: UIImageOrientation) -> UIImage {
        if imageOrientation == UIImageOrientation.Up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransformIdentity
        
        switch imageOrientation {
        case UIImageOrientation.Down, UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
        case UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            break
        case UIImageOrientation.Up, UIImageOrientation.UpMirrored:
            break
        }
        
        switch imageOrientation {
        case UIImageOrientation.UpMirrored, UIImageOrientation.DownMirrored:
            CGAffineTransformTranslate(transform, size.width, 0)
            CGAffineTransformScale(transform, -1, 1)
            break
        case UIImageOrientation.LeftMirrored, UIImageOrientation.RightMirrored:
            CGAffineTransformTranslate(transform, size.height, 0)
            CGAffineTransformScale(transform, -1, 1)
        case UIImageOrientation.Up, UIImageOrientation.Down, UIImageOrientation.Left, UIImageOrientation.Right:
            break
        }
        
        let ctx: CGContextRef = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), CGImageGetBitsPerComponent(CGImage!), 0, CGImageGetColorSpace(CGImage!)!, CGImageAlphaInfo.PremultipliedLast.rawValue)!
        
        CGContextConcatCTM(ctx, transform)
        
        switch imageOrientation {
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored, UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0, 0, size.height, size.width), CGImage!)
            break
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, size.width, size.height), CGImage!)
            break
        }
        
        let cgImage: CGImageRef = CGBitmapContextCreateImage(ctx)!
        
        return UIImage(CGImage: cgImage)
    }
}


// MARK: UIColor ectension
extension UIColor {
    
    class func RGBColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return RGBAlphaColor(red, green: green, blue: blue, alpha: 1)
    }
    
    class func RGBAlphaColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
}


// MARK: UIDevice orientation
extension UIDevice {
    
}


