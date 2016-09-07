//
//  StatusDAO.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/9/7.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class StatusDAO: NSObject
{
    class func loadStatuses()
    {
        //1.从本地数据库获取
        
        //2.如果本地有，直接返回
        
        //3.从网络获取
        
        //4.缓存网络获取的数据
    }
    
    /**
     缓存网络获取数据
     */
    class func cacheStatused(statuses: [[String: AnyObject]])
    {
        let userId = UserAccount.readAccount()!.uid!
        
        //定义SQL语句
        let sql = "INSERT INTO T_Status" +
                    "(statusId, statusText, userId)" +
                    "VALUES" +
                    "(?, ?, ?);"
        
        //执行SQL语句
        SQLiteManager.shareManager().dbQueue?.inTransaction({ (db, rollback) -> Void in
            for dict in statuses
            {
                do
                {
                    let statusId = dict["id"]!
                    // JSON -> 二进制 -> 字符串
                    let data = try! NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.PrettyPrinted)
                    let statusText = String(data: data, encoding: NSUTF8StringEncoding)!
                    print(statusText)
                    try db.executeUpdate(sql, statusId, statusText, userId)
                } catch
                {
                    // 如果插入数据失败, 就回滚
                    rollback.memory = true
                    print(error)
                } //try
            } //for
        }) //闭包
    } //func
}
