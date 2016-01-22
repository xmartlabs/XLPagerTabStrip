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

public class TwitterPagerTabStripViewController: PagerTabStripViewController, PagerTabStripViewControllerDataSource, PagerTabStripViewControllerIsProgressiveDelegate {
    lazy var navigationView: UIView = {
       let navigationView = UIView()
        navigationView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        return navigationView
    }()
    
    lazy var navigationScrollView: UIScrollView = { [unowned self] in
        let navigationScrollView = UIScrollView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44))
        navigationScrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        navigationScrollView.bounces = true
        navigationScrollView.scrollsToTop = false
        navigationScrollView.delegate = self
        navigationScrollView.showsVerticalScrollIndicator = false
        navigationScrollView.showsHorizontalScrollIndicator = false
        navigationScrollView.pagingEnabled = true
        navigationScrollView.userInteractionEnabled = false
        navigationScrollView.alwaysBounceHorizontal = true
        navigationScrollView.alwaysBounceVertical = false
        return navigationScrollView
    }()
    var navigationPageControl: FXPageControl = {
        let navigationPageControl = FXPageControl()
        navigationPageControl.backgroundColor = .clearColor()
        navigationPageControl.dotSize = 3.8
        navigationPageControl.dotSpacing = 4.0
        navigationPageControl.dotColor = UIColor(white: 1, alpha: 0.4)
        navigationPageControl.selectedDotColor = .whiteColor()
        navigationPageControl.userInteractionEnabled = false
        return navigationPageControl
    }()
    var navigationItemsViews = [UIView]()
    
    var landscapeTitleFont = UIFont.systemFontOfSize(14)
    var portraitTitleFont = UIFont.systemFontOfSize(18)
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        datasource = self
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if navigationView.superview == nil {
            navigationItem.titleView = navigationView
        }
        
        navigationView.addObserver(self, forKeyPath: "frame", options: [.New, .Old], context: nil)
        navigationView.frame = CGRectMake(0, 0, CGRectGetWidth(navigationController!.navigationBar.frame), CGRectGetHeight(navigationController!.navigationBar.frame))
        
        if navigationScrollView.superview == nil {
            navigationView.addSubview(navigationScrollView)
        }
        if navigationPageControl.superview == nil {
            navigationView.addSubview(navigationPageControl)
        }
        
        reloadNavigationViewItems()
    }
    
    public override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        guard isViewLoaded() else { return }
        
        reloadNavigationViewItems()
        setNavigationViewItemsPosition()
    }
    
    // MARK: - PagerTabStripViewControllerDelegate
    
    public func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) throws {
        
    }
    
    public func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) throws {
        let distance = getDistanceValue()
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
        
        navigationScrollView.contentOffset = CGPointMake(xOffset, 0)
        setAlphaWithOffset(xOffset)
        navigationPageControl.currentPage = currentIndex
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard object as! UIView == navigationView && keyPath! == "frame" && change![NSKeyValueChangeKindKey] as! UInt == NSKeyValueChange.Setting.rawValue else { return }
        
        let oldRect = change![NSKeyValueChangeOldKey]!.CGRectValue
        let newRect = change![NSKeyValueChangeOldKey]!.CGRectValue
        guard !CGRectEqualToRect(oldRect, newRect) else { return }
        
        navigationScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(navigationView.frame), CGRectGetHeight(navigationScrollView.frame))
        setNavigationViewItemsPosition()
    }
    
    deinit {
        navigationView.removeObserver(self, forKeyPath: "frame")
    }
    
    // MARK: - Helpers
    
    func reloadNavigationViewItems() {
        for item in navigationItemsViews {
            item.removeFromSuperview()
        }
        
        navigationItemsViews.removeAll()
        
        for (index, item) in viewControllers.enumerate() {
            let child = item as! PagerTabStripChildItem
            let childHeader = child.childHeaderForPagerTabStripViewController(self)
            
            let navTitleLabel = createNewLabelWithText(childHeader.title)
            navTitleLabel.alpha = currentIndex == index ? 1 : 0
            navTitleLabel.textColor = childHeader.color ?? .whiteColor()
            navigationScrollView.addSubview(navTitleLabel)
            navigationItemsViews.append(navTitleLabel)
        }
    }
    
    private func setNavigationViewItemsPosition() {
        setNavigationViewItemsPosition(true)
    }
    
    private func setNavigationViewItemsPosition(updateAlpha: Bool) {
        let distance = getDistanceValue()
        let isPortrait = UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)
        let labelHeightSpace: CGFloat = isPortrait ? 34 : 25
        for (index, view) in navigationItemsViews.enumerate() {
            let label = view as! UILabel
            if updateAlpha {
                label.alpha = currentIndex == index ? 1 : 0
            }
            label.font = isPortrait ? portraitTitleFont : landscapeTitleFont
            let viewSize = getLabelSize(label)
            let originX = distance - viewSize.width/2 + CGFloat(index) * distance
            let originY = (CGFloat(labelHeightSpace) - viewSize.height) / 2
            label.frame = CGRectMake(originX, originY + 2, viewSize.width, viewSize.height)
            label.tag = index
        }
        
        let xOffset = distance * CGFloat(currentIndex)
        navigationScrollView.contentOffset = CGPointMake(xOffset, 0)
        
        navigationPageControl.numberOfPages = navigationItemsViews.count
        navigationPageControl.currentPage = currentIndex
        let viewSize = navigationPageControl.sizeForNumberOfPages(navigationItemsViews.count)
        let originX = distance - viewSize.width/2
        navigationPageControl.frame = CGRectMake(originX, labelHeightSpace, viewSize.width, viewSize.height)
    }
    
    private func setAlphaWithOffset(xOffset: CGFloat) {
        let distance = getDistanceValue()
        for (index, view) in navigationItemsViews.enumerate() {
            var alpha: CGFloat = 0
            if xOffset < distance * CGFloat(index) {
                alpha = (xOffset - distance * CGFloat(index - 1)) / distance
            }
            else {
                alpha = 1 - ((xOffset - distance * CGFloat(index)) / distance)
            }
            view.alpha = alpha
        }
    }
    
    private func createNewLabelWithText(text :String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = landscapeTitleFont
        label.textColor = .whiteColor()
        label.alpha = 0
        return label
    }
    
    private func getLabelSize(label: UILabel) -> CGSize {
        return (label.text! as NSString).sizeWithAttributes([NSFontAttributeName : label.font])
    }
    
    private func getDistanceValue() -> CGFloat {
        let middle = navigationController?.navigationBar .convertPoint(navigationController!.navigationBar.center, toView: navigationView)
        return middle!.x
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setNavigationViewItemsPosition(false)
    }
}
