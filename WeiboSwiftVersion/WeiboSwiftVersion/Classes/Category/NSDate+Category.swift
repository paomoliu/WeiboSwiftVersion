
//
//  NSDate+Category.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/29.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

extension NSDate
{
    class func dateWithStr(time: String) -> NSDate {
        //1.将服务器返回的时间字符串转换为NSDate
        //1.1创建formatter
        let formatter = NSDateFormatter()
        //1.2设置时间格式
        formatter.dateFormat = "EEE MMM d HH:mm:ss z yyyy"
        //1.3设置时间的区域（真机必须设置，否则可能不能转换成功）
        formatter.locale = NSLocale(localeIdentifier: "en")
        //1.4转换字符串，转换好的时间去除时区的时间
        let createDate = formatter.dateFromString(time)!
        
        return createDate
    }
    
    /**
     刚刚(一分钟内)
     X分钟前(一小时内)
     X小时前(当天)
     昨天 HH:mm(昨天)
     MM-dd HH:mm(一年内)
     yyyy-MM-dd HH:mm(更早期)
     */
    /// 描述时间的属性
    var descDate: String {
        /*
        NSDate: 时间
        //日历，可以取出一个NSDate中的时分秒年月日
        //快速判断两个时间是否同一年
        NSCalendar
        */
        let calendar = NSCalendar.currentCalendar()
        
        // 1.判断是否是今天
        if calendar.isDateInToday(self)
        {
            //1.0获取当前时间与系统时间之间的差距（秒数）
            let seconds = Int(NSDate().timeIntervalSinceDate(self))
//            print(seconds)
            
            // 1.1是否是刚刚
            if seconds < 60
            {
                return "刚刚"
            }
            
            // 1.2多少分钟以前
            if seconds < 60 * 60
            {
                return "\(seconds / 60)分钟前"
            }
            // 1.3多少小时以前
            return "\(seconds / (60 * 60))小时前"
        }
    
        // 2.判断是否是昨天
        var formatterStr = "HH:mm"
        if calendar.isDateInYesterday(self)
        {
            //昨天: HH:mm
            formatterStr = "昨天: " + formatterStr
        } else {
            //通过以下方式可以获取两个之间相差的年
            let comps = calendar.components(NSCalendarUnit.Year, fromDate: self, toDate: NSDate(), options: NSCalendarOptions(rawValue: UInt.max))
            
            if comps.year == 0
            {
                // 3.处理一年以内
                formatterStr = "MM-dd " + formatterStr
            } else {
                // 4.处理更早的时间
                formatterStr = "yyyy-MM-dd " + formatterStr
            }
        }

        
        //5.按照指定的格式将时间转换为字符串
        //5.1创建formatter
        let formatter = NSDateFormatter()
        //5.2设置时间格式
        formatter.dateFormat = formatterStr
        //5.3设置时间的区域（真机必须设置，否则可能不能转换成功）
        formatter.locale = NSLocale(localeIdentifier: "en")
        
        return formatter.stringFromDate(self)
    }
}
