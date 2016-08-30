//
//  DiscoverTableViewController.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/20.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class DiscoverTableViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if !userLogin
        {
            visitorView?.setupVisitorInfo(false, imageName: "visitordiscover_image_message", message: "登录后，最新、最热微博尽在掌握，不再会与实事潮流擦肩而过")
        }
    }
}
