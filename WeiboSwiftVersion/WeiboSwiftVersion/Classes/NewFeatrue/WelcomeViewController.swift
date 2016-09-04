//
//  WelcomeViewController.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/26.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit
import SDWebImage

class WelcomeViewController: UIViewController {
    
    private var avatarBottomCons: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        //设置用户头像
        if let avatarUrl = UserAccount.readAccount()?.avatar_large
        {
            let url = NSURL(string: avatarUrl)
            avatarView.sd_setImageWithURL(url)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //修改头像约束
        avatarBottomCons?.constant = -UIScreen.mainScreen().bounds.height - avatarBottomCons!.constant
//        print(-UIScreen.mainScreen().bounds.height)
//        print(avatarBottomCons!.constant)
//        print(-UIScreen.mainScreen().bounds.height - avatarBottomCons!.constant)
        
        //执行动画
        UIView.animateWithDuration(1.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            //强制更新约束
            self.view.layoutIfNeeded()
            }) { (_) -> Void in
                //执行文本动画
                UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
                    self.message.alpha = 1.0
                    }, completion: { (_) -> Void in
                        print("OK")
                        
                        //去主页
                        NSNotificationCenter.defaultCenter().postNotificationName(SwithRootViewControllerKey, object: true)
                })
        }
    }
    
    private func setupUI()
    {
        //1.添加子控件
        view.addSubview(bgImageView)
        view.addSubview(avatarView)
        view.addSubview(message)
        
        //2.设置子控件布局
        bgImageView.xmg_Fill(view)
        
        let cons = avatarView.xmg_AlignInner(type: XMG_AlignType.BottomCenter, referView: view, size: CGSize(width: 100, height: 100), offset: CGPoint(x: 0, y: -200))
        //拿到头像的底部约束
        avatarBottomCons = avatarView.xmg_Constraint(cons, attribute: NSLayoutAttribute.Bottom)
        
        message.xmg_AlignVertical(type: XMG_AlignType.BottomCenter, referView: avatarView, size: nil, offset: CGPoint(x: 0, y: 20))
    }
    
    //MARK: - 懒加载
    private lazy var bgImageView: UIImageView = UIImageView(image: UIImage(named: "ad_background"))
    
    private lazy var avatarView: UIImageView = {
        let avatar = UIImageView(image: UIImage(named: "avatar_default_big"))
        avatar.layer.cornerRadius = 50
        avatar.layer.masksToBounds = true
        
        return avatar
    }()
    
    private lazy var message: UILabel = {
        let messageLabel = UILabel()
        messageLabel.text = "欢迎回来"
        messageLabel.alpha = 0.0
        messageLabel.sizeToFit()
        
        return messageLabel
    }()
}
