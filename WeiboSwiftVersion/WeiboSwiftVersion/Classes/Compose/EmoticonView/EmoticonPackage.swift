//
//  EmoticonPackage.swift
//  EmojiKeyboard
//
//  Created by paomoliu on 16/9/1.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

/*
结构:
1. 加载emoticons.plist拿到每组表情的路径

emoticons.plist(字典)  存储了所有组表情的数据
|----packages(字典数组)
        |----id(存储了对应组表情对应的文件夹)

2. 根据拿到的路径加载对应组表情的info.plist
info.plist(字典)
    |----id(当前组表情文件夹的名称)
    |----group_name_cn(组的名称)
    |----emoticons(字典数组, 里面存储了所有表情)
        |----chs(表情对应的文字)
        |----png(表情对应的图片)
        |----code(emoji表情对应的十六进制字符串)
*/

import UIKit

class EmoticonPackage: NSObject
{
    /// 当前组表情文件夹的名称
    var id: String?
    /// 组的名称
    var group_name_cn: String?
    /// 字典数组, 里面存储了所有表情
    var emoticons: [Emoticon]?
    /// 通过静态变量的方式保存数据，不用在外部多次调用加载组的方法，提高性能
    static let packageList: [EmoticonPackage] = EmoticonPackage.loadPackages()
    
    init(id: String)
    {
        self.id = id
    }
    
    private class func loadPackages() -> [EmoticonPackage]
    {
        var packages = [EmoticonPackage]()
        //0.创建最近组
        let defalutPk = EmoticonPackage(id: "")
        defalutPk.group_name_cn = "最近"
        defalutPk.emoticons = [Emoticon]()
        defalutPk.appendEmptyEmoticon()
        packages.append(defalutPk)
        
        // 1.加载emoticons.plist
        let path = NSBundle.mainBundle().pathForResource("emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")
        let dict = NSDictionary(contentsOfFile: path!)!
        
        // 2.获取emoticons中获取packages
        let dictArr = dict["packages"] as! [[String: AnyObject]]
        
        // 3.遍历packages数组
        for dictionary in dictArr
        {
            // 4.取出ID, 创建对应的组
            let package = EmoticonPackage(id: dictionary["id"] as! String)
            packages.append(package)
            package.loadEmoticon()
            package.appendEmptyEmoticon()
        }
        
        return packages
    }
    
    func loadEmoticon()
    {
        let emoticonDict = NSDictionary(contentsOfFile: infoPath())!
        group_name_cn = emoticonDict["group_name_cn"] as? String
        let dictArr = emoticonDict["emoticons"] as! [[String: String]]
        
        emoticons = [Emoticon]()
        var index = 0
        for dict in dictArr
        {
            if index == 20
            {
                emoticons?.append(Emoticon(isRemoveBtn: true))
                index = 0
            }
            emoticons?.append(Emoticon(dict: dict, id: id!))
            index++
        }
    }
    
    /**
     追加空白按钮
     如果一页不足21个，那么就添加一些空白按钮补齐
     */
    func appendEmptyEmoticon()
    {
        print(emoticons?.count)
        
        let count = emoticons!.count % 21
        
        for _ in count..<20
        {
            emoticons?.append(Emoticon(isRemoveBtn: false))
        }
        
        emoticons?.append(Emoticon(isRemoveBtn: true))
    }
    
    /**
     追加emoticon到最近组
     */
    func appendEmoticonsToRecentPackage(emoticon: Emoticon)
    {
        //判断是否是删除按钮
        if emoticon.isRemoveBtn
        {
            return
        }
        
        //判断当前点击按钮是否包含在最近组中
        let isContain = emoticons!.contains(emoticon)
        if !isContain
        {
            //先移除删除按钮
            emoticons?.removeLast()
            //追加到最近组
            emoticons?.append(emoticon)
        }
        
        var result = emoticons?.sort({ (e1, e2) -> Bool in
            return e1.times > e2.times
        })
        
        if !isContain
        {
            result?.removeLast()
            //追加删除按钮
            result?.append(Emoticon(isRemoveBtn: true))
        }
        
        emoticons = result
    }
    
    /**
     获取微博表情的主路径
     */
    class func emoticonPath() -> NSString
    {
        return (NSBundle.mainBundle().bundlePath as NSString).stringByAppendingPathComponent("Emoticons.bundle")
    }
    
    /**
     获取id文件夹对应的plist文件
     */
    func infoPath() -> String
    {
        return (EmoticonPackage.emoticonPath().stringByAppendingPathComponent(id!) as NSString).stringByAppendingPathComponent("info.plist")
    }
}

class Emoticon: NSObject
{
    /// 表情对应的文字
    var chs: String?
    /// 表情对应的图片
    var png: String? {
        didSet {
            imagePath = (EmoticonPackage.emoticonPath().stringByAppendingPathComponent(id!) as NSString).stringByAppendingPathComponent(png!)
        }
    }
    /// emoji表情对应的十六进制字符串
    var code: String? {
        didSet {
            // 1.从字符串中取出十六进制的数
            // 创建一个扫描器, 扫描器可以从字符串中提取我们想要的数据
            let scanner = NSScanner(string: code!)
            
            // 2.将十六进制转换为字符串
            var result:UInt32 = 0
            scanner.scanHexInt(&result)
            
            // 3.将十六进制转换为emoji字符串
            emojiStr = "\(Character(UnicodeScalar(result)))"
        }
    }
    var emojiStr: String?
    /// 当前组表情文件夹的名称
    var id: String?
    /// 表情图片的全路径
    var imagePath: String?
    /// 判断是否是删除按钮
    var isRemoveBtn: Bool = false
    /// 记录每个表情被使用的次数
    var times: Int = 0
    
    init(isRemoveBtn: Bool) {
        self.isRemoveBtn = isRemoveBtn
    }
    
    init(dict: [String: String], id: String)
    {
        super.init()
        
        self.id = id
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
}
