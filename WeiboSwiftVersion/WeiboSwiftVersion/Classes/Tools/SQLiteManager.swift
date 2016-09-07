//
//  SQLiteManager.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/9/6.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class SQLiteManager: NSObject
{
    private static let manager: SQLiteManager = SQLiteManager()
    
    class func shareManager() -> SQLiteManager {
        return manager
    }
    
    var dbQueue: FMDatabaseQueue?
    
    /**
     打开数据库
     
     - parameter daName: 数据库名称
     */
    func openDB(dbName: String)
    {
        //根据传入的数据库名称拼接数据库路径
        let path = dbName.docDir()
        print(path)
        
        //创建数据库对象
        //注意: 如果是使用FMDatabaseQueue创建数据库对象, 那么就不用打开数据库
        dbQueue = FMDatabaseQueue(path: path)
        
        //创建表
        createTable()
    }
    
    /**
     创建表
     */
    private func createTable()
    {
        //编写SQL语句
        let sql = "CREATE TABLE IF NOT EXISTS T_Status( \n" +
                    "statusId INTEGER PRIMARY KEY, \n" +
                    "statusText TEXT, \n" +
                    "userId INTEGER \n" +
                    "); \n"
        
        //执行SQL语句
        dbQueue!.inDatabase { (db) -> Void in
            db.executeUpdate(sql, withArgumentsInArray: nil)
        }
    }
}
