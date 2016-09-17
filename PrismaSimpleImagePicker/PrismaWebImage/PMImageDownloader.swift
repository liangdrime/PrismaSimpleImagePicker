//
//  PMImageDownloader.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/8/5.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit

class PMSessionDelegate: NSObject {
    var completionHandler: ((NSData?, NSURL?, NSError?) -> Void)?
    var task: NSURLSessionDataTask?
    var mutableData: NSMutableData = NSMutableData.init()
    
    override init() {
        super.init()
    }
    
    convenience init(completionHandler: ((NSData?, NSURL?, NSError?) -> Void)?) {
        self.init()
        self.completionHandler = completionHandler
    }
}

class PMImageDownloader: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {

    var session: NSURLSession?
    var imageCache: PMImageCache = PMImageCache.init()
    var taskDelegates: [String:PMSessionDelegate] = [String:PMSessionDelegate]()
    
    
    override init() {
        super.init()
        session = NSURLSession.init(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.init())
    }
    
    class func sharedDownloader() -> PMImageDownloader {
        struct Static {
            static var token: dispatch_once_t = 0
            static var downloader: PMImageDownloader?
        }
        
        dispatch_once(&Static.token) {
            Static.downloader = PMImageDownloader.init()
        }
        
        return Static.downloader!
    }
    
    func downloadImage(url: NSURL, completionHandler: ((image: UIImage?, URL: NSURL?, error: NSError?)->Void)) {
        let urlKey = url.absoluteString
        
        // Check disk
        weak var weakSelf = self
        imageCache.queryImageFromCache(urlKey!) { (image: UIImage?) in
            if let img: UIImage = image {
                if let com: ((image: UIImage?, URL: NSURL?, error: NSError?)->Void) = completionHandler {
                    com(image: img, URL: url,  error: nil)
                }
            }
            
            // Down image
            else {
                let dataTask = weakSelf!.pmDataTaskWithURL(url) { (data: NSData?, _URL: NSURL?, error: NSError?) in
                    var image: UIImage?
                    var error: NSError?
                    if let err = error {
                        error = err
                        print("down error \(err)")
                    }else {
                        if data?.length > 0 {
                            image = UIImage.init(data: data!)
                            // Stroe image
                            weakSelf!.imageCache.storeImage(image!, forKey: urlKey!)
                        }
                    }
                    
                    if let com: ((image: UIImage?, URL: NSURL? ,error: NSError?)->Void) = completionHandler {
                        com(image: image, URL: _URL, error: error)
                    }
                }
                
                dataTask.resume()
            }
        }
        
    }
    
    
    func pmDataTaskWithURL(url: NSURL, completionHandler: (NSData?, NSURL?, NSError?) -> Void) -> NSURLSessionDataTask {
        
        if let delegate = taskDelegates[url.absoluteString!] {
            delegate.completionHandler = completionHandler
            let task = delegate.task!
            return task
        }
        
        let task = self.session!.dataTaskWithURL(url)
        let delegate = PMSessionDelegate.init(completionHandler: completionHandler)
        delegate.task = task
        taskDelegates[url.absoluteString!] = delegate
        
        return task
    }
    
    // MARK: Delegate
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        let delegate = taskDelegates[(dataTask.originalRequest?.URL?.absoluteString)!]
        delegate?.mutableData.appendData(data)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        let delegate = taskDelegates[(task.originalRequest?.URL?.absoluteString)!]
        if let callBack = delegate?.completionHandler {
            dispatch_async(dispatch_get_main_queue(), { 
                callBack(delegate?.mutableData, task.originalRequest?.URL, error)
            })
        }
    }
    
}

var kAssociatedUrl: UInt8 = 0

extension UIImageView {
    
    var currentUrl: String {
        set {
            objc_setAssociatedObject(self, &kAssociatedUrl, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let url = objc_getAssociatedObject(self, &kAssociatedUrl) {
                return url as! String
            }
            return "current_orginal_url"
        }
    }
    
    func pm_setImageWithURL(URL: NSURL, completionHandler:((image: UIImage?, error: NSError?)->Void)?) {
        self.image = nil
        currentUrl = URL.absoluteString!
        let downloader = PMImageDownloader.sharedDownloader()
        downloader.downloadImage(URL) { (image: UIImage?, _URL: NSURL?, error: NSError?) in
            
            guard _URL?.absoluteString == self.currentUrl else {
                return
            }
            
            if let img = image {
                self.image = img
                self.setNeedsLayout()
            }
            
            if let callBack = completionHandler {
                callBack(image: image,error: error)
            }
        }
    }
}
