//
//  BaseTableViewController.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/21.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController, VisitorViewDelegate
{
    //保存用户当前是否登录
    var userLogin = UserAccount.userLogin()
    //保存未登录视图
    var visitorView: VisitorView?

    override func loadView() {
        userLogin ? super.loadView() : setVisitorView()
    }
    
    private func setVisitorView()
    {
        //1.初始化未登录界面
        let customView = VisitorView()
        customView.delegate = self
        customView.backgroundColor = UIColor(white: 237.0/255.0, alpha: 1.0)
        view = customView
        visitorView = customView
        //2.设置导航栏未登录按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.Plain, target: self, action: "registerBtnClicked")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: UIBarButtonItemStyle.Plain, target: self, action: "loginBtnClicked")
    }
    
    func loginBtnClicked() {        
        //1.弹出登录界面
        let oauthVC = OAuthViewController()
        let nav = UINavigationController(rootViewController: oauthVC)
        presentViewController(nav, animated: true, completion: nil)
    }
    
    func registerBtnClicked() {
        print(__FUNCTION__)
    }
}
