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
    class func loadStatuses(since_id: Int, max_id: Int, finished: (statuses: [[String: AnyObject]]?, error: NSError?)->())
    {
        //1.从本地数据库获取
        loadCacheStatuses(since_id, max_id: max_id) { (statuses, error) -> () in
            //2.如果本地有，直接返回
            if !statuses.isEmpty
            {
                print("++++++++本地有，直接返回")
                finished(statuses: statuses, error: nil)
                return
            }
            
            //3.从网络获取
            loadNetworkStatused(since_id, max_id: max_id, finished: { (statuses, error) -> () in
                finished(statuses: statuses, error: error)
            })
        }
    }
    
    class func loadNetworkStatused(since_id: Int, max_id: Int, finished: (statuses: [[String: AnyObject]]?, error: NSError?)->())
    {
        print("-----------从网络获取")
        let path = "2/statuses/home_timeline.json"
        var params = ["access_token": UserAccount.readAccount()!.access_token!]
        
        //下拉刷新
        if since_id > 0
        {
            params["since_id"] = "\(since_id)"
        }
        
        //上拉加载更多
        if max_id > 0
        {
            //传递max_id会使返回的数据包含max_id对应的微博数据，这样在拼接数据时就包含两条max_id对应的数据，所以这里需要－1
            params["max_id"] = "\(max_id - 1)"
        }
        
        NetworkTools.shareNetworkTools().GET(path, parameters: params, progress: nil, success: { (_, JSON) -> Void in
            let statuses = JSON!["statuses"] as! [[String: AnyObject]]
            
            //4.缓存网络获取的数据
            cacheStatuses(statuses)
            
            // 5.返回获取到的数据
            finished(statuses: statuses, error: nil)
            }) { (_, error) -> Void in
                print(error)
                finished(statuses: nil, error: error)
        }
    }
    
    class func loadCacheStatuses(since_id: Int, max_id: Int, finished: (statuses: [[String: AnyObject]], error: NSError?)->())
    {
        //定义SQL语句
        var sql = "SELECT * FROM T_Status \n"
        if since_id > 0
        {
            sql += "WHERE statusId > \(since_id) \n"
        } else if max_id > 0
        {
            sql += "WHERE statusId < \(max_id) \n"
        }
        sql += "ORDER BY statusId DESC \n"
        sql += "LIMIT 20"
        
        //执行SQL语句
        SQLiteManager.shareManager().dbQueue?.inDatabase({ (db) -> Void in
            let res = db.executeQuery(sql, withArgumentsInArray: nil)
            
            var statuses = [[String: AnyObject]]()
            while res.next()
            {
                let statusText = res.stringForColumn("statusText") as String
                let data = statusText.dataUsingEncoding(NSUTF8StringEncoding)!
                let dict = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! [String: AnyObject]
                statuses.append(dict)
            }
            
            finished(statuses: statuses, error: nil)
        })
    }
    
    /**
     缓存网络获取数据
     */
    class func cacheStatuses(statuses: [[String: AnyObject]])
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
//                    print(statusText)
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
