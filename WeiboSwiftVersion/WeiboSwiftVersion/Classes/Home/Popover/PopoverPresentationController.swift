//
//  PopoverPresentationController.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/22.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class PopoverPresentationController: UIPresentationController {
    /// 保存弹出视图的大小
    var presentFrame = CGRectZero
    
    /**
     初始化方法，用于创建负责转场动画的对象
     
     - parameter presentedViewController:  被展现的控制器－>弹出视图控制器
     - parameter presentingViewController: 发起的控制器－>首页视图控制器，Xcode6中是nil，Xcode 7是野指针
     
     - returns: 负责转场动画的对象
     */
    override init(presentedViewController: UIViewController, presentingViewController: UIViewController)
    {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        print(presentedViewController)
//        print(presentingViewController)
    }
    
    /**
     即将布局转场子视图时调用
     */
    override func containerViewWillLayoutSubviews()
    {
        //1.修改弹出视图的大小
//        containerView 容器视图
//        presentedView() 弹出视图
        if presentFrame == CGRectZero
        {
            presentedView()?.frame = CGRect(x: 100, y: 56, width: 200, height: 300)
        } else
        {
            presentedView()?.frame = presentFrame
        }
        
        
        //2.在容器视图上添加一个蒙板，插入到展示视图下面
        //因为展示视图和蒙板在同一视图上，而后添加的视图会盖住先添加的
        containerView?.insertSubview(coverView, atIndex: 0)
    }
    
    private lazy var coverView: UIView = {
        //创建view
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        view.frame = UIScreen.mainScreen().bounds
        
        //添加监听
        let tap = UITapGestureRecognizer(target: self, action: "close")
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    func close()
    {
        print(__FUNCTION__)
        presentedViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
