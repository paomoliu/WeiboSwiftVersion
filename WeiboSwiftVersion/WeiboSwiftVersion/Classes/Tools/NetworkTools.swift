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
    
    /**
     发送微博
     
     - parameter text:            需要发送的正文
     - parameter image:           需要发送的图片
     - parameter successCallBack: 成功的回调
     - parameter failureCallBack: 失败的回调
     */
    func sendStatus(text: String, image: UIImage?, successCallBack: (status: Status)->(), failureCallBack: (error: NSError)->())
    {
        var path = "2/statuses/"
        let params = ["access_token": UserAccount.readAccount()!.access_token!, "status": text]
        if image != nil
        {
            path += "upload.json"
            
            POST(path, parameters: params, constructingBodyWithBlock: { (formData) -> Void in
                // 1.将数据转换为二进制
                let imageData = UIImagePNGRepresentation(image!)
                
                // 2.上传数据
                /*
                第一个参数: 需要上传的二进制数据
                第二个参数: 服务端对应的字段名称
                第三个参数: 文件的名称(在大部分服务器上可以随便写)
                第四个参数: 数据类型, 通用类型application/octet-stream
                */
                formData.appendPartWithFileData(imageData!, name: "pic",fileName: "image.png", mimeType: "application/octet-stream")
                }, success: { (_, JSON) -> Void in
                    successCallBack(status: Status(dict: JSON as! [String : AnyObject]))
                }, failure: { (_, error) -> Void in
                    failureCallBack(error: error)
            })
        } else
        {
            path += "update.json"

            POST(path, parameters: params, progress: nil, success: { (_, JSON) -> Void in
                    successCallBack(status: Status(dict: JSON as! [String : AnyObject]))
                }) { (_, error) -> Void in
                    failureCallBack(error: error)
            }
        }
    }
}
