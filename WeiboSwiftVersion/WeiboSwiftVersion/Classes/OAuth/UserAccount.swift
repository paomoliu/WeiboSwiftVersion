//
//  UserAccount.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/25.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

//Swift 2.0中，打印对象需要重写CustomStringConvertible协议中的description方法
class UserAccount: NSObject, NSCoding{
    var access_token: String?
    var expires_in: NSNumber? {
        didSet{
            //根据过期秒数，生成真正的过期时间
            expires_date = NSDate(timeIntervalSinceNow: expires_in!.doubleValue)
            print("真正过期时间: \(expires_date)")
        }
    }
    //保存用户过期时间
    var expires_date: NSDate?
    var uid: String?
    /// 用户昵称
    var screen_name: String?
    /// 用户头像地址（大图），180×180像素
    var avatar_large: String?
    
    init(dict: [String: AnyObject]) {
        /*access_token = dict["access_token"] as? String
        //注意：如果直接赋值，这里不会调用didSet，如果是在初始化的时候赋值不会调用didSet方法，需要先初始化，再赋值
        expires_in = dict["expires_in"] as? NSNumber
        uid = dict["uid"] as? String*/
        super.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    //使用setValuesForKeysWithDictionary时，在这里不声明该方法就会导致报错
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    override var description: String {
        //1.定义属性数组
        let keys = ["access_token", "expires_in", "uid", "screen_name", "avatar_large"]
        //2.根据属性数组，将属性转换为字典
        let dict = self.dictionaryWithValuesForKeys(keys)
        //3.将字典转换为字符串
        return "\(dict)"
    }
    
    class func userLogin() -> Bool {
        return UserAccount.readAccount() != nil
    }
    
    func loadUserInfos(finished: (account: UserAccount?, error: NSError?)->())
    {
        assert(access_token != nil, "没有授权")
        let path = "2/users/show.json"
        let params = ["access_token": access_token!, "uid": uid!]
        
        NetworkTools.shareNetworkTools().GET(path, parameters: params, progress: nil, success: { (_, JSON) -> Void in
//            print(JSON)
            //1.判断字典是否有值
            if let dict = JSON as? [String: AnyObject]
            {
                self.screen_name = dict["screen_name"] as? String
                self.avatar_large = dict["avatar_large"] as? String
                
                finished(account: self, error: nil)
                return
            }
            
            finished(account: nil, error: nil)
            
            }) { (_, error) -> Void in
                print(error)
                finished(account: nil, error: error)
        }
    }
    
    static let filePath = "account.plist".cacheDir()
    //MARK: - 保存和读取
    func saveAccount()
    {
        NSKeyedArchiver.archiveRootObject(self, toFile: UserAccount.filePath)
    }
    
    static var account: UserAccount?
    class func readAccount() -> UserAccount?
    {
        //1.判断是否已经加载
        if account != nil
        {
            return account
        }
        
        //2.加载授权模型
        account = NSKeyedUnarchiver.unarchiveObjectWithFile(UserAccount.filePath) as? UserAccount
        
        //3.判断授权信息是否过期
        if account?.expires_date?.compare(NSDate()) == NSComparisonResult.OrderedAscending
        {
            return nil
        }
        
        return account
    }
    
    //MARK: - NSCoding
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(access_token, forKey: "access_token")
        aCoder.encodeObject(expires_in, forKey: "expires_in")
        aCoder.encodeObject(uid, forKey: "uid")
        aCoder.encodeObject(expires_date, forKey: "expires_date")
        aCoder.encodeObject(screen_name, forKey: "screen_name")
        aCoder.encodeObject(avatar_large, forKey: "avatar_large")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        access_token = aDecoder.decodeObjectForKey("access_token") as? String
        expires_in = aDecoder.decodeObjectForKey("expires_in") as? NSNumber
        uid = aDecoder.decodeObjectForKey("uid") as? String
        expires_date = aDecoder.decodeObjectForKey("expires_date") as? NSDate
        screen_name = aDecoder.decodeObjectForKey("screen_name") as? String
        avatar_large = aDecoder.decodeObjectForKey("avatar_large") as? String
    }
}
