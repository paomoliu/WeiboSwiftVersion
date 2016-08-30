
//
//  UIButton+Category.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/28.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

extension UIButton
{
    class func createButton(imageName: String, title: String) -> UIButton {
        let btn = UIButton()
        btn.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "timeline_card_bottom_background"), forState: UIControlState.Normal)
        btn.setTitle(title, forState: UIControlState.Normal)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        btn.titleLabel?.font = UIFont.systemFontOfSize(12)
        btn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        
        return btn
    }
}

