//
//  StatusPictureView.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/29.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit
import SDWebImage

class StatusPictureView: UICollectionView
{
    var status: Status? {
        didSet {
            reloadData()
        }
    }
    private var pictureViewLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    init()
    {
        super.init(frame: CGRectZero, collectionViewLayout: pictureViewLayout)
        
        //1.注册cell
        registerClass(PictureCell.self, forCellWithReuseIdentifier: kPictrueViewReuseIdentifier)
        
        //2.设置数据源
        dataSource = self
        delegate = self
        
        //3.设置cell间间隙
        pictureViewLayout.minimumInteritemSpacing = 5
        pictureViewLayout.minimumLineSpacing = 5
        
        backgroundColor = UIColor.darkGrayColor()
    }
    
    /**
     计算配图尺寸
     */
    func calulateImageSize() -> CGSize
    {
        //1.取出配图个数
        let count = status?.storyedPicUrls?.count
        
        //2.如果没有配图返回zero
        if count == 0 || count == nil
        {
            return CGSizeZero
        }
        
        //3.如果只有一张配图，返回图片实际大小
        if count == 1
        {
            //3.1取出缓存图片
            let key = status?.storyedPicUrls!.first?.absoluteString
            let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(key)
            pictureViewLayout.itemSize = image.size
            //3.2返回缓存图片大小
            
            return image.size
        }
        
        //4.如果四张配图，计算田字格的大小
        let width = Int((UIScreen.mainScreen().bounds.width - 10 * 2 - 5 * 2) / 3)
        let margin = 5
        pictureViewLayout.itemSize = CGSize(width: width, height: width)
        if count == 4
        {
            let viewWidth = width * 2 + margin
            
            return CGSize(width: viewWidth, height: viewWidth)
        }
        
        //5.如果是其它，计算九宫格的大小
        /*
        2/3
        5/6
        7/8/9
        */
        //5.1计算列数
        let colNumber = 3
        //5.2计算行数
        //              ( 2 - 1) / 3 + 1
        let rowNumber = (count! - 1) / 3 + 1
        //宽度 ＝ 列数 * 图片的宽度 + (列数 － 1) * 间隙
        let viewWidth = colNumber * width + (colNumber - 1) * margin
        //高度 ＝ 行数 * 图片的高度 + (行数 － 1) * 间隙
        let viewHeight = rowNumber * width + (rowNumber - 1) * margin
        
        return CGSize(width: viewWidth, height: viewHeight)
    }
    
    //内部类，说明只是包含它的类使用，提高阅读能力
    private class PictureCell: UICollectionViewCell
    {
        var pictureUrl: NSURL? {
            didSet {
                //1.设置图片
                pictureView.sd_setImageWithURL(pictureUrl)
                
                //2.判断是否需要显示gif图标 -- GIF
                if (pictureUrl!.absoluteString as NSString).pathExtension.lowercaseString == "gif"
                {
                    gifView.hidden = false
                }
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setupUI()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI()
        {
            contentView.addSubview(pictureView)
            pictureView.addSubview(gifView)
            
            pictureView.xmg_Fill(contentView)
            gifView.xmg_AlignInner(type: XMG_AlignType.BottomRight, referView: pictureView, size: CGSize(width: 28, height: 18))
        }
        
        //MARK: - 懒加载
        private lazy var pictureView: UIImageView = {
            let imageView = UIImageView()
//            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            
            return imageView
        }()
        private lazy var gifView: UIImageView = {
            let gifView = UIImageView(image: UIImage(named: "timeline_image_gif"))
            gifView.hidden = true
            
            return gifView
        }()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

let kHomePictureSelected = "kHomePictureSelected"
let kCurrentPictureIndexKey = "kCurrentPictureIndexKey"
let kLargePictureUrlsKey = "kPictureUrlsKey"

extension StatusPictureView: UICollectionViewDataSource, UICollectionViewDelegate
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return status?.storyedPicUrls?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kPictrueViewReuseIdentifier, forIndexPath: indexPath) as! PictureCell
        //        cell.backgroundColor = UIColor.greenColor()
        cell.pictureUrl = status?.storyedPicUrls![indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //应该使用控制器跳转到控制器，从当前视图传递通知到首页控制器，经过了cell，传两层
        //一层用代理，两层用通知比较好
        let info = [kCurrentPictureIndexKey: indexPath, kLargePictureUrlsKey: status!.storyedLargePicUrls!]
        NSNotificationCenter.defaultCenter().postNotificationName(kHomePictureSelected, object: self, userInfo: info)
    }
}