//
//  NetworkTools.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/25.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit
import AFNetworking

class NetworkTools: AFHTTPSessionManager {
    static let tools: NetworkTools = {
        //注意：baseUrl一定要以／结尾
        let baseUrl = NSURL(string: "https://api.weibo.com/")
        let t = NetworkTools(baseURL: baseUrl)
        t.responseSerializer.acceptableContentTypes = NSSet(objects: "application/xml", "text/xml", "text/plain", "application/json") as! Set<String>
        return t
    }()
    
    //获取单例的方法
    class func shareNetworkTools() -> NetworkTools {
        return tools
    }
}
