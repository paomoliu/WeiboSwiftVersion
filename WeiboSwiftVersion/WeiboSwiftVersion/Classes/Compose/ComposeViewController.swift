//
//  ComposeViewController.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/9/1.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit
import SVProgressHUD

class ComposeViewController: UIViewController
{
    //工具条底部约束
    var toolBarBottomCons: NSLayoutConstraint?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        //监听键盘改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeKeyboardFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        //初始化导航条
        setupNav()
        
        //初始化输入框
        setupInputView()
        
        //初始化工具条
        setupToolBar()
    }
    
    override  func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //主动显示键盘
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //主动隐藏键盘
        textView.resignFirstResponder()
    }
    
    func changeKeyboardFrame(notify: NSNotification)
    {
        print(notify)
        // 取出键盘最终的rect
        let value = notify.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        
        // 修改工具条的约束
        // 弹出 : Y = 409 height = 258
        // 关闭 : Y = 667 height = 258
        // 667 - 409 = 258
        // 667 - 667 = 0
        let height = UIScreen.mainScreen().bounds.height
        toolBarBottomCons?.constant = -(height - value.origin.y)
        
        //更新界面
        let duration = notify.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        UIView.animateWithDuration(duration) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupNav()
    {
        //添加取消按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "clickedCloseBtn")
        
        //添加发送按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: UIBarButtonItemStyle.Plain, target: self, action: "sendStatus")
        navigationItem.rightBarButtonItem?.enabled = false
        
        //添加中间视图
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 35)
        let topLabel = UILabel()
        topLabel.text = "发微博"
        topLabel.font = UIFont.systemFontOfSize(15)
//        topLabel.textAlignment = NSTextAlignment.Center
        topLabel.sizeToFit()
        titleView.addSubview(topLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = UserAccount.readAccount()?.screen_name
        nameLabel.font = UIFont.systemFontOfSize(13)
//        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.sizeToFit()
        titleView.addSubview(nameLabel)
        
        topLabel.xmg_AlignInner(type: XMG_AlignType.TopCenter, referView: titleView, size: nil)
        nameLabel.xmg_AlignInner(type: XMG_AlignType.BottomCenter, referView: titleView, size: nil)
        
        navigationItem.titleView = titleView
    }
    
    private func setupInputView()
    {
        view.addSubview(textView)
        textView.addSubview(placeholderLabel)
        //允许拖拽
        textView.alwaysBounceVertical = true
        //拖拽移除键盘
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        textView.xmg_Fill(view)
        placeholderLabel.xmg_AlignInner(type: XMG_AlignType.TopLeft, referView: textView, size: nil, offset: CGPoint(x: 5, y: 6))
    }
    
    private func setupToolBar()
    {
        //添加子控件
        view.addSubview(toolBar)
        
        //添加按钮
        var items = [UIBarButtonItem]()
        let itemSettings = [["imageName": "compose_toolbar_picture", "action": "selectPicture"],
            
            ["imageName": "compose_mentionbutton_background"],
            
            ["imageName": "compose_trendbutton_background"],
            
            ["imageName": "compose_emoticonbutton_background", "action": "inputEmoticon"],
            
            ["imageName": "compose_addbutton_background"]]
        for dict in itemSettings
        {
            let item = UIBarButtonItem(imageName: dict["imageName"]!, target: self, action: dict["action"])
            items.append(item)
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        toolBar.items = items
        
        //布局toolBar
        let width = UIScreen.mainScreen().bounds.width
        let cons = toolBar.xmg_AlignInner(type: XMG_AlignType.BottomLeft, referView: view, size: CGSize(width: width, height: 44))
        toolBarBottomCons = toolBar.xmg_Constraint(cons, attribute: NSLayoutAttribute.Bottom)
    }
    
    func clickedCloseBtn()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendStatus()
    {
        let path = "2/statuses/update.json"
        let params = ["access_token": UserAccount.readAccount()?.access_token, "status": textView.text]
        NetworkTools.shareNetworkTools().POST(path, parameters: params, progress: nil, success: { (_, JSON) -> Void in
            SVProgressHUD.showSuccessWithStatus("发送成功")
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
            self.clickedCloseBtn()
            }) { (_, error) -> Void in
            SVProgressHUD.showErrorWithStatus("发送失败")
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        }
    }
    
    //MARK: - 懒加载
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        
        return textView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(13)
        label.textColor = UIColor.darkGrayColor()
        label.text = "分享新鲜事..."
        
        return label
    }()
    
    private lazy var toolBar: UIToolbar = UIToolbar()
}

extension ComposeViewController: UITextViewDelegate
{
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = textView.hasText()
        navigationItem.rightBarButtonItem?.enabled = textView.hasText()
    }
}
