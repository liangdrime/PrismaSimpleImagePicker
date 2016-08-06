//
//  PMStyleCell.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/8/1.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit

class PMStyleCell: UICollectionViewCell {
    
    @IBOutlet weak var styleImageView: UIImageView!
    @IBOutlet weak var styleNameLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view.frame = bounds
    }
    
    func loadImage(data: AnyObject) {
        // Loading
        indicator.hidden = false
        indicator.startAnimating()
        
        // Ttile
        let title: String = data.objectForKey("artwork")! as! String
        self.styleNameLabel.text = title
        
        // Download image
        let URL: NSURL = NSURL.init(string: data.objectForKey("image_url")! as! String)!
        styleImageView.pm_setImageWithURL(URL) { (image: UIImage?, error: NSError?) in
            self.indicator.stopAnimating()
            self.indicator.hidden = true
        }
    }
}
