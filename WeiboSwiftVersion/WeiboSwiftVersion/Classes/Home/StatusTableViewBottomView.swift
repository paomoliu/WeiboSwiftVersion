//
//  StatusTableViewBottomView.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/29.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class StatusTableViewBottomView: UIView
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI()
    {
        //1.添加子控件
        addSubview(retweetBtn)
        addSubview(unlinkBtn)
        addSubview(commentBtn)
        backgroundColor = UIColor(white: 0.8, alpha: 0.2)
        
        //2.布局子控件
        xmg_HorizontalTile([retweetBtn, unlinkBtn, commentBtn], insets: UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0))
    }
    
    //MARK: - 懒加载
    /// 转发
    private lazy var retweetBtn: UIButton = UIButton.createButton("timeline_icon_retweet", title: "转发")
    /// 赞
    private lazy var unlinkBtn: UIButton = UIButton.createButton("timeline_icon_unlike", title: "赞")
    /// 评论
    private lazy var commentBtn: UIButton = UIButton.createButton("timeline_icon_comment", title: "评论")
}
