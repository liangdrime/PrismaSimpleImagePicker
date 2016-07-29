//
//  PMImageGroupModel.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/25.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import Photos

class PMImageGroupModel: NSObject {
    
    var image: UIImage?
    var title: String?
    var content: String?
    
    override init() {
        super.init()
    }
    
    convenience init(image: UIImage?, title: String?, content: String?) {
        self.init()
        self.image = image
        self.title = title
        self.content = content
    }
    
    class func groupModelFromPHAssetCollection(collection: PHAssetCollection) -> PMImageGroupModel {
        
        var image: UIImage? = nil
        let title = collection.localizedTitle
        let content = collection.photosCount
        
        let assets: PHFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
        let asset = assets.firstObject as? PHAsset
        
        let options = PHImageRequestOptions()
        options.synchronous = true
        options.resizeMode = .Fast
        options.deliveryMode = .FastFormat
        
        if let _asset = asset {
            let size: CGSize = CGSizeMake(150, 150)
            PHImageManager.defaultManager().requestImageForAsset(_asset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: options) { (_image: UIImage?, info: [NSObject : AnyObject]?) in
                image = _image
            }
        }
        
        let model = PMImageGroupModel.init(image: image, title: title, content: String(content))
        return model
    }
}


extension PHAssetCollection {
    var photosCount: Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)
        let result = PHAsset.fetchAssetsInAssetCollection(self, options: fetchOptions)
        return result.count
    }
}
