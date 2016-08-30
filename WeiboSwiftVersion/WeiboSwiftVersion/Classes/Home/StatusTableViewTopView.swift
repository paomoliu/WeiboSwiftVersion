//
//  StatusTableViewTopView.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/29.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class StatusTableViewTopView: UIView
{
    var status: Status? {
        didSet {
            nameLabel.text = status?.user?.name
            timeLabel.text = status?.created_at
            //设置来源
            sourceLabel.text = status?.source
            //
            //            if let avatarUrl = status?.user?.profile_image_url
            //            {
            //                let url = NSURL(string: avatarUrl)
            //                avatarView.sd_setImageWithURL(url)
            //            }
            if let url = status?.user?.avatarURL
            {
                avatarView.sd_setImageWithURL(url)
            }
            //设置认证图片
            verifiedView.image = status?.user?.verifiedImage
            //设置等级图片
            vipView.image = status?.user?.mbrankImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    private func setupUI()
    {
        //1.添加子控件
        addSubview(avatarView)
        addSubview(verifiedView)
        addSubview(nameLabel)
        addSubview(vipView)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        
        //2.布局子控件
        avatarView.xmg_AlignInner(type: XMG_AlignType.TopLeft, referView: self, size: CGSize(width: 50, height: 50), offset: CGPoint(x: 10, y: 10))
        verifiedView.xmg_AlignInner(type: XMG_AlignType.BottomRight, referView: avatarView, size: CGSize(width: 14, height: 14), offset: CGPoint(x: 5, y: 5))
        nameLabel.xmg_AlignHorizontal(type: XMG_AlignType.TopRight, referView: avatarView, size: nil, offset: CGPoint(x: 10, y: 0))
        vipView.xmg_AlignHorizontal(type: XMG_AlignType.BottomRight, referView: nameLabel, size: CGSize(width: 14, height: 14), offset: CGPoint(x: 10, y: 0))
        timeLabel.xmg_AlignHorizontal(type: XMG_AlignType.BottomRight, referView: avatarView, size: nil, offset: CGPoint(x: 10, y: 0))
        sourceLabel.xmg_AlignHorizontal(type: XMG_AlignType.BottomRight, referView: timeLabel, size: nil, offset: CGPoint(x: 10, y: 0))

    }
    
    //MARK: - 懒加载
    /// 用户头像
    private lazy var avatarView: UIImageView = {
        let av = UIImageView(image: UIImage(named: "avatar_default_big"))
        
        return av
    }()
    
    /// 认证图片
    private lazy var verifiedView: UIImageView = UIImageView(image: UIImage(named: "avatar_enterprise_vip"))
    /// 昵称
    private lazy var nameLabel: UILabel = UILabel.createLabel(UIColor.darkGrayColor(), fontSize: 14)
    /// 会员图片
    private lazy var vipView: UIImageView = UIImageView(image: UIImage(named: "common_icon_membership_level1"))
    /// 时间
    private lazy var timeLabel: UILabel = UILabel.createLabel(UIColor.darkGrayColor(), fontSize: 14)
    /// 来源
    private lazy var sourceLabel: UILabel = UILabel.createLabel(UIColor.darkGrayColor(), fontSize: 14)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
