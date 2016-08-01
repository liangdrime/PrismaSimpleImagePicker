//
//  PMStyleHeaderView.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/8/1.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit

class PMStyleHeaderView: UIView {
    
    var imageView = UIImageView.init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubviews()
    }
    
    func configSubviews() {
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.frame = bounds
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    func setImage(image: UIImage) {
        imageView.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
