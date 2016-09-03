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
    var photoPickerHeightCons: NSLayoutConstraint?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        //监听键盘改变
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeKeyboardFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        //1将键盘、图片选择器控制器添加为当前控制器子控制器
        addChildViewController(emoticonVC)
        addChildViewController(photoPickerVC)
        
        //初始化导航条
        setupNav()
        
        //初始化输入框
        setupInputView()
        
        //初始化工具条
        setupToolBar()
        
        setupPhotoPicker()
    }
    
    override  func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if photoPickerHeightCons == 0
        {
            //主动显示键盘
            textView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //主动隐藏键盘
        textView.resignFirstResponder()
    }
    
    func changeKeyboardFrame(notify: NSNotification)
    {
//        print(notify)
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
        /*
          工具条回弹是因为执行了两次动画，而系统自带的键盘动画节奏（曲线）是7
          7 在apple API中并没有提供给我们, 但是我们可以使用
          7这种节奏有一个特点: 如果连续执行两次动画, 不管上一次有没有执行完毕, 都会立刻执行下一次
          也就是说上一次可能会被忽略
        
          如果将动画节奏设置为7, 那么动画的时长无论如何都会自动修改为0.5
          UIView动画的本质是核心动画, 所以可以给核心动画设置动画节奏
        */
        // 1.取出键盘的动画节奏
        let curve = notify.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.integerValue
        UIView.animateWithDuration(duration) { () -> Void in
            // 2.设置动画节奏
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
            print(duration)
            
            self.view.layoutIfNeeded()
        }
    }
    
    func clickedCloseBtn()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendStatus()
    {
        let path = "2/statuses/update.json"
        let params = ["access_token": UserAccount.readAccount()!.access_token!, "status": textView.emoticonAttributedText()]
        NetworkTools.shareNetworkTools().POST(path, parameters: params, progress: nil, success: { (_, JSON) -> Void in
            SVProgressHUD.showSuccessWithStatus("发送成功")
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
            self.clickedCloseBtn()
            }) { (_, error) -> Void in
                SVProgressHUD.showErrorWithStatus("发送失败")
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        }
    }
    
    func selectPicture()
    {
        print(__FUNCTION__)
        //关闭键盘
        textView.resignFirstResponder()
        
        //更改图片选择器高度约束
        photoPickerHeightCons?.constant = UIScreen.mainScreen().bounds.height * CGFloat(0.6)
    }
    
    func switchEmoticon()
    {
        print(__FUNCTION__)
        // 结论: 如果是系统自带的键盘, 那么inputView = nil
        //      如果不是系统自带的键盘, 那么inputView != nil
//        print(textView.inputView)
        
        //关闭键盘
        textView.resignFirstResponder()
        
        //切换键盘
        textView.inputView = (textView.inputView == nil) ? emoticonVC.view : nil
        
        //召唤键盘
        textView.becomeFirstResponder()
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
        placeholderLabel.xmg_AlignInner(type: XMG_AlignType.TopLeft, referView: textView, size: nil, offset: CGPoint(x: 5, y: 8))
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
            
            ["imageName": "compose_emoticonbutton_background", "action": "switchEmoticon"],
            
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
    
    private func setupPhotoPicker()
    {
        view.insertSubview(photoPickerVC.view, belowSubview: toolBar)
        
        let width = UIScreen.mainScreen().bounds.width
        let cons = photoPickerVC.view.xmg_AlignInner(type: XMG_AlignType.BottomLeft, referView: view, size: CGSize(width: width, height: 0))
        photoPickerHeightCons = photoPickerVC.view.xmg_Constraint(cons, attribute: NSLayoutAttribute.Height)
    }
    
    //MARK: - 懒加载
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.font = UIFont.systemFontOfSize(15)
        
        return textView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(15)
        label.textColor = UIColor.darkGrayColor()
        label.text = "分享新鲜事..."
        
        return label
    }()
    
    private lazy var toolBar: UIToolbar = UIToolbar()
    
    //weak：相当于OC中__weak，特点对象释放之后会将变量设置为nil, 设用它self需要加！
    //unowned：相当于OC中unsafe_unretained，特点对象释放之后不会将变量设置为nil
    /// 表情键盘
    private lazy var emoticonVC: EmoticonsViewController = EmoticonsViewController { [unowned self] (emoticon) -> () in
        self.textView.insertEmoticon(emoticon)
    }
    
    /// 图片选择器
    private lazy var photoPickerVC: PhotoPickerViewController = PhotoPickerViewController()
}

extension ComposeViewController: UITextViewDelegate
{
    //注意：输入图片表情时不会触发textViewDidChange
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = textView.hasText()
        navigationItem.rightBarButtonItem?.enabled = textView.hasText()
    }
}
