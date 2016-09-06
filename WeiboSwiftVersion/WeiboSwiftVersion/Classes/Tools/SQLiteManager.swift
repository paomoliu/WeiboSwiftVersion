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
}
