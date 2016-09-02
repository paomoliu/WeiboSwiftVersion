//
//  HomeRefreshControl.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/30.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class HomeRefreshControl: UIRefreshControl
{
    override init()
    {
        super.init()
        
        setupUI()
    }
    
    private func setupUI()
    {
        //1.添加子控件
        addSubview(refreshView)
        
        //2.布局子控件
        refreshView.xmg_AlignInner(type: XMG_AlignType.Center, referView: self, size: CGSize(width: 100, height: 60))
        
        /*
        1.当用户下拉到一定程度时需要旋转箭头
        2.当用户上推到一定程度时需要旋转箭头
        3.当下拉刷新控件触发刷新方法的时候，需要显示刷新界面（转轮）
        
        通过观察：
            越往下拉，值越小
            越往上推，值越大
        */
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    //定义变量记录是否需要旋转监听
    private var rotationArrowFlag = false
    //定义变量记录是否正在刷新，防止刷新动画未结束前添加多个刷新动画
    private var refreshingFlag = false
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        //过滤掉不需要的数据
        if frame.origin.y >= 0
        {
            return
        }
        
        //判断是否触发刷新时间
        if refreshing && !refreshingFlag
        {
            refreshingFlag = true
            refreshView.startLoadingAnimation()
            
            return
        }
        
        if frame.origin.y >= -50  && rotationArrowFlag
        {
            print("翻回来")
            rotationArrowFlag = false
            refreshView.rotationAnimation(rotationArrowFlag)
        } else if frame.origin.y < -50 && !rotationArrowFlag
        {
            print("翻转")
            rotationArrowFlag = true
            refreshView.rotationAnimation(rotationArrowFlag)
        }
    }
    
    /**
     重写结束刷新动画
     */
    override func endRefreshing() {
        super.endRefreshing()
        
        //关闭刷新动画
        refreshView.stopLoadingAnimation()
        refreshingFlag = false
    }
    
    //MARK: - 懒加载
    private lazy var refreshView: HomeRefreshView = HomeRefreshView.refreshView()
    
    deinit
    {
        removeObserver(self, forKeyPath: "frame")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomeRefreshView: UIView

{
    @IBOutlet weak var arrowIcon: UIImageView!
    @IBOutlet weak var loadingIcon: UIImageView!
    @IBOutlet weak var unrefreshLabel: UILabel!
    @IBOutlet weak var tipView: UIView!
    
    class func refreshView() -> HomeRefreshView
    {
        return NSBundle.mainBundle().loadNibNamed("HomeRefreshView", owner: nil, options: nil).last as! HomeRefreshView
    }
    
    /**
     箭头旋转动画
     */
    private func rotationAnimation(flag: Bool)
    {
        /*
        1.默认顺时针刷新
        2.按照就近原则刷新
        */
        var angle = M_PI
        angle += flag ? -0.01 : 0.01
        
        UIView.animateWithDuration(0.2) { () -> Void in
            self.arrowIcon.transform = CGAffineTransformRotate(self.arrowIcon.transform, CGFloat(angle))
            
            if flag == false
            {
                self.unrefreshLabel.text = "下拉刷新"
            } else
            {
                self.unrefreshLabel.text = "释放更新"
            }
        }
    }
    
    /**
     开始刷新动画
     */
    private func startLoadingAnimation()
    {
        tipView.hidden = true
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 1
        animation.toValue = 2 * M_PI
        animation.repeatCount = MAXFLOAT
        //该属性默认为YES，代表动画结束就移除
        animation.removedOnCompletion = false
        
        loadingIcon.layer.addAnimation(animation, forKey: nil)
    }
    
    /**
     停止刷新动画
     */
    private func stopLoadingAnimation()
    {
        tipView.hidden = false
        loadingIcon.layer.removeAllAnimations()
    }
}
