//
//  PMImageCache.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/8/5.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import Compression

class PMImageCache: NSObject {

    let imageCache: NSCache = NSCache.init()
    var diskPath: String?
    let fileManager: NSFileManager = NSFileManager.defaultManager()
    
    override init() {
        super.init()
        self.diskPath = defaultDiskPath()
    }
    
    func storeImage(image: UIImage, forKey: String) {
        let path = defaultCachePathForKey(forKey)
        if !fileManager.isExecutableFileAtPath(diskPath!) {
            try! fileManager.createDirectoryAtPath(diskPath!, withIntermediateDirectories: true, attributes: nil)
        }
        
        imageCache.setObject(image, forKey: forKey, cost: Int(image.size.height * image.size.width * image.scale * image.scale))
        fileManager.createFileAtPath(path, contents: UIImageJPEGRepresentation(image, 1.0), attributes: nil)
    }
    
    func queryImageFromCache(key: String, doneBlock: ((image: UIImage?)->Void)?) {
        
        var image: UIImage?
        
        if let cacheImage = self.imageCache.objectForKey(key) {
            image = cacheImage as? UIImage
            if let done = doneBlock {
                done(image: image)
            }
        }else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let path = self.defaultCachePathForKey(key)
                if self.fileManager.isExecutableFileAtPath(path) {
                    let data = NSData.init(contentsOfFile: path)
                    image = UIImage.init(data: data!)
                }
                
                if let done = doneBlock {
                    dispatch_async(dispatch_get_main_queue(), { 
                        done(image: image)
                    })
                }
            }
            
        }
    }
    
    func defaultDiskPath() -> String {
        var path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, .UserDomainMask, true)
        let diskDir: NSString = path[0]
        let diskPath = diskDir.stringByAppendingPathComponent("com.PMImageSimplePicker.PMImageCache")
        return diskPath
    }
    
    func defaultCachePathForKey(key: String) -> String {
        let path = (diskPath! as NSString).stringByAppendingPathComponent(key)
        return path
    }
    
}
