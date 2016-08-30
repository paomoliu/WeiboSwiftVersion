//
//  MainViewController.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/20.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

        addChildViewControllers()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setComposeBtn()
    }
    
    private func setComposeBtn()
    {
        //调整按钮位置
        let width = UIScreen.mainScreen().bounds.size.width / CGFloat(viewControllers!.count)
        let rect = CGRect(x: 0, y: 0, width: width, height: tabBar.bounds.height)
        
        //第一个参数：frame的大小
        //第二个参数：x方向的偏移
        //第三个参数：y方向的偏移
        composeBtn.frame = CGRectOffset(rect, 2 * width, 0)
    }
    
    private func addChildViewControllers()
    {
        //1.获取Json文件路径
        let path = NSBundle.mainBundle().pathForResource("MainVCSettings.json", ofType: nil)
        //2.通过文件路径创建NSData
        if let jsonPath = path
        {
            let jsonData = NSData(contentsOfFile: jsonPath)
            
            do {
                //有可能发生异常的代码放这里
                //3.序列化NSData数据➝Array
                //try:发生异常会跳到catch中继续执行
                //try!:强制try，发生异常程序直接崩溃
                let dictArr = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers)
                
                //4.遍历数据，动态创建控制器和设置数据
                //在Swift中遍历一个数组，必须明确数据类型,[[String: String]]最外层［］说明dictArr是一个数组，数据中的数据是[String: String]类型
                for dict in dictArr as! [[String: String]] {
                    //报错的原因是addChildViewController参数必须有值，但是字典的返回值是可选类型，加！解决
                    addChildViewController(dict["vcName"]!, title: dict["title"]!, imageName: dict["imageName"]!)
                }
            } catch {
                //发生异常之后执行
                print(error)
                
                //从本地加载控制器
                addChildViewController("HomeTableViewController", title: "首页", imageName: "tabbar_home")
                addChildViewController("MessageTableViewController", title: "消息", imageName: "tabbar_message_center")
                //添加一个占位控制器
                addChildViewController("NullViewController", title: "", imageName: "")
                addChildViewController("DiscoverTableViewController", title: "广场", imageName: "tabbar_discover")
                addChildViewController("ProfileTableViewController", title: "我", imageName: "tabbar_profile")
            }
        }
    }
    
    private func addChildViewController(vcName: String, title: String, imageName: String)
    {
//        tabBar.tintColor = UIColor.orangeColor()
        
        //-1.动态获取命名空间（as加！是因为可能info中键取出的空值，加！说明一定有值转化为String）
        let nameSpace = NSBundle.mainBundle().infoDictionary!["CFBundleExecutable"] as! String
        
        //0.将字符串转换为类
        //0.1默认情况命名空间是项目名称，但命名空间可改变，其保存在Info.plist文件的CFBundleExecutable对应的value中
        let cls: AnyClass! = NSClassFromString(nameSpace + "." + vcName)
        //0.2通过类创建对象
        //0.2.1将anyClass转换为指定的类型
        let vcCls = cls as! UIViewController.Type
        //0.2.2通过class创建对象
        let vc = vcCls.init()
        
        vc.title = title
        vc.tabBarItem.image = UIImage(named: imageName)
        vc.tabBarItem.selectedImage = UIImage(named: imageName + "_highlighted")
        let nav = UINavigationController(rootViewController: vc)
        
        addChildViewController(nav)
    }
    
    //MARK: -懒加载
    private lazy var composeBtn: UIButton = {
        let btn = UIButton()
        //前景图
        btn.setImage(UIImage(named: "tabbar_compose_icon_add"), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), forState: UIControlState.Highlighted)
        //背景图
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button"), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), forState: UIControlState.Highlighted)
        
        //添加监听
        btn.addTarget(self, action: "clickedOnComposeBtn", forControlEvents: UIControlEvents.TouchUpInside)
        
        //添加＋按钮，闭包中必须写self，容易引起循环引用
        self.tabBar.addSubview(btn)
        
        return btn
    }()
    
    //注：监听按钮点击的方法不能为私有方法
    //因为按钮点击事件的调用是由运行循环监听并且以消息机制传递的
    func clickedOnComposeBtn()
    {
        print(__FUNCTION__)
    }
}
