//
//  PhotoPickerViewController.swift
//  PhotoPicker
//
//  Created by paomoliu on 16/9/3.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit

private let kPhotoPickerCellReuseIdentifier = "kPhotoPickerCellReuseIdentifier"

class PhotoPickerViewController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI()
    {
        view.addSubview(collectionView)
        
        var cons = [NSLayoutConstraint]()
        let dict = ["collectionView": collectionView]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        view.addConstraints(cons)
    }
    
    //MARK: - 懒加载
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: PhotoPickerViewLayout())
        collectionView.registerClass(PhotoPickerViewCell.self, forCellWithReuseIdentifier: kPhotoPickerCellReuseIdentifier)
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    lazy var photoImages: [UIImage] = [UIImage]()
}

extension PhotoPickerViewController: UICollectionViewDataSource, PhotoPickerCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return photoImages.count + 1;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kPhotoPickerCellReuseIdentifier, forIndexPath: indexPath) as! PhotoPickerViewCell
        cell.delegate = self
        cell.image = (photoImages.count == indexPath.item) ? nil : photoImages[indexPath.item]
        
        return cell
    }
    
    func photoDidAdded(cell: PhotoPickerViewCell)
    {
//        print(__FUNCTION__)
        /*
        case PhotoLibrary     照片库(所有的照片，拍照&用 iTunes & iPhoto `同步`的照片 - 不能删除)
        case SavedPhotosAlbum 相册 (自己拍照保存的, 可以随便删除)
        case Camera    相机
        */
        // 1.判断能否打开照片库
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        {
            print("不能打开照片库")
            return
        }
        
        // 2.创建图片选择器
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        presentViewController(imagePickerVC, animated: true, completion: nil)
    }
    
    func photoDidRemoved(cell: PhotoPickerViewCell)
    {
        // 1.从数组中移除当前点击的图片
        let indexPath = collectionView.indexPathForCell(cell)
        photoImages.removeAtIndex(indexPath!.item)
        
        // 2.刷新表格
        collectionView.reloadData()
    }
    
    /**
     选中相片之后调用
     
     :param: picker      触发事件的控制器
     :param: image       当前选中的图片
     :param: editingInfo 编辑之后的图片
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        /*
        注意：一般情况下，只要涉及到从相册中获取图片的功能，都需要处理内存
        
        一般情况下一个应用程序启动会占用20M左右的内存，当内存飙升到500M左右的时候系统就会发送内存警告，
        此时就需要释放内存，否则就会闪退（其它程序关闭的情况下）
        只要内存释放到100M左右，那么系统就不会闪退应用程序
        一个应用程序占用的内存20～100M时，是比较安全的内存范围
        */
        
        /*
        注意：1.如果使用JPGE压缩图片，图片压缩之后是不保真的
             2.苹果官方不推荐使用JPG图片，因为现实JPG图片解压缩的时候非常消耗性能
        */

        let newImage = image.imageWithScale(320)
        photoImages.append(newImage)
        collectionView.reloadData()
        
        // 注意: 如果实现了该方法, 需要自己关闭图片选择器
        dismissViewControllerAnimated(true, completion: nil)
    }
}

@objc
protocol PhotoPickerCellDelegate: NSObjectProtocol
{
    optional func photoDidAdded(cell: PhotoPickerViewCell)
    optional func photoDidRemoved(cell: PhotoPickerViewCell)
}

class PhotoPickerViewCell: UICollectionViewCell
{
    weak var delegate: PhotoPickerCellDelegate?
    var image: UIImage? {
        didSet {
            if image != nil
            {
                removeBtn.hidden = false
                photoBtn.userInteractionEnabled = false
                photoBtn.setBackgroundImage(image, forState: UIControlState.Normal)
                photoBtn.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Highlighted)
            } else
            {
                removeBtn.hidden = true
                photoBtn.userInteractionEnabled = true
                photoBtn.setBackgroundImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
                photoBtn.setBackgroundImage(UIImage(named: "compose_pic_add_highlighted"), forState: UIControlState.Highlighted)
            }
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    func addPhoto()
    {
        delegate?.photoDidAdded!(self)
    }
    
    func removePhoto()
    {
        delegate?.photoDidRemoved!(self)
    }
    
    private func setupUI()
    {
        contentView.addSubview(photoBtn)
        contentView.addSubview(removeBtn)
        
        var cons = [NSLayoutConstraint]()
        let dict = ["photoBtn": photoBtn, "removeBtn": removeBtn]
        photoBtn.translatesAutoresizingMaskIntoConstraints = false
        removeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[photoBtn]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[photoBtn]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:[removeBtn]-2-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-2-[removeBtn]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: dict)
        contentView.addConstraints(cons)
    }
    
    //MARK: - 懒加载
    private lazy var photoBtn: UIButton = {
        let btn = UIButton()
        btn.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        btn.setBackgroundImage(UIImage(named: "compose_pic_add"), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "compose_pic_add_highlighted"), forState: UIControlState.Highlighted)
        btn.addTarget(self, action: "addPhoto", forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
    
    private lazy var removeBtn: UIButton = {
        let btn = UIButton()
        btn.hidden = true
        btn.setBackgroundImage(UIImage(named: "compose_photo_close"), forState: UIControlState.Normal)
        btn.addTarget(self, action: "removePhoto", forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PhotoPickerViewLayout: UICollectionViewFlowLayout
{
    override func prepareLayout()
    {
        itemSize = CGSize(width: 80, height: 80)
        sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
