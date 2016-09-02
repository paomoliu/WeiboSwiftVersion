//
//  UIBarButtonItem+Category.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/21.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    //class相当于OC中的＋ －> 类方法
    class func createBarButtonItem(imageName: String, target: AnyObject?, action: Selector) -> UIBarButtonItem
    {
        let btn = UIButton ()
        btn.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: imageName + "_highlighted"), forState: UIControlState.Highlighted)
        btn.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        btn.sizeToFit()
        
        return UIBarButtonItem(customView: btn)
    }
    
    convenience init(imageName: String, target: AnyObject?, action: String?) {
        let btn = UIButton ()
        btn.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: imageName + "_highlighted"), forState: UIControlState.Highlighted)
        
        if action != nil
        {
            btn.addTarget(target, action: Selector(action!), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        btn.sizeToFit()
        
        self.init(customView: btn)
    }
}
