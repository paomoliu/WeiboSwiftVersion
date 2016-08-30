//
//  TitleButton.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/21.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class TitleButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTitle("paomoliu ", forState: UIControlState.Normal)
        setImage(UIImage(named: "navigationbar_arrow_down"), forState: UIControlState.Normal)
        setImage(UIImage(named: "navigationbar_arrow_up"), forState: UIControlState.Selected)
        setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        sizeToFit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.frame.origin.x = 0
        imageView?.frame.origin.x = titleLabel!.frame.size.width
    }
}
