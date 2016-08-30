//
//  ProfileTableViewController.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/20.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class ProfileTableViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if !userLogin
        {
            visitorView?.setupVisitorInfo(false, imageName: "visitordiscover_image_profile", message: "登录后，你的微博、相册、个人资料会显示在这里，展示给别人")
        }
    }
}
