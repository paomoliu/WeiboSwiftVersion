//
//  StatusRetweetTableViewCell.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/30.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class StatusRetweetTableViewCell: StatusTableViewCell
{
    //重写父类属性的didSet并不会覆盖父类的操作
    //只需要在重写方法中，做自己想做的事即可
    //注意点：如果父类是didSet，那么子类重写也只能重写didSet
    override var status: Status? {
        didSet {
            let name = status?.retweeted_status?.user?.name ?? ""
            let text = status?.retweeted_status?.text ?? ""
            retweetContentLabel.text = "@" + name + ": " + text
        }
    }
    
    override func setupUI() {
        super.setupUI()
        //1.添加子控件
        contentView.insertSubview(retweetBg, belowSubview: pictureView)
        contentView.insertSubview(retweetContentLabel, aboveSubview: retweetBg)
        
        //2.布局子控件
        //2.1布局转发背景视图
        retweetBg.xmg_AlignVertical(type: XMG_AlignType.BottomLeft, referView: contentLabel, size: nil, offset: CGPoint(x: -10, y: 10))
        retweetBg.xmg_AlignVertical(type: XMG_AlignType.TopRight, referView: tools, size: nil)
        
        //2.2布局转发正文
        retweetContentLabel.xmg_AlignInner(type: XMG_AlignType.TopLeft, referView: retweetBg, size: nil, offset: CGPoint(x: 10, y: 10))
        
        //2.3重新调整配图布局
        let cons = pictureView.xmg_AlignVertical(type: XMG_AlignType.BottomLeft, referView: retweetContentLabel, size: CGSizeZero, offset: CGPoint(x: 0, y: 10))
        pictureWidthCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.Width)
        pictureHeightCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.Height)
        pictureTopCons = pictureView.xmg_Constraint(cons, attribute: NSLayoutAttribute.Top)
    }
    
    //MARK: - 懒加载
    /// 转发正文
    private lazy var retweetContentLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.darkGrayColor(), fontSize: 15)
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 20
        
        return label
    }()
    
    private lazy var retweetBg: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        return btn
    }()
}
