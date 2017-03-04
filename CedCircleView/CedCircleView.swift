//
//  CedCircleView.swift
//  CedCircleView
//
//  Created by gssdromen on 05/10/2016.
//  Copyright © 2016 gssdromen. All rights reserved.
//

import UIKit

public protocol CedCircleViewDelegate: class {
    /**
     *点击图片的代理方法
     */
    func clickCurrentImage(index: UInt)

    /// 加载图片的代理方法，如果返回了UIImage，会进行图片的缓存
    ///
    /// - Parameters:
    ///   - imageView: ImageView
    ///   - index: Index
    ///   - offset: 负数表示左一张，0表示当前张，正数表示右一张
    /// - Returns: UIImage, 如果返回了UIImage，会进行图片的缓存
    func refreshImageViewAtIndex(imageView: UIImageView, index: UInt, offset: Int) -> UIImage?

    /**
     图片张数
     */
    func numberOfImageViews() -> UInt
}

public class CedCircleView: UIView, UIScrollViewDelegate {

    weak public var delegate: CedCircleViewDelegate? {
        didSet {
            self.reloadData()
        }
    }

    public let scrollView = UIScrollView()
    let curImageView = UIImageView()
    let prevImageView = UIImageView()
    let nextImageView = UIImageView()

    override public var frame: CGRect {
        didSet {
            layoutMyViews()
        }
    }

    private var totalPages: UInt?
    private var curPage: UInt?
    private var timeInterval: TimeInterval?
    private var timer: Timer?
    private var imageCacheDict = Dictionary<UInt, UIImage>()
    private var isAutoScroll = true

    // MARK: - UIScrollViewDelegate
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let page = self.getCurrentPage()
        if offset == 0 {
            self.curPage = page.0
        } else if offset == self.frame.width * 2 {
            self.curPage = page.2
        }
        // 重新布局图片
        self.refreshImages()
        // 布局后把contentOffset设为中间
        self.scrollView.setContentOffset(CGPoint(x: self.frame.width, y: 0), animated: false)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 如果用户手动拖动到了一个整数页的位置就不会发生滑动了所以需要判断手动调用滑动停止滑动方法
        if !decelerate {
            self.scrollViewDidEndDecelerating(scrollView)
        }
    }

    // 时间触发器设置滑动时动画true，会触发的方法
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollViewDidEndDecelerating(scrollView)
    }

    // MARK: - Public Methods
    public func scrollToNextImage(animate: Bool) {
        self.scrollView.setContentOffset(CGPoint(x: self.bounds.width * 2, y: 0), animated: animate)
    }

    public func scrollToPreviousImage(animate: Bool) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animate)
    }

    public func reloadData() {
        self.imageCacheDict.removeAll()
        self.configViews()
        guard self.totalPages != nil else {
            print("error get nil from self.totalPages")
            return
        }
        self.scrollView.isScrollEnabled = self.totalPages! > 1
        self.refreshImages()
    }

    public func enableAutoScroll(_ flag: Bool) {
        self.isAutoScroll = flag
    }

    public func setCurrentIndex(index: UInt) {
        //        if let count = self.totalPages {
        //            if index < count {
        self.curPage = index
        self.refreshImages()
        //            }
        //        }

    }

    // MARK: - Private Methods
    @objc private func imageViewClickAction() {
        let page = self.getCurrentPage()
        self.delegate?.clickCurrentImage(index: page.1)
    }

    @objc private func timerAction() {
        if self.isAutoScroll {
            self.scrollView.setContentOffset(CGPoint(x: self.bounds.width * 2, y: 0), animated: true)
        }
    }

    private func getCurrentPage() -> (UInt, UInt, UInt) {
        guard self.curPage != nil && self.totalPages != nil else {
            return (0, 0, 0)
        }
        // 计算前一页
        var prevIndex: UInt = 0
        if self.curPage! == 0 {
            if self.totalPages! > 0 {
                prevIndex = self.totalPages! - 1
            } else {
                //                print("图片轮播总数为0")
            }
        } else {
            prevIndex = self.curPage! - 1
        }
        // 计算后一页
        var nextIndex = self.curPage! + 1
        if nextIndex >= self.totalPages! {
            nextIndex = 0
        }

        return (prevIndex, self.curPage!, nextIndex)
    }

    private func refreshImages() {
        let page = self.getCurrentPage()

        // 判断缓存
        if self.imageCacheDict[page.0] != nil {
            self.prevImageView.image = self.imageCacheDict[page.0]
        } else {
            let image = self.delegate?.refreshImageViewAtIndex(imageView: self.prevImageView, index: page.0, offset: -1)
            if image != nil {
                self.imageCacheDict[page.0] = image!
            }
        }
        if self.imageCacheDict[page.1] != nil {
            self.prevImageView.image = self.imageCacheDict[page.1]
        } else {
            let image = self.delegate?.refreshImageViewAtIndex(imageView: self.curImageView, index: page.1, offset: 0)
            if image != nil {
                self.imageCacheDict[page.1] = image!
            }
        }
        if self.imageCacheDict[page.2] != nil {
            self.prevImageView.image = self.imageCacheDict[page.2]
        } else {
            let image = self.delegate?.refreshImageViewAtIndex(imageView: self.nextImageView, index: page.2, offset: 1)
            if image != nil {
                self.imageCacheDict[page.2] = image!
            }
        }
    }

    // MARK: - Views About
    func configViews() {
        self.totalPages = self.delegate?.numberOfImageViews()
        self.curPage = 0
        guard self.totalPages != nil else {
            print("error get nil from numberOfImageViews")
            return
        }
        if self.timeInterval == nil {
            self.timeInterval = 3.5
        }
        if self.timer == nil && self.timeInterval != nil {
            self.timer = Timer(timeInterval: self.timeInterval!, target: self, selector: #selector(CedCircleView.timerAction), userInfo: nil, repeats: true)
        } else {
            //            self.timer?.invalidate()
        }
        if self.timer != nil {
            RunLoop.current.add(self.timer!, forMode: RunLoopMode.defaultRunLoopMode)
        }
    }

    func addMyViews() {
        self.scrollView.delegate = self
        self.scrollView.clipsToBounds = true
        self.scrollView.isPagingEnabled = true
        self.scrollView.bounces = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false

        self.curImageView.contentMode = UIViewContentMode.scaleAspectFit
        self.curImageView.clipsToBounds = true
        self.curImageView.translatesAutoresizingMaskIntoConstraints = false
        self.curImageView.isUserInteractionEnabled = true
        self.curImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CedCircleView.imageViewClickAction)))

        self.prevImageView.contentMode = UIViewContentMode.scaleAspectFit
        self.prevImageView.clipsToBounds = true
        self.prevImageView.translatesAutoresizingMaskIntoConstraints = false

        self.nextImageView.contentMode = UIViewContentMode.scaleAspectFit
        self.nextImageView.clipsToBounds = true
        self.nextImageView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.curImageView)
        self.scrollView.addSubview(self.prevImageView)
        self.scrollView.addSubview(self.nextImageView)
    }

    func layoutMyViews() {
        guard self.scrollView.superview != nil && self.nextImageView.superview != nil && self.curImageView.superview != nil && self.prevImageView.superview != nil else {
            return
        }
        // 布局scrollView
        let constraints1 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: NSLayoutFormatOptions.alignmentMask, metrics: nil, views: ["scrollView": self.scrollView])
        let constraints2 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: NSLayoutFormatOptions.alignmentMask, metrics: nil, views: ["scrollView": self.scrollView])
        self.addConstraints(constraints1)
        self.addConstraints(constraints2)

        // 布局ImageViews
        let constraints3 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[i1(width)][i2(width)][i3(width)]|", options: NSLayoutFormatOptions.alignAllTop, metrics: ["width": self.bounds.width], views: ["i1": self.prevImageView, "i2": self.curImageView, "i3": self.nextImageView])
        let constraints4 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[i1(height)]|", options: NSLayoutFormatOptions.alignmentMask, metrics: ["height": self.bounds.height], views: ["i1": self.prevImageView])
        let constraints5 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[i2(height)]|", options: NSLayoutFormatOptions.alignmentMask, metrics: ["height": self.bounds.height], views: ["i2": self.curImageView])
        let constraints6 = NSLayoutConstraint.constraints(withVisualFormat: "V:|[i3(height)]|", options: NSLayoutFormatOptions.alignmentMask, metrics: ["height": self.bounds.height], views: ["i3": self.nextImageView])
        //        self.prevImageView.backgroundColor = UIColor.red
        //        self.curImageView.backgroundColor = UIColor.green
        //        self.nextImageView.backgroundColor = UIColor.blue
        self.scrollView.addConstraints(constraints3)
        self.scrollView.addConstraints(constraints4)
        self.scrollView.addConstraints(constraints5)
        self.scrollView.addConstraints(constraints6)
        self.scrollView.setContentOffset(CGPoint(x: self.bounds.width, y: 0), animated: true)
    }

    // MARK: - Life Cycle
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layoutMyViews()
    }

    convenience public init() {
        self.init(frame: CGRect.zero)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.addMyViews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addMyViews()
        //        fatalError("init(coder:) has not been implemented")
    }
    
}
