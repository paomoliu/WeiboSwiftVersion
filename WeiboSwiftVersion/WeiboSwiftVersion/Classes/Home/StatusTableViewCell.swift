//
//  StatusTableViewCell.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/28.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit
import SDWebImage

let kPictrueViewReuseIdentifier = "kPictrueViewReuseIdentifier"

/**
 保存cell的重用标识
 
 - RetWeetCellID: 转发微博的重用标识
 - NormalCellID:  原创微博的重用标识
 */
enum StatusTableViewCellIdentifier: String
{
    case RetWeetCellID = "kHomeRetWeetReuseIdentifier"
    case NormalCellID = "kHomeNormalReuseIdentifier"
    
    //如果在枚举中利用static修饰一个方法，相当于类中的class修饰方法
    //如果调用枚举值的rawValue，那么意味着拿到枚举对应的原始值
    static func cellID(status: Status) -> String
    {
        return status.retweeted_status != nil ? RetWeetCellID.rawValue : NormalCellID.rawValue
    }
}

class StatusTableViewCell: UITableViewCell {
    /// 保存配图宽度约束
    var pictureWidthCons: NSLayoutConstraint?
    /// 保存配图高度约束
    var pictureHeightCons: NSLayoutConstraint?
    /// 保存配图顶部约束
    var pictureTopCons: NSLayoutConstraint?
    
    var status: Status? {
        didSet {
            //设置顶部视图模型
            topView.status = status
            //设置正文
//            contentLabel.text = status?.text
            contentLabel.attributedText = EmoticonPackage.attributedTextWithText(status?.text ?? "")
            //设置配图模型
            pictureView.status = status?.retweeted_status != nil ? status?.retweeted_status : status 
            
            //设置配图的尺寸
            //1.1根据模型计算配图的尺寸
            let size = pictureView.calulateImageSize()
            //1.2设置配图的尺寸
            pictureWidthCons?.constant = size.width
            pictureHeightCons?.constant = size.height
            pictureTopCons?.constant = size.height == 0 ? 0 : 10
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //设置子控件
        setupUI()
    }
    
    func setupUI()
    {
        //1.添加子控件
        contentView.addSubview(topView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(pictureView)
        contentView.addSubview(tools)
        
        //2.布局子控件
        let screenWidth = UIScreen.mainScreen().bounds.width
        topView.xmg_AlignInner(type: XMG_AlignType.TopLeft, referView: contentView, size: CGSize(width: screenWidth, height: 60))
        contentLabel.xmg_AlignVertical(type: XMG_AlignType.BottomLeft, referView: topView, size: nil, offset: CGPoint(x: 10, y: 10))
        
        tools.xmg_AlignVertical(type: XMG_AlignType.BottomLeft, referView: pictureView, size: CGSize(width: screenWidth, height: 50), offset: CGPoint(x: -10, y: 10))
        
        // 添加一个底部约束
        // TODO: 这个地方是有问题的
//        tools.xmg_AlignInner(type: XMG_AlignType.BottomRight, referView: contentView, size: nil, offset: CGPoint(x: 0, y: 0))
    }
    
    /**
     用户获取行高
     */
    func rowHeight(status: Status) -> CGFloat
    {
        //1.为了调用didSet，计算配图的高度
        self.status = status
        
        //2.强制更新界面
        self.layoutIfNeeded()
        
        //3.返回底部视图最大的Y值
        return CGRectGetMaxY(tools.frame)
    }

    //MARK: - 懒加载
    /// 头部视图
    private lazy var topView: StatusTableViewTopView = StatusTableViewTopView()
    /// 正文
    lazy var contentLabel: UILabel = {
        let label = UILabel.createLabel(UIColor.darkGrayColor(), fontSize: 15)
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 20
        
        return label
    }()
    /// 配图
    lazy var pictureView: StatusPictureView = StatusPictureView()
    /// 工具条
    lazy var tools: StatusTableViewBottomView = StatusTableViewBottomView()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


