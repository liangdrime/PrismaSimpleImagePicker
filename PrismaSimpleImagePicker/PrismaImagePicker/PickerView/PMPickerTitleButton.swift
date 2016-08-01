//
//  PMPickerTitleButton.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/25.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit

enum ArrowStatus {
    case up
    case down
}

class PMPickerTitleButton: UIButton {
    
    var arrowStatus: ArrowStatus = .down
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        var rect = contentRect
        rect.size.width -= contentRect.size.height
        return rect
    }
    
    override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
        var rect = contentRect
        rect.size.width = contentRect.size.height
        rect.origin.x = CGRectGetWidth(contentRect) - CGRectGetWidth(rect)
        return rect
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
