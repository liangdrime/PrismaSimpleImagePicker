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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view.frame = bounds
    }
}
