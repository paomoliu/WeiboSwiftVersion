//
//  HomeTableViewController.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/20.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class HomeTableViewController: BaseTableViewController {
    
    /// 保存微博数组
    var models: [Status]? {
        didSet {
            //当设置完数据，刷新表格
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !userLogin
        {
            visitorView?.setupVisitorInfo(true, imageName: "visitordiscover_feed_image_house", message: "关注一些人，回这里看看有什么惊喜")
            return
        }
        
        setNav()
        
        //注册通知，监听菜单
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "change", name: kVCWillShow, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "change", name: kVCWillDismiss, object: nil)
        
        //注册两个cell
        tableView.registerClass(StatusRetweetTableViewCell.self, forCellReuseIdentifier: StatusTableViewCellIdentifier.RetWeetCellID.rawValue)
        tableView.registerClass(StatusNormalTableViewCell.self, forCellReuseIdentifier: StatusTableViewCellIdentifier.NormalCellID.rawValue)
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 200
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        //4.加载微博数据
        loadData()
    }
    
    deinit
    {
        //移除通知
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     获取微博数据
     */
    private func loadData()
    {
        Status.loadStatuses { (models, error) -> () in
            if error != nil
            {
                return
            }
            
            self.models = models
        }
    }
    
    func leftBtnClicked()
    {
        print(__FUNCTION__)
    }
    
    func rightBtnClicked()
    {
        print(__FUNCTION__)
        let storyboard = UIStoryboard(name: "QRCode", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        presentViewController(vc!, animated: true, completion: nil)
    }
    
    func change()
    {
        //修改标题按钮的状态
        let titleBtn = navigationItem.titleView as! TitleButton
        titleBtn.selected = !titleBtn.selected
        
    }
    
    func titleBtnClicked(btn: TitleButton)
    {
        //1.修改箭头方向
//        btn.selected = !btn.selected
        
        //2.弹出菜单
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        let popoverVC = storyboard.instantiateInitialViewController()
        //自定义转场首先需进行下面两步
        //2.1设置转场代理
        //默认情况下model会移除以前控制器的view，替换为当前弹出的view，如果自定义转场，那么就不会移除以前控制器的view
//        popoverVC?.transitioningDelegate = self
        popoverVC?.transitioningDelegate = popoverAnimation
        //2.2设置转场样式
        popoverVC?.modalPresentationStyle = UIModalPresentationStyle.Custom
        presentViewController(popoverVC!, animated: true, completion: nil)
    }
    
    private func setNav()
    {
        //1.初始化左右按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem.createBarButtonItem("navigationbar_friendattention", target: self, action: "leftBtnClicked")
        navigationItem.rightBarButtonItem = UIBarButtonItem.createBarButtonItem("navigationbar_pop", target: self, action: "rightBtnClicked")
        
        //2.初始化标题按钮
        let btn = TitleButton()
        btn.addTarget(self, action: "titleBtnClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.titleView = btn
    }
    
//    private func createBarButtonItem(imageName: String, target: AnyObject?, action: Selector) -> UIBarButtonItem
//    {
//        let btn = UIButton ()
//        btn.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
//        btn.setImage(UIImage(named: imageName + "_highlighted"), forState: UIControlState.Highlighted)
//        btn.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
//        btn.sizeToFit()
//        
//        return UIBarButtonItem(customView: btn)
//    }
    
    //一定要定义一个属性来保存自定义转场对象，否则会报错
    private lazy var popoverAnimation: PopoverAnimation = {
        let pa = PopoverAnimation()
        pa.presentFrame = CGRect(x: 100, y: 56, width: 200, height: 350)
        return pa
    }()
    
    /// 微博行高的缓存，利用字典作为容器，key就是微博的id，值对应行高
    /// 也可以使用NSCache类来进行缓存，这里采用自己的方式
    var rowHeightCache: [Int: CGFloat] = [Int: CGFloat]()
    
    override func didReceiveMemoryWarning() {
        //收到内存警告通知时，清空缓存
        rowHeightCache.removeAll()
    }
}

extension HomeTableViewController
{
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let status = models![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(StatusTableViewCellIdentifier.cellID(status), forIndexPath: indexPath) as! StatusTableViewCell
//        cell.textLabel?.text = status.text
        cell.status = status
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //1.取出对应行的模型
        let status = models![indexPath.row]
        
        //2.判断缓存中是否有对应行行高
        if let height = rowHeightCache[status.id]
        {
//            print("从缓存中读取")
            return height
        }
        
        //3.拿到cell
        let cell = tableView.dequeueReusableCellWithIdentifier(StatusTableViewCellIdentifier.cellID(status)) as! StatusTableViewCell
        //注意点：不要使用下面的方法获取cell，在某些版本会有bug
//        tableView.dequeueReusableCellWithIdentifier(<#T##identifier: String##String#>, forIndexPath: <#T##NSIndexPath#>)
        
//        print("计算行高")
        //4.拿到对应行的行高
        let rowHeight = cell.rowHeight(status)
        
        //5.将行高进行缓存
        rowHeightCache[status.id] = rowHeight
        
        //返回行高
        return rowHeight
    }
}
