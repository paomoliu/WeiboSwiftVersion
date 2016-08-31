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
        
        //1.设置导航栏
        setNav()
        
        //2.注册通知，监听菜单
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "change", name: kVCWillShow, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "change", name: kVCWillDismiss, object: nil)
        
        //3.注册两个cell
        tableView.registerClass(StatusRetweetTableViewCell.self, forCellReuseIdentifier: StatusTableViewCellIdentifier.RetWeetCellID.rawValue)
        tableView.registerClass(StatusNormalTableViewCell.self, forCellReuseIdentifier: StatusTableViewCellIdentifier.NormalCellID.rawValue)
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 200
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //4.添加下拉刷新
        //UIRefreshControl -> UIControl -> UIView
        /*refreshControl = UIRefreshControl()
        let refreshView = UIView();
        refreshView.frame = CGRect(x: 0, y: 0, width: 375, height: 60)
        refreshView.backgroundColor = UIColor.greenColor()
        refreshControl?.addSubview(refreshView)
        refreshControl?.endRefreshing()*/
        refreshControl = HomeRefreshControl()
        refreshControl?.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)

        //5.加载微博数据
        loadData()
    }
    
    deinit
    {
        //移除通知
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //记录是否是下拉加载更多
    var pullDownFlag = false
    /**
     获取微博数据
     如果想要调用一个私有的方法：
     1.去掉private
     2.加@objc，当作OC方法来处理
     */
    func loadData()
    {
        /*
        1.默认最新返回20条数据
        2.since_id : 会返回比since_id大的微博
        3.max_id: 会返回小于等于max_id的微博

        每条微博都有一个微博ID, 而且微博ID越后面发送的微博, 它的微博ID越大
        递增

        新浪返回给我们的微博数据, 是从大到小的返回给我们的
        */
        
        // 1.默认当做下拉处理
        var since_id = models?.first!.id ?? 0
        var max_id = 0
        
        // 2.判断是否是上拉
        if pullDownFlag
        {
            since_id = 0
            max_id = models?.last?.id ?? 0
            //重置变量值
            //问题？pullDownFlag无重置值为false，如果用户加载更多后又返回头部刷新，就会出现依旧是加载更多而并非刷新的情况
            pullDownFlag = false
        }
        Status.loadStatuses(since_id, max_id: max_id) { (models, error) -> () in
            //结束刷新动画
            self.refreshControl?.endRefreshing()
            
            if error != nil
            {
                return
            }
            
            if since_id > 0
            {
                //由于下拉刷新时，传递since_id参数获取回来的数据是比since_id大的微博，所以需要拼接在原始数据前面
                self.models = models! + self.models!
                
                //显示刷新提示
                self.showRefreshCount((models?.count) ?? 0)
            } else if max_id > 0
            {
                // 如果是上拉加载更多, 就将获取到的数据, 拼接在原有数据的后面
                self.models = self.models! + models!
            } else
            {
                self.models = models
            }
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
    
    private func showRefreshCount(count: Int)
    {
        refreshWarnLabel.hidden = false
        refreshWarnLabel.text = count == 0 ? "没有刷新到新微博" : "\(count)条新微博"
        
        UIView.animateWithDuration(3, animations: { () -> Void in
            self.refreshWarnLabel.transform = CGAffineTransformMakeTranslation(0, self.refreshWarnLabel.frame.height)
            }) { (_) -> Void in
                UIView.animateWithDuration(3, animations: { () -> Void in
                    self.refreshWarnLabel.transform = CGAffineTransformIdentity
                    }, completion: { (_) -> Void in
                        self.refreshWarnLabel.hidden = true
                })
        }
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
    
    //MARK: - 懒加载
    //一定要定义一个属性来保存自定义转场对象，否则会报错
    private lazy var popoverAnimation: PopoverAnimation = {
        let pa = PopoverAnimation()
        pa.presentFrame = CGRect(x: 100, y: 56, width: 200, height: 350)
        
        return pa
    }()
    
    private lazy var refreshWarnLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 14, width: UIScreen.mainScreen().bounds.width, height: 30)
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(12)
        label.backgroundColor = UIColor(red: 250.0/255.0, green: 127.0/255.0, blue: 0.0, alpha: 0.8)
        label.hidden = true
        
        // 加载 navBar 上面，不会随着 tableView 一起滚动
        self.navigationController?.navigationBar.insertSubview(label, atIndex: 0)
        
        return label
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
        print("models?.count ======= \(models?.count)")
        return models?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let status = models![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(StatusTableViewCellIdentifier.cellID(status), forIndexPath: indexPath) as! StatusTableViewCell
//        cell.textLabel?.text = status.text
        cell.status = status
        
        //判断是否是最后一个cell
        let count = models?.count ?? 0
        if indexPath.row == count - 1
        {
            pullDownFlag = true
            //下拉加载更多
            loadData()
        }
        
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
