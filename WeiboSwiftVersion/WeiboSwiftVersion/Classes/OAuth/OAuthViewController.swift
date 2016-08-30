//
//  OAuthViewController.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/25.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit
import SVProgressHUD

class OAuthViewController: UIViewController {

    let WB_Client_ID = "756247302"
    let WB_REDIRECT_URI = "http://www.520it.com"
    let WB_App_Secret = "2e1f4b249e478479e0038ee00d6ee54a"
    
    override func loadView() {
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //0.初始化导航条
        navigationItem.title = "新浪微博"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: "close")

        loadOAuthPage()
    }
    
    func close()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func loadOAuthPage()
    {
        //1.拼接字符串
        let urlStr = "https://api.weibo.com/oauth2/authorize?client_id=\(WB_Client_ID)&redirect_uri=\(WB_REDIRECT_URI)"
        //2.创建URL
        let url = NSURL(string: urlStr)
        //3.创建Request
        let request = NSURLRequest(URL: url!)
        //4.加载界面
        webView.loadRequest(request)
    }
    
    //MARK: - 懒加载
    private lazy var webView: UIWebView = {
        let webView = UIWebView()
        webView.delegate = self
        return webView
    }()
}

extension OAuthViewController: UIWebViewDelegate
{
    //返回true正常加载，false不加载
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
    {
        //加载授权登录界面：https://api.weibo.com/oauth2/authorize?client_id=756247302&redirect_uri=http://www.520it.com
        //跳转到授权界面：https://api.weibo.com/oauth2/authorize
        //授权成功：http://www.520it.com/?code=xxxxxxxxxxxx
        //取消授权：http://www.520it.com/?error_url=xxxxxxxxxx
        print(request.URL?.absoluteString)
        
        //1.判断是否是授权回调页面，如果不是就继续加载
        if !request.URL!.absoluteString.hasPrefix(WB_REDIRECT_URI)
        {
            //继续加载
            return true
        }
        
        //判断是否授权成功
        let codeStr = "code="
        if request.URL!.query!.hasPrefix(codeStr)
        {
            print("授权成功")
            //取出已经授权的RequestToken
            //codeStr.endIndex是拿到code＝最后的位置
            let code = request.URL!.query!.substringFromIndex(codeStr.endIndex)
            print(code)
            
            //2.用code换取accessToken
            loadAccessToken(code)
        } else
        {
            print("授权失败")
            //关闭界面
            close()
        }
        
        return false
    }
    
    private func loadAccessToken(code: String)
    {
        //1.设置路径
        let path = "oauth2/access_token"
        
        //2.构造参数
        let params = ["client_id": WB_Client_ID, "client_secret": WB_App_Secret, "grant_type": "authorization_code", "code": code, "redirect_uri": WB_REDIRECT_URI]
        
        //3.发送post请求
        NetworkTools.shareNetworkTools().POST(path, parameters: params, success: { (_, Json) -> Void in
            //2.00IvfGgD0ITILp804f6b4bf1ONaPfD
            //2.00IvfGgD0ITILp804f6b4bf1ONaPfD
            /*结论：同一个用户对同一个应用授权多次access_token是一样的，每个access_token都是有过期时间的；
              1.如果自己对自己的应用授权，有效时间是5年差1天
              2.若其他人对自己的应用授权，有效时间是3天
            */
//            print("_______JSON = \(Json)")
            
            //1.字典转模型
            /*
            plist：特点是只能存储系统自带的数据类型
            将对象转换为Json之后写入文件中--->在公司中开始使用
            偏好设置：本质就是plist
            归档：可以存储自定义的对象
            数据库：用于存储大数据，特点是效率较高
            */
            let userAccount = UserAccount(dict: Json as! [String: AnyObject])
//            print(userAccount)
            
            //2.保存用户信息
            userAccount.loadUserInfos({ (account, error) -> () in
                if account != nil
                {
                    account!.saveAccount()
                    
                    //去欢迎页
                    NSNotificationCenter.defaultCenter().postNotificationName(SwithRootViewControllerKey, object: false)
                    
                    return
                }
                
                SVProgressHUD.showInfoWithStatus("网络不给力", maskType: SVProgressHUDMaskType.Black)
            })
            
            //2.归档模型
            //由于请求用户信息是异步的，有可能请求还没结束就在保存，所以不该在这里调用，应该在网络请求完的时候才保存
//            userAccount.saveAccount()
            
            }) { (_, error) -> Void in
                print(error)
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        //提示用户正在加载
        SVProgressHUD.showInfoWithStatus("正在加载...")
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        //关闭提示
        SVProgressHUD.dismiss()
    }
}
