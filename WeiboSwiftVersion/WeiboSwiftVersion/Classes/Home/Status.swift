//
//  Status.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/28.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit
import SDWebImage

class Status: NSObject{
    /// 微博创建时间
    var created_at: String? {
        didSet {
//            print("---------\(created_at)")
            
            //1.将字符串转换为时间
            let createDate = NSDate.dateWithStr(created_at!)
            //2.获取格式化之后的时间字符串
            created_at = createDate.descDate
            
            /*
            NSDate: 时间
            //日历，可以取出一个NSDate中的时分秒年月日
            //快速判断两个时间是否同一年
            NSCalendar
            */
//            let calendar = NSCalendar.currentCalendar()
//            let flag = NSCalendarUnit(rawValue: UInt.max)
//            var comps = calendar.components(flag, fromDate: createDate)
//            print(comps.year)
//            print(comps.month)
//            print(comps.day)
//            
//            //利用日历类，只要指定一个时间，就可以判断指定时间和当前时间是否是同一天
//            if calendar.isDateInToday(createDate)
//            {
//                print("今天")
//            }
//            
//            if calendar.isDateInYesterday(createDate)
//            {
//                print("昨天")
//            }
//            
//            //通过以下方式可以获取两个之间相差的年
//            comps = calendar.components(NSCalendarUnit.Year, fromDate: createDate, toDate: NSDate(), options: NSCalendarOptions(rawValue: UInt.max))
//            print(comps.year)
        }
    }
    /// 微博ID
    var id: Int = 0
    /// 微博信息内容
    var text: String?
    /// 微博来源
    var source: String? {
        didSet {
            //<a href="http://app.weibo.com/t/feed/2O2xZO" rel="nofollow">人民网微博</a>
            
//            print("source = \(source)")
            //1.截取字符串
            //注意：nil和""不是同一个概念，如果这里判断只写let str = source会崩，因为source可能是""，而let str ＝ source只会判断source是否为nil
            if source != nil && source != ""
            {
                let str = source! as NSString
                //1.1获取开始和结束截取的位置
                //rangeOfString方法从头开始找，找到一个匹配的就返回，可以设置其查找的顺序
                let startLocation = str.rangeOfString(">").location + 1
                let endLocation = str.rangeOfString("<", options: NSStringCompareOptions.BackwardsSearch).location
                //let endLocation = (sourceStr as NSString).rangeOfString("</").location
                //1.2获取截取长度
                let length = (endLocation - startLocation) as Int
                //1.3截取字符串
                source = "来自 " + (str as NSString).substringWithRange(NSMakeRange(startLocation, length))
            }
        }
    }
    /// 微博配图
    var pic_urls: [[String: AnyObject]]? {
        didSet {
            // 1.初始化数组
            storyedPicUrls = [NSURL]()
            // 2遍历取出所有的图片路径字符串
            for picDict in pic_urls!
            {
                if let urlStr = picDict["thumbnail_pic"]
                {
                    // 将字符串转换为URL保存到数组中
                    storyedPicUrls?.append(NSURL(string: urlStr as! String)!)
                }
            }
        }
    }
    /// 保存转换好的配图URL，在swift开发中，最好是将所有的东西提前准备好
    var storyedPicUrls: [NSURL]?
    /// 用户
    var user: User?
    /// 保存转发微博内容
    var retweeted_status: Status?
    /// 如果有转发，原创微博就不会显示配图，那就不需要缓存原创微博配图，只需要缓存转发配图
    /// 定义一个计算属性，用于返回原创或者转发配图的URL数据
    var pictureUrls: [NSURL]? {
        return retweeted_status?.storyedPicUrls != nil ? retweeted_status?.storyedPicUrls : storyedPicUrls
    }
    
    class func loadStatuses(since_id: Int, finished: (models: [Status]?, error: NSError?)->()) {
        let path = "2/statuses/home_timeline.json"
        var params = ["access_token": UserAccount.readAccount()!.access_token!]
        
        //下拉刷新
        if since_id > 0
        {
            params["since_id"] = "\(since_id)"
        }
        
        NetworkTools.shareNetworkTools().GET(path, parameters: params, progress: nil, success: { (_, JSON) -> Void in
//            print(JSON)
            //1. 取出statuses key对应的数组（存储的都是字典），遍历数组，将字典转换为模型
            let models = dict2Model(JSON!["statuses"] as! [[String: AnyObject]])
//            print(models)
            //2.缓存微博配图
            cacheStatusImages(models, finished: finished)
            }) { (_, error) -> Void in
//                print(error)
                finished(models: nil, error: error)
        }
    }
    
    //缓存微博配图
    class func cacheStatusImages(list: [Status], finished: (models: [Status]?, error: NSError?)->()) {
        if list.count == 0
        {
            finished(models: list, error: nil)
            
            return
        }
        
        //创建一个组
        let group = dispatch_group_create()
        
        for status in list
        {
            
            //判断当前微博是否有配图，如果没有就直接跳过
//            if status.storyedPicUrls == nil
//            {
//                print("结束当前循环，继续下一次循环")
//                //结束当前循环，继续下一次循环
//                continue
//            }
            
            //swift2.0新语法，如果条件为nil，那么就会执行else后面的语句
            guard let _ = status.pictureUrls else
            {
                print("结束当前循环，继续下一次循环")
                continue
            }
            
            for url in status.pictureUrls!
            {
                //将当前下载操作添加到组中
                dispatch_group_enter(group)
                
                //异步缓存图片
                SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (_, _, _, _, _) -> Void in
                    //下载完离开当前组
                    dispatch_group_leave(group)
//                    print("ok")
                })
            }
        }
        
        //组通知
        dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
            //2. 当所有图片都下载完毕再通过闭包将数据传递给调用者
            //什么时候知道所有照片都异步下载完成，可以使用GCD里的组，当组里的队列都离开时，会发送一个通知
//            print("Over")
            finished(models: list, error: nil)
        }
    }
    
    //将字典数组转模型
    class func dict2Model(list: [[String: AnyObject]]) -> [Status]
    {
        var models = [Status]()
        for dict in list
        {
            models.append(Status(dict: dict))
        }
        
        return models
    }
    
    //字典转模型
    init(dict: [String: AnyObject]) {
        super.init()
        setValuesForKeysWithDictionary(dict)
    }
    
    //setValuesForKeysWithDictionary内部会调用下面的方法
    override func setValue(value: AnyObject?, forKey key: String) {
        //1.判断当前是否正在给微博字典中的user字典赋值
        if "user" == key
        {
            //2.根据user key对应的字典创建一个模型
            user = User(dict: value as! [String: AnyObject])
            
            return
        }
        
        //判断当前是否正在给转发微博字典赋值
        if "retweeted_status" == key
        {
            //根据Status key对用的字典创建一个模型
            retweeted_status = Status(dict: value as! [String: AnyObject])
            
            return
        }
        
        super.setValue(value, forKey: key)
//        print("key = \(key), value = \(value)")
    }
    
    //使用该方法是因为dict中有很多key是用不到，为了保证匹配dict时不出错
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    var keys = ["created_at", "id", "text", "source", "pic_urls"]
    override var description: String {
        let dict = dictionaryWithValuesForKeys(keys)
        
        return "\(dict)"
    }
}
