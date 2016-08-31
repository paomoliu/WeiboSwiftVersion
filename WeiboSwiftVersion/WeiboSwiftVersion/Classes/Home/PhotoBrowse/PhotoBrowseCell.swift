//
//  PhotoBrowseCell.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/31.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit
import SDWebImage

protocol PhotoBrowseCellDelegate: NSObjectProtocol
{
    func closePhotoBrowse(cell: PhotoBrowseCell)
}

class PhotoBrowseCell: UICollectionViewCell
{
    var delegate: PhotoBrowseCellDelegate?
    var pictureUrl: NSURL? {
        didSet {
            //重置属性
            reset()
            
            pictureView.sd_setImageWithURL(pictureUrl) { (image, _, _, _) -> Void in
                //调整图片位置
                self.setImageViewPosition()
            }
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        setupUI()
    }

    private func setupUI()
    {
        //1.添加子控件
        contentView.addSubview(scrollView)
        scrollView.addSubview(pictureView)
        
        //2.布局子控件
        scrollView.frame = UIScreen.mainScreen().bounds
        
        //3.处理缩放
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 2
        
        //4.监听图片点击，一层用代理
        let tap = UITapGestureRecognizer(target: self, action: "closePhotoBrowse")
        pictureView.addGestureRecognizer(tap)
        pictureView.userInteractionEnabled = true
    }
    
    func closePhotoBrowse()
    {
        delegate?.closePhotoBrowse(self)
    }
    
    /**
     重置scrollview和imageview的属性
     若不进行重置处理，若进行了缩放，那么后面重用的配图位置会显示不正确
     */
    private func reset()
    {
        //重置scrollView属性
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSizeZero
        
        //重置pictureView属性
        pictureView.transform = CGAffineTransformIdentity
    }
    
    //调整图片的位置
    private func setImageViewPosition()
    {
        //1.拿到按照宽高比计算之后的图片大小
        let size = displaySize(pictureView.image!)
        
        //2.判断图片的高度，是否大于屏幕的高度
        if size.height > UIScreen.mainScreen().bounds.height
        {
            //2.1大于， 长图 --> y ＝ 0， 设置scrollView滚动的范围为图片大小
            pictureView.frame = CGRect(origin: CGPointZero, size: size)
            scrollView.contentSize = size
        } else
        {
            //2.2小于， 短途 --> 设置边框，让图片居中显示
            pictureView.frame = CGRect(origin: CGPointZero, size: size)
            let y = (UIScreen.mainScreen().bounds.height - size.height) * 0.5
            scrollView.contentInset =  UIEdgeInsets(top: y, left: 0, bottom: y, right: 0)
            //pictureView.frame = CGRect(origin: CGPoint(x: 0, y: y), size: size)
        }
    }
    
    //根据图片宽高比计算图片显示大小
    private func displaySize(image: UIImage) -> CGSize
    {
        //1.拿到图片宽高比
        let scale = image.size.height / image.size.width
        
        //2.根据宽高比计算高度
        let width = UIScreen.mainScreen().bounds.width
        let height = width * scale
        
        return CGSize(width: width, height: height)
    }
    
    //MARK: - 懒加载
    private lazy var scrollView: UIScrollView = UIScrollView()
    lazy var pictureView: UIImageView = UIImageView ()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoBrowseCell: UIScrollViewDelegate
{
    //告诉系统要缩放哪个控件
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return pictureView
    }
    
    //重新调整缩放配图位置
    //view：被调整的配图
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat)
    {
        //注意：缩放的本质就是修改transform，而修改transform不会影响到bounds，只有frame会受到影响
        var offsetX = (UIScreen.mainScreen().bounds.width - view!.frame.width) * 0.5
        var offsetY = (UIScreen.mainScreen().bounds.height - view!.frame.height) * 0.5
        
        offsetX = offsetX < 0 ? 0 : offsetX
        offsetY = offsetY < 0 ? 0 : offsetY
        
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}
