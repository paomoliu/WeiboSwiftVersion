//
//  User.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/28.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class User: NSObject {
    /// 用户id
    var id: Int = 0
    /// 友好显示名称
    var name: String?
    /// 用户头像地址（中图），50x50
    var profile_image_url: String? {
        didSet {
            if let urlStr = profile_image_url
            {
                avatarURL = NSURL(string: urlStr)
            }
        }
    }
    /// 用于保存用户头像的URL
    var avatarURL: NSURL?
    /// 是否认证，true是，false不是
    var verified: Bool = false
    /// 认证类型：－1没有，0：认证用户，2，3，5:企业认证， 220:达人
    var verified_type: Int = -1 {
        didSet {
            switch verified_type
            {
            case 0:
                verifiedImage = UIImage(named: "avatar_vip")
            case 2,3,5:
                verifiedImage = UIImage(named: "avatar_enterprise_vip")
            case 220:
                verifiedImage = UIImage(named: "avatar_grassroot")
            default:
                verifiedImage = nil
            }
        }
    }
    /// 保存用户当前认证图片
    var verifiedImage: UIImage?
    /// 用户会员等级
    var mbrank: Int = 0 {
        didSet {
            if mbrank > 0 && mbrank < 7 {
                mbrankImage = UIImage(named: "common_icon_membership_level\(mbrank)")
            } else  {
                mbrankImage = nil
            }
        }
    }
    /// 保存用户会员等级图片
    var mbrankImage: UIImage?

    //字典转模型
    init(dict: [String: AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    //使用该方法是因为dict中有很多key是用不到，为了保证匹配dict时不出错
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    var keys = ["id", "name", "profile_image_url", "verified", "verified_type", "mbrank"]
    override var description: String {
        let dict = dictionaryWithValuesForKeys(keys)
        
        return "\(dict)"
    }
}
