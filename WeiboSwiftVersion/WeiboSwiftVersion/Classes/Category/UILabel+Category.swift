
//
//  UILabel+Category.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/28.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

extension UILabel {
    class func createLabel(color: UIColor, fontSize: CGFloat) -> UILabel
    {
        let label = UILabel()
        label.textColor = color
        label.font = UIFont.systemFontOfSize(fontSize)
        
        return label
    }
}
