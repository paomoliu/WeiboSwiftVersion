
//
//  UIColor+Category.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/31.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

extension UIColor {
    class func randomColor() -> UIColor {
        return UIColor(red: randomNumber(), green: randomNumber(), blue: randomNumber(), alpha: 1.0)
    }
    
    class func randomNumber() -> CGFloat {
        //写256是因为该方法不包含尾
        //0 ~ 255
        return CGFloat(arc4random_uniform(256)) / CGFloat(255)
    }
}
