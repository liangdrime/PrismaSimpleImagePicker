//
//  PMImageGroupCell.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/25.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import Photos

class PMImageGroupCell: UITableViewCell {
    
    
    @IBOutlet weak var groupCover: UIImageView!
    @IBOutlet weak var groupTitle: UILabel!
    @IBOutlet weak var groupContent: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectedBackgroundView = UIView.init(frame: self.bounds)
        selectedBackgroundView!.backgroundColor = UIColor.init(white: 0.85, alpha: 1)
    }
    
    func configGroupCell(group : PMImageGroupModel) {
        groupCover.image = group.image
        groupTitle.text = group.title
        groupContent.text = group.content
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
