//
//  UIImage+Category.swift
//  PhotoPicker
//
//  Created by paomoliu on 16/9/3.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

extension UIImage
{
    /**
     根据传入的宽度生成一张图片(图片不会失真)
     按照图片的宽高比来压缩以前的图片
     
     :param: width 制定宽度
     */
    func imageWithScale(width: CGFloat) -> UIImage
    {
        //根据宽度计算高度
        let height = width * size.height / size.width
        
        //按照宽高比绘制一张新的图片
        let currentSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(currentSize)
        drawInRect(CGRect(origin: CGPointZero, size: currentSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
