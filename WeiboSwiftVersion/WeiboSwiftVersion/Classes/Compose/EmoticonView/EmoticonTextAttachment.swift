//
//  EmoticonTextAttachment.swift
//  EmojiKeyboard
//
//  Created by paomoliu on 16/9/2.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class EmoticonTextAttachment: NSTextAttachment {
    var chs: String?
    
    /**
     根据表情模型，创建表情属性字符串
     */
    class func imageText(emoticon: Emoticon, font: UIFont) -> NSAttributedString
    {
        //1创建附件
        let attachment = EmoticonTextAttachment()
        attachment.chs = emoticon.chs
        attachment.image = UIImage(contentsOfFile: emoticon.imagePath!)
        //设置附件的大小
        let fontSize = font.lineHeight
        attachment.bounds = CGRectMake(0, -4, fontSize, fontSize)
        
        //2.2根据附件创建属性字符串
        return NSAttributedString(attachment: attachment)
    }
}
