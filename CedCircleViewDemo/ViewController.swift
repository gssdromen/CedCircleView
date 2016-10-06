//
//  ViewController.swift
//  CedCircleViewDemo
//
//  Created by gssdromen on 05/10/2016.
//  Copyright © 2016 gssdromen. All rights reserved.
//

import UIKit
import CedCircleView
import Kingfisher

class ViewController: UIViewController, CedCircleViewDelegate {

    let circle = CedCircleView()
    
    // MARK: - CedCircleViewDelegate
    func numberOfImageViews() -> UInt {
        return 3
    }
    
    func clickCurrentImage(index: UInt) {
        
    }
    
    /**
     加载图片的代理方法，如果返回了UIImage，会进行图片的缓存
     */
    public func refreshImageViewAtIndex(imageView: UIImageView, index: UInt) -> UIImage? {
        imageView.kf_setImage(with: URL(string: "https://pbs.twimg.com/media/CYU6bUjUwAA_TUj.jpg"))
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.circle.frame = CGRect(x: 0, y: 0, width: 320, height: 80)
        self.view.addSubview(self.circle)
        self.circle.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.circle.scrollView.setContentOffset(CGPoint(x: 200, y: 300), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

