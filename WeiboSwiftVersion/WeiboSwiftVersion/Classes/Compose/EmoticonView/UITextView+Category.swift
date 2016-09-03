//
//  UITextView+Category.swift
//  EmojiKeyboard
//
//  Created by paomoliu on 16/9/2.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

extension UITextView
{
    func insertEmoticon(emoticon: Emoticon)
    {
        //0.判断是否是删除按钮
        if emoticon.isRemoveBtn
        {
            deleteBackward()
        }
        
        //1.判断是否是emoji表情
        if emoticon.emojiStr != nil
        {
            //不做处理会引起循环引用
            replaceRange(selectedTextRange!, withText: emoticon.emojiStr!)
        }
        //2.判断是否是图片表情
        if emoticon.png != nil
        {
            //2.1创建属性字符串
            let imageText = EmoticonTextAttachment.imageText(emoticon, font: font ?? UIFont.systemFontOfSize(17))
            
            //2.2拿到当前所有文本
            let text = NSMutableAttributedString(attributedString: attributedText)
            
            //2.3插入表情到当前光标所在位置
            let range = selectedRange
            text.replaceCharactersInRange(range, withAttributedString: imageText)
            //若不在这里设置文本大小，就会有bug：若emoji在图片表情之后，那么emoji表情明显变得很小
            //因为属性字符串有自己默认的尺寸，当emoji在表情图片后面，就会按照前一个的默认尺寸进行设置
            text.addAttribute(NSFontAttributeName, value: font ?? UIFont.systemFontOfSize(17), range: NSMakeRange(range.location, 1))
            
            //2.4将替换后的字符串赋值给UITextView
            attributedText = text
            
            //2.5恢复光标所在位置
            //第一个参数指定光标位置，第二个是选中文本的个数
            selectedRange = NSMakeRange(range.location + 1, 0)
            
            //2.6自己主动出发textViewDidChange方法
            delegate?.textViewDidChange!(self)
        }
    }
    
    /**
     获取需要发送给服务器的字符串
     */
    func emoticonAttributedText() -> String
    {
        //获取发送给服务器的数据
        var str = String()
        attributedText.enumerateAttributesInRange(NSMakeRange(0, attributedText.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (objc, range, _) -> Void in
            if objc["NSAttachment"] != nil
            {
                //图片表情
                let attachment = objc["NSAttachment"] as! EmoticonTextAttachment
                str += attachment.chs!
            } else
            {
                //文字
                str += (self.text as NSString).substringWithRange(range)
            }
        }
        
        return str
    }
}
