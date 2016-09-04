//
//  EmoticonsViewController.swift
//  EmoticonsKeyboard
//
//  Created by paomoliu on 16/9/1.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

class EmoticonsViewController: UIViewController {
    /// 定义一个闭包属性, 用于传递选中的表情模型
    var emoticonSelectedCallBack: (emoticon: Emoticon)->()
    
    init(callBack: (emoticon: Emoticon)->())
    {
        self.emoticonSelectedCallBack = callBack
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.redColor()
        
        //初始化UI
        setupUI()
    }
    
    private func setupUI()
    {
        view.addSubview(collectionView)
        view.addSubview(toolBar)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        var cons = [NSLayoutConstraint]()
        let dict = ["collectionView": collectionView, "toolBar": toolBar]
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[toolBar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-[toolBar(44)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        view.addConstraints(cons)
    }
    
    func clickedToolBarBtn(item: UIBarButtonItem)
    {
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: item.tag), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
    }
    
    //MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: EmoticonLayout())
        collectionView.registerClass(EmoticonCell.self, forCellWithReuseIdentifier: kEmoticonCellReuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    private lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.tintColor = UIColor.darkGrayColor()
        var items = [UIBarButtonItem]()
        
        var index = 0
        for title in ["最近", "默认", "emoji", "浪小花"]
        {
            let item = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Plain, target: self, action: "clickedToolBarBtn:")
            item.tag = index++
            items.append(item)
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil))
        }
        items.removeLast()
        toolBar.items = items
        
        return toolBar
    }()
    
    private lazy var packages: [EmoticonPackage] = EmoticonPackage.packageList
}

private let kEmoticonCellReuseIdentifier = "kEmoticonsCellReuseIdentifier"
extension EmoticonsViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return packages.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return packages[section].emoticons?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kEmoticonCellReuseIdentifier, forIndexPath: indexPath) as! EmoticonCell
        cell.backgroundColor = (indexPath.item % 2 == 0) ? UIColor.redColor() : UIColor.grayColor()
        //取出对应的组
        let package = packages[indexPath.section]
        //取出组对应组对应行的模型
        let emoticon = package.emoticons![indexPath.item]
        cell.emoticon = emoticon
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let emoticon = packages[indexPath.section].emoticons![indexPath.item]
        emoticon.times++
        
        //追加emoticon到最近组
        packages[0].appendEmoticonsToRecentPackage(emoticon)
        
        //重新加载数据
//        collectionView.reloadSections(NSIndexSet(index: 0))
        
        //回调通知使用者当前点击了哪个表情
        emoticonSelectedCallBack(emoticon: emoticon)
    }
}

class EmoticonCell: UICollectionViewCell
{
    var emoticon: Emoticon? {
        didSet {
            //判断是否是图片表情
            if emoticon?.chs != nil
            {
                emoticonBtn.setImage(UIImage(contentsOfFile: emoticon!.imagePath!), forState: UIControlState.Normal)
            } else
            {
                //防止重用
                emoticonBtn.setImage(nil, forState: UIControlState.Normal)
            }
            
            //设置emoji表情
            emoticonBtn.setTitle(emoticon?.emojiStr ?? "", forState: UIControlState.Normal)
            
            if emoticon?.isRemoveBtn == true
            {
                emoticonBtn.setImage(UIImage(named: "compose_emotion_delete"), forState: UIControlState.Normal)
                emoticonBtn.setImage(UIImage(named: "compose_emotion_delete_highlighted"), forState: UIControlState.Highlighted)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    private func setupUI()
    {
        contentView.addSubview(emoticonBtn)
        emoticonBtn.backgroundColor = UIColor.whiteColor()
        //设置不能与用户交互，若不设置点击按钮区域，不能触发cell的点击
        emoticonBtn.userInteractionEnabled = false
        //        emoticonBtn.frame = contentView.frame
        emoticonBtn.frame = CGRectInset(contentView.frame, 4, 4)
        //设置字体保证emoji表情和其它表情大小一致
        emoticonBtn.titleLabel?.font = UIFont.systemFontOfSize(32)
    }
    
    private lazy var emoticonBtn: UIButton = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EmoticonLayout: UICollectionViewFlowLayout
{
    override func prepareLayout()
    {
        let width = collectionView!.bounds.width / 7
        itemSize = CGSize(width: width, height: width)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.pagingEnabled = true
        collectionView?.bounces = false
        
        //注意：最好不要乘以0.5，因为CGFloat不准确
        let y = (collectionView!.bounds.height - 3 * width) * 0.49
        collectionView?.contentInset = UIEdgeInsets(top: y, left: 0, bottom: y, right: 0)
    }
}
