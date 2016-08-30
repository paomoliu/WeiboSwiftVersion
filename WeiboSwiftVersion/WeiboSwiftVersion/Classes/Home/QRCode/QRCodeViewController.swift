//
//  QRCodeViewController.swift
//  WeiboSwiftVersion
//
//  Created by paomoliu on 16/8/22.
//  Copyright © 2016年 Sunshine Girl. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, UITabBarDelegate {

    /// 冲击波顶部约束
    @IBOutlet weak var scanLineTopCons: NSLayoutConstraint!
    @IBOutlet weak var scanLineView: UIImageView!
    /// 容器高度约束
    @IBOutlet weak var containerHeightCons: NSLayoutConstraint!
    /// 底部视图
    @IBOutlet weak var customTabBar: UITabBar!
    
    @IBAction func CloseBtnClick(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func myCardBtnClick(sender: AnyObject) {
        let vc = QRCodeCardViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //1.设置默认选项
        customTabBar.selectedItem = customTabBar.items![0]
        
        customTabBar.delegate = self
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //1.开启冲击波动画
        startAnimation()
        //2.开始扫描
        startScan()
    }
    
    private func startAnimation()
    {
        //让约束从顶部开始
        self.scanLineTopCons.constant = -self.containerHeightCons.constant
        self.scanLineView.layoutIfNeeded()
        
        //执行冲击波动画
        UIView.animateWithDuration(2.0) { () -> Void in
            //1.修改约束
            self.scanLineTopCons.constant = 0
            //设置动画指定的次数
            UIView.setAnimationRepeatCount(MAXFLOAT)
            //2.强制更新界面
            self.scanLineView.layoutIfNeeded()
        }
    }
    
    private func startScan()
    {
        //1.判断是否能够将输入添加到会话
        if !session.canAddInput(deviceInput)
        {
            return
        }
        //2.判断是否能够将输出添加到会话
        if !session.canAddOutput(dataOutput)
        {
            return
        }
        //3.将输入和输出都添加到会话中
        session.addInput(deviceInput)
        session.addOutput(dataOutput)
        //4.设置输出数据能够解析的数据类型
        //注意：设置能够解析的数据类型时，一定要在输出数据添加到会话之后，否则会报错
        dataOutput.metadataObjectTypes = dataOutput.availableMetadataObjectTypes
        //5.设置输出数据的代理，只要解析成功，就会通知代理
        dataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        //如果想实现只扫描一张图片，那么系统自带的二维码扫描是不支持的
        //只能设置让二维码只有出现在某一块区域才去扫描
//        dataOutput.rectOfInterest = CGRectMake(0.0, 0.0, 0.5, 0.5)
        
        //插入预览图层
        view.layer.insertSublayer(previewLayer, atIndex: 0)
        //添加边线图层
        previewLayer.addSublayer(drawLayer)
        
        //6.告诉session开始扫描
        session.startRunning()
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem)
    {
        //1.修改容器的高度
        if item.tag == 1
        {
            self.containerHeightCons.constant = 300
        } else
        {
            self.containerHeightCons.constant = 150
        }
        
        //停止动画
        self.scanLineView.layer.removeAllAnimations()
        //重新开始动画
        startAnimation()
    }
    
    //MARK: - 懒加载
    //会话，是扫描的桥梁
    private lazy var session: AVCaptureSession = AVCaptureSession()
    //输入设备
    private lazy var deviceInput: AVCaptureDeviceInput? = {
        //拿到摄像头
       let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do
        {
            let input = try AVCaptureDeviceInput(device: device)
            return input
        }catch
        {
            print(error)
            return nil
        }
    }()
    //输出数据
    private lazy var dataOutput: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    //创建预览图层
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
       let layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.frame = UIScreen.mainScreen().bounds
        
        return layer
    }()
    //创建用于绘制边线的图层
    private lazy var drawLayer: CALayer = {
        let layer = CALayer()
        layer.frame = UIScreen.mainScreen().bounds
        return layer
    }()
}

extension QRCodeViewController: AVCaptureMetadataOutputObjectsDelegate
{
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!)
    {
        //0.清空图层
        clearCorners()
        
        //1.获取扫描到的数据
        //注意：此处必须使用stringValue
//        print(metadataObjects.last)
//        print(metadataObjects.last?.stringValue)
        
        //2.获取扫描到的二维码位置
//        print(metadataObjects.last?.corners)
        //2.1转换坐标
        for object in metadataObjects
        {
            //2.1.1判断当前获取到的数据，是否是机器可识别的类型
            if object is AVMetadataMachineReadableCodeObject
            {
                //2.1.2将坐标转换为界面可识别的坐标
                let codeObject = previewLayer.transformedMetadataObjectForMetadataObject(object as! AVMetadataObject) as! AVMetadataMachineReadableCodeObject
                //2.1.3绘制图形
                drawCorners(codeObject)
            }
        }
    }
    
    /**
     绘制图形
     
     - parameter codeObject: 保存坐标的对象
     */
    private func drawCorners(codeObject: AVMetadataMachineReadableCodeObject)
    {
        if codeObject.corners.isEmpty
        {
            return
        }
        
        //1.创建一个图层
        let layer = CAShapeLayer()
        layer.lineWidth = 4
        layer.strokeColor = UIColor.greenColor().CGColor
        layer.fillColor = UIColor.clearColor().CGColor
        
        //2.创建路径
//        layer.path = UIBezierPath(rect: CGRect(x: 100, y: 100, width: 200, height: 200)).CGPath
        let path = UIBezierPath()
        var point = CGPointZero
        var index: Int = 0
        //2.1移动到第一个点
        CGPointMakeWithDictionaryRepresentation((codeObject.corners[index++] as! CFDictionaryRef), &point)
        path.moveToPoint(point)
        //2.2移动到其它点
        while index < codeObject.corners.count
        {
            CGPointMakeWithDictionaryRepresentation((codeObject.corners[index++] as! CFDictionaryRef), &point)
            path.addLineToPoint(point)
        }
        //2.3关闭路径
        path.closePath()
        //2.4绘制路径
        layer.path = path.CGPath
        
        //将绘制好的图层添加到drawLayer上
        drawLayer.addSublayer(layer)
    }
    
    /**
     清空边线
     */
    private func clearCorners()
    {
        //1.判断drawLayer上是否有其它图层
        if drawLayer.sublayers?.count == nil || drawLayer.sublayers?.count == 0
        {
            return
        }
        
        //2移除所有子图层
        for layer in drawLayer.sublayers!
        {
            layer.removeFromSuperlayer()
        }
    }
}
