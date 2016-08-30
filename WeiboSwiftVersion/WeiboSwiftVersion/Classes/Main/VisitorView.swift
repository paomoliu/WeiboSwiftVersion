//
//  VisitorView.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/21.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

protocol VisitorViewDelegate: NSObjectProtocol
{
    func loginBtnClicked()
    func registerBtnClicked()
}

class VisitorView: UIView
{
    //定义一个属性保存代理对象
    //一定加weak，避免循环引用
    weak var delegate: VisitorViewDelegate?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupVisitorInfo(isHome: Bool, imageName: String, message: String)
    {
        //不是首页，隐藏转盘
        iconView.hidden = !isHome
        homeIconView.image = UIImage(named: imageName)
        messageLabel.text = message
        
        if isHome
        {
            startAnimation()
        }
    }
    
    func clickedOnLoginBtn()
    {
        delegate?.loginBtnClicked()
    }
    
    func clickedOnRegisterBtn()
    {
        delegate?.registerBtnClicked()
    }
    
    /**
     设置内部控件
     */
    private func setupUI()
    {
        //1.添加子控件
        addSubview(iconView)
        addSubview(maskIconView)
        addSubview(homeIconView)
        addSubview(messageLabel)
        addSubview(loginBtn)
        addSubview(registerBtn)
        //2.布局子控件
        //2.1设置背景图标
        iconView.xmg_AlignInner(type: XMG_AlignType.Center, referView: self, size: nil)
        //2.2设置小房子
        homeIconView.xmg_AlignInner(type: XMG_AlignType.Center, referView: self, size: nil)
        maskIconView.xmg_AlignInner(type: XMG_AlignType.Center, referView: self, size: nil)
        //2.3设置文本
        messageLabel.xmg_AlignVertical(type: XMG_AlignType.BottomCenter, referView: iconView, size: nil)
        let widthCons = NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 224)
        addConstraint(widthCons)
        //2.4设置按钮
        registerBtn.xmg_AlignVertical(type: XMG_AlignType.BottomLeft, referView: messageLabel, size: CGSize(width: 100, height: 35), offset: CGPoint(x: 0, y: 20))
        loginBtn.xmg_AlignVertical(type: XMG_AlignType.BottomRight, referView: messageLabel, size: CGSize(width: 100, height: 35), offset: CGPoint(x: 0, y: 20))
    }
    
    private func startAnimation()
    {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 20
        animation.toValue = 2 * M_PI
        animation.repeatCount = MAXFLOAT
        //该属性默认为YES，代表动画结束就移除
        animation.removedOnCompletion = false
        
        iconView.layer.addAnimation(animation, forKey: nil)
    }
    
    //MARK: - 界面元素懒加载
    /// 转盘
    private lazy var iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
        return iv
    }()
    
    private lazy var homeIconView: UIImageView = {
       let iv = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
        return iv
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "关注一些人，回这里看看有什么惊喜"
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var maskIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))
        return iv
    }()
    
    private lazy var loginBtn: UIButton = {
       let btn = UIButton()
        btn.setTitle("登录", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Normal)
        btn.addTarget(self, action: "clickedOnLoginBtn", forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
    
    private lazy var registerBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("注册", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Normal)
        btn.addTarget(self, action: "clickedOnRegisterBtn", forControlEvents: UIControlEvents.TouchUpInside)
        return btn
    }()
}
