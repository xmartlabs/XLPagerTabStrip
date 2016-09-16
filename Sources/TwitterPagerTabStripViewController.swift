//  TwitterPagerTabStripViewController.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public struct TwitterPagerTabStripSettings {
    
    public struct Style {
        public var dotColor = UIColor(white: 1, alpha: 0.4)
        public var selectedDotColor = UIColor.white
        public var portraitTitleFont = UIFont.systemFont(ofSize: 18)
        public var landscapeTitleFont = UIFont.systemFont(ofSize: 15)
        public var titleColor = UIColor.white
    }
    
    public var style = Style()
}

open class TwitterPagerTabStripViewController: PagerTabStripViewController, PagerTabStripDataSource, PagerTabStripIsProgressiveDelegate {
    
    open var settings = TwitterPagerTabStripSettings()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        pagerBehaviour = .progressive(skipIntermediateViewControllers: true, elasticIndicatorLimit: true)
        delegate = self
        datasource = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        pagerBehaviour = .progressive(skipIntermediateViewControllers: true, elasticIndicatorLimit: true)
        delegate = self
        datasource = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if titleView.superview == nil {
            navigationItem.titleView = titleView
        }
        
        // keep watching the frame of titleView
        titleView.addObserver(self, forKeyPath: "frame", options: [.new, .old], context: nil)
        
        guard let navigationController = navigationController  else {
            fatalError("TwitterPagerTabStripViewController should be embedded in a UINavigationController")
        }
        titleView.frame = CGRect(x: 0, y: 0, width: navigationController.navigationBar.frame.width, height: navigationController.navigationBar.frame.height)
        titleView.addSubview(titleScrollView)
        titleView.addSubview(pageControl)
        reloadNavigationViewItems()
    }

    open override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        guard isViewLoaded else { return }
        
        reloadNavigationViewItems()
        setNavigationViewItemsPosition(updateAlpha: true)
    }
    
    // MARK: - PagerTabStripDelegate

    open func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {

        // move indicator scroll view
        let distance = distanceValue
        var xOffset: CGFloat = 0
        if fromIndex < toIndex {
            xOffset = distance * CGFloat(fromIndex) + distance * progressPercentage
        }
        else if fromIndex > toIndex {
            xOffset = distance * CGFloat(fromIndex) - distance * progressPercentage
        }
        else {
            xOffset = distance * CGFloat(fromIndex)
        }

        titleScrollView.contentOffset = CGPoint(x: xOffset, y: 0)

        // update alpha of titles
        setAlphaWith(offset: xOffset, andDistance: distance)

        // update page control page
        pageControl.currentPage = currentIndex
    }

    open func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
        fatalError()
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard object as AnyObject === titleView && keyPath == "frame" && change?[NSKeyValueChangeKey.kindKey] as? UInt == NSKeyValueChange.setting.rawValue else { return }
        
        let oldRect = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).cgRectValue
        let newRect = (change![NSKeyValueChangeKey.oldKey]! as AnyObject).cgRectValue
        if (oldRect?.equalTo(newRect!))! {
            titleScrollView.frame = CGRect(x: 0, y: 0, width: titleView.frame.width, height: titleScrollView.frame.height)
            setNavigationViewItemsPosition(updateAlpha: true)
        }
    }
    
    deinit {
        titleView.removeObserver(self, forKeyPath: "frame")
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setNavigationViewItemsPosition(updateAlpha: false)
    }
    
    // MARK: - Helpers
    
    private lazy var titleView: UIView = {
        let navigationView = UIView()
        navigationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return navigationView
        }()
    
    private lazy var titleScrollView: UIScrollView = { [unowned self] in
        let titleScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        titleScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleScrollView.bounces = true
        titleScrollView.scrollsToTop = false
        titleScrollView.delegate = self
        titleScrollView.showsVerticalScrollIndicator = false
        titleScrollView.showsHorizontalScrollIndicator = false
        titleScrollView.isPagingEnabled = true
        titleScrollView.isUserInteractionEnabled = false
        titleScrollView.alwaysBounceHorizontal = true
        titleScrollView.alwaysBounceVertical = false
        return titleScrollView
    }()
    
    private lazy var pageControl: FXPageControl = { [unowned self] in
        let pageControl = FXPageControl()
        pageControl.backgroundColor = .clear
        pageControl.dotSize = 3.8
        pageControl.dotSpacing = 4.0
        pageControl.dotColor = self.settings.style.dotColor
        pageControl.selectedDotColor = self.settings.style.selectedDotColor
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private var childTitleLabels = [UILabel]()

    private func reloadNavigationViewItems() {
        // remove all child view controller header labels
        childTitleLabels.forEach { $0.removeFromSuperview() }
        childTitleLabels.removeAll()
        for (index, item) in viewControllers.enumerated() {
            let child = item as! IndicatorInfoProvider
            let indicatorInfo = child.indicatorInfo(for: self)
            let navTitleLabel : UILabel = {
                let label = UILabel()
                label.text = indicatorInfo.title
                label.font = UIApplication.shared.statusBarOrientation.isPortrait ? settings.style.portraitTitleFont : settings.style.landscapeTitleFont
                label.textColor = settings.style.titleColor
                label.alpha = 0
                return label
            }()
            navTitleLabel.alpha = currentIndex == index ? 1 : 0
            navTitleLabel.textColor = settings.style.titleColor
            titleScrollView.addSubview(navTitleLabel)
            childTitleLabels.append(navTitleLabel)
        }
    }
    
    private func setNavigationViewItemsPosition(updateAlpha: Bool) {
        let distance = distanceValue
        let isPortrait = UIApplication.shared.statusBarOrientation.isPortrait
        let navBarHeight: CGFloat = navigationController!.navigationBar.frame.size.height
        for (index, label) in childTitleLabels.enumerated() {
            if updateAlpha {
                label.alpha = currentIndex == index ? 1 : 0
            }
            label.font = isPortrait ? settings.style.portraitTitleFont : settings.style.landscapeTitleFont
            let viewSize = label.intrinsicContentSize
            let originX = distance - viewSize.width/2 + CGFloat(index) * distance
            let originY = (CGFloat(navBarHeight) - viewSize.height) / 2
            label.frame = CGRect(x: originX, y: originY - 2, width: viewSize.width, height: viewSize.height)
            label.tag = index
        }
        
        let xOffset = distance * CGFloat(currentIndex)
        titleScrollView.contentOffset = CGPoint(x: xOffset, y: 0)
        
        pageControl.numberOfPages = childTitleLabels.count
        pageControl.currentPage = currentIndex
        let viewSize = pageControl.sizeForNumber(ofPages: childTitleLabels.count)
        let originX = distance - viewSize.width / 2
        pageControl.frame = CGRect(x: originX, y: navBarHeight - 10, width: viewSize.width, height: viewSize.height)
    }
    
    private func setAlphaWith(offset: CGFloat, andDistance distance: CGFloat) {
        for (index, label) in childTitleLabels.enumerated() {
            label.alpha = {
                if offset < distance * CGFloat(index) {
                    return (offset - distance * CGFloat(index - 1)) / distance
                }
                else {
                    return 1 - ((offset - distance * CGFloat(index)) / distance)
                }
            }()
        }
    }
    
    private var distanceValue: CGFloat {
        let middle = navigationController!.navigationBar.convert(navigationController!.navigationBar.center, to: titleView)
        return middle.x
    }
}
