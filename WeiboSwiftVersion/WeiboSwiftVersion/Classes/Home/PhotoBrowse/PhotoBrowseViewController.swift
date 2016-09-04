//
//  PhotoBrowseViewController.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/31.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit
import SVProgressHUD

private let kPhotoBrowseCellReuseIdentifier = "kPhotoBrowseCellReuseIdentifiere"

class PhotoBrowseViewController: UIViewController
{
    var currentIndex: Int?
    var pictureUrls: [NSURL]?
    init(index: Int, urls: [NSURL])
    {
        super.init(nibName: nil, bundle: nil)
        
        currentIndex = index
        pictureUrls = urls
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //控制器view默认为透明色，若不设置颜色，会看到两个按钮先出来的情况
        view.backgroundColor = UIColor.whiteColor()
        
        //初始化UI
        setupUI()
    }
    
    private func setupUI()
    {
        //1.添加子控件
        view.addSubview(collectionView)
        view.addSubview(closeBtn)
        view.addSubview(saveBtn)
        
        //2.布局子控件
        closeBtn.xmg_AlignInner(type: XMG_AlignType.BottomLeft, referView: view, size: CGSize(width: 100, height: 40), offset: CGPoint(x: 10, y: -10))
        saveBtn.xmg_AlignInner(type: XMG_AlignType.BottomRight, referView: view, size: CGSize(width: 100, height: 40), offset: CGPoint(x: -10, y: -10))
        collectionView.frame = UIScreen.mainScreen().bounds
        collectionView.contentOffset.x = UIScreen.mainScreen().bounds.width * CGFloat(currentIndex!)
        
        //3.设置数据源
        collectionView.dataSource = self
        collectionView.registerClass(PhotoBrowseCell.self, forCellWithReuseIdentifier: kPhotoBrowseCellReuseIdentifier)
    }
    
    func close()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save()
    {
        //1.拿到当前正在显示的cell
        let indexPath = collectionView.indexPathsForVisibleItems().last!
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoBrowseCell
        
        //2.保存图片
        let image = cell.pictureView.image
        UIImageWriteToSavedPhotosAlbum(image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
        
        //- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo; ----OC方法
    }

    //OC方法转Swift方法
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject)
    {
        if error != nil
        {
            SVProgressHUD.showErrorWithStatus("保存失败")
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Clear)
        } else
        {
            SVProgressHUD.showInfoWithStatus("保存成功")
            SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Clear)
        }
    }
    
    //MARK: - 懒加载
    private lazy var closeBtn: UIButton =
    {
       let btn = UIButton()
        btn.setTitle("关闭", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.darkGrayColor()
        btn.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
    
    private lazy var saveBtn: UIButton =
    {
        let btn = UIButton()
        btn.setTitle("保存", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btn.backgroundColor = UIColor.darkGrayColor()
        btn.addTarget(self, action: "save", forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
    
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: PhotoBrowseLayout())
}

extension PhotoBrowseViewController: UICollectionViewDataSource, PhotoBrowseCellDelegate
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return pictureUrls?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kPhotoBrowseCellReuseIdentifier, forIndexPath: indexPath) as! PhotoBrowseCell
        cell.backgroundColor = UIColor.randomColor()
        cell.pictureUrl = pictureUrls![indexPath.item]
        cell.delegate = self
        
        return cell
    }
    
    func closePhotoBrowse(cell: PhotoBrowseCell) {
        close()
    }
}

private class PhotoBrowseLayout: UICollectionViewFlowLayout
{
    private override func prepareLayout() {
        //设置布局
        itemSize = UIScreen.mainScreen().bounds.size
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        //设置集合视图属性
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.bounces = false
        collectionView?.pagingEnabled = true
    }
}
