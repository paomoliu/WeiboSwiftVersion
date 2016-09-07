//
//  AppDelegate.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/20.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

let SwithRootViewControllerKey = "SwithRootViewControllerKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //加载数据库
        SQLiteManager.shareManager().openDB("status.sqlite")
        
        //设置导航栏与工具条外观
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
        UITabBar.appearance().tintColor = UIColor.orangeColor()
        
        //注册一个通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "SwithRootViewController:", name: SwithRootViewControllerKey, object: nil)
        
        //1.创建Window
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        //2.创建根视图控制器
        window?.rootViewController = defalutController()
        //3.显示Window
        window?.makeKeyAndVisible()
        
        return true
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     切换根控制器
     */
    func SwithRootViewController(notification: NSNotification)
    {
        print(notification.object)
        if notification.object as! Bool
        {
            window?.rootViewController = MainViewController()
        } else
        {
            window?.rootViewController = WelcomeViewController()
        }
        
    }
    
    private func defalutController() -> UIViewController
    {
        if UserAccount.userLogin()
        {
            return isNewUpdate() ? NewFeatrueCollectionViewController() : WelcomeViewController()
        }
        
        return MainViewController()
    }
    
    private func isNewUpdate() -> Bool
    {
        //1.获取当前版本号 ---> Info.plist
        let currentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        //2.获取以前版本号 ---> 从本地存储中读取（以前存储的）
        //？？的作用是如果前面为nil，则将值变为""
        let sandBoxVersion = NSUserDefaults.standardUserDefaults().valueForKey("CFBundleShortVersionString") as? String ?? ""
        //3.比较两个版本号
        //    2.0                    1.0  ---> 降序
        if currentVersion.compare(sandBoxVersion) == NSComparisonResult.OrderedDescending
        {
            //3.1当前版本 > 以前版本 ---> 有更新
            //3.1.1存储当前最新版本号
            NSUserDefaults.standardUserDefaults().setValue(currentVersion, forKey: "CFBundleShortVersionString")
            
            return true
        }
        
        //3.2当前版本 < | == 以前版本 ---> 无更新
        return false
    }
}

