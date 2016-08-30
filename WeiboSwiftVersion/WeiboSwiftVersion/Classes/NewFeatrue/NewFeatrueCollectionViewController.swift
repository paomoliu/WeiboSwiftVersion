//
//  NewFeatrueCollectionViewController.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/26.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class NewFeatrueCollectionViewController: UICollectionViewController {

    private let imageCount = 4
    private var layout: UICollectionViewFlowLayout = NewFeatureLayout()
    //此处无override，因为集合视图默认的构造函数带参数的（collectionViewLayout）
    init()
    {
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //注册cell
        //oc中获取类是［UICollectionViewCell class］，swift中直接在类后加.self
        collectionView?.registerClass(NewFeatrueCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /*//设置布局
        layout.itemSize = UIScreen.mainScreen().bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        //设置集合视图属性
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.bounces = false
        collectionView?.pagingEnabled = true*/
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCount
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! NewFeatrueCell
        cell.imageIndex = indexPath.item
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        //传递给我们的是上一页的索引
//        print(indexPath)
        
        //获取当前页的索引
        let path = collectionView.indexPathsForVisibleItems().last!
        
        if path.item == (imageCount - 1)
        {
            //拿到cell
            let cell = collectionView.cellForItemAtIndexPath(path) as! NewFeatrueCell
            //3.让cell执行按钮动画
            cell.startBtnAnimation()
        }
    }
}

//swift中一个文件可以定义多个类
//如果当前类需要监听按钮的点击方法，那么当前类不能是私有的
class NewFeatrueCell: UICollectionViewCell
{
    //swift中被private修饰的东西，如果在同一个文件中是可以访问的
     private var imageIndex: Int? {
        didSet{
            iconView.image = UIImage(named: "new_feature_\(imageIndex! + 1)")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startBtnClicked()
    {
        print(__FUNCTION__)
        //去主页，注意点：在企业开发中，如果要切换根控制器，最好都在Appdelegate.m中切换
        NSNotificationCenter.defaultCenter().postNotificationName(SwithRootViewControllerKey, object: true)
    }
    
    /**
     让按钮做动画
     */
    private func startBtnAnimation()
    {
        startBtn.hidden = false
        
        //执行动画
        startBtn.transform = CGAffineTransformMakeScale(0.0, 0.0)
        startBtn.userInteractionEnabled = false
        
        //UIViewAnimationOptions(rawValue: 0) == OC knilOptions
        UIView.animateWithDuration(2.0, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            //清空形变
            self.startBtn.transform = CGAffineTransformIdentity
            }, completion: { (_) -> Void in
                self.startBtn.userInteractionEnabled = true
        })
    }
    
    private func setupUI()
    {
        contentView.addSubview(iconView)
        contentView.addSubview(startBtn)
        
        iconView.xmg_Fill(contentView)
        startBtn.xmg_AlignInner(type: XMG_AlignType.BottomCenter, referView: contentView, size: nil, offset: CGPoint(x: 0, y: -150))
    }
    
    //MARK: - 懒加载
    private lazy var iconView = UIImageView()
    private lazy var startBtn: UIButton = {
       let btn = UIButton()
        btn.setBackgroundImage(UIImage(named: "new_feature_button"), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "new_feature_button_highlighted"), forState: UIControlState.Highlighted)
        btn.hidden = true
        btn.addTarget(self, action: "startBtnClicked", forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
}

private class NewFeatureLayout: UICollectionViewFlowLayout {
    //准备布局
    //什么时候调用？1.先调用有多少个cell的方法 2.调用准备布局 3.调用绘制cell方法
    override func prepareLayout() {
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
