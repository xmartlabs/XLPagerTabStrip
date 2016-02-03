//  PagerTabStripViewController.swift
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


// MARK: Protocols

public protocol IndicatorInfoProvider {
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo
}

public protocol PagerTabStripDelegate: class {
    
    func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int)
}

public protocol PagerTabStripIsProgressiveDelegate : PagerTabStripDelegate {

    func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool)
}

public protocol PagerTabStripDataSource: class {
    
    func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController]
}


//MARK: PagerTabStripViewController

public class PagerTabStripViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet lazy public var containerView: UIScrollView! = { [unowned self] in
        let containerView = UIScrollView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)))
        containerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        return containerView
    }()
    
    public weak var delegate: PagerTabStripDelegate?
    public weak var datasource: PagerTabStripDataSource?
    
    public var pagerBehaviour = PagerTabStripBehaviour.Progressive(skipIntermediateViewControllers: true, elasticIndicatorLimit: true)
    
    public private(set) var viewControllers = [UIViewController]()
    public private(set) var currentIndex = 0
    
    public var pageWidth: CGFloat {
        return CGRectGetWidth(containerView.bounds)
    }
    
    public var scrollPercentage: CGFloat {
        if swipeDirection != .Right {
            let module = fmod(containerView.contentOffset.x, pageWidth)
            return module == 0.0 ? 1.0 : module / pageWidth
        }
        return 1 - fmod(containerView.contentOffset.x >= 0 ? containerView.contentOffset.x : pageWidth + containerView.contentOffset.x, pageWidth) / pageWidth
    }
    
    public var swipeDirection: SwipeDirection {
        if containerView.contentOffset.x > lastContentOffset {
            return .Left
        }
        else if containerView.contentOffset.x < lastContentOffset {
            return .Right
        }
        return .None
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if containerView.superview == nil {
            view.addSubview(containerView)
        }
        containerView.bounces = true
        containerView.alwaysBounceHorizontal = true
        containerView.alwaysBounceVertical = false
        containerView.scrollsToTop = false
        containerView.delegate = self
        containerView.showsVerticalScrollIndicator = false
        containerView.showsHorizontalScrollIndicator = false
        containerView.pagingEnabled = true
        reloadViewControllers()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        isViewAppearing = true
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        lastSize = containerView.bounds.size
        updateIfNeeded()
        isViewAppearing = false
    }
    
    override public func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        updateIfNeeded()
    }
    
    public func moveToViewControllerAtIndex(index: Int, animated: Bool = true) {
        guard isViewLoaded() && view.window != nil else {
            currentIndex = index
            return
        }
        if animated && pagerBehaviour.skipIntermediateViewControllers && abs(currentIndex - index) > 1 {
            var tmpViewControllers = viewControllers
            let currentChildVC = viewControllers[currentIndex]
            let fromIndex = currentIndex < index ? index - 1 : index + 1
            let fromChildVC = viewControllers[fromIndex]
            tmpViewControllers[currentIndex] = fromChildVC
            tmpViewControllers[fromIndex] = currentChildVC
            pagerTabStripChildViewControllersForScrolling = tmpViewControllers
            containerView.setContentOffset(CGPointMake(pageOffsetForChildIndex(index: fromIndex), 0), animated: false)
            (navigationController?.view ?? view).userInteractionEnabled = false
            containerView.setContentOffset(CGPointMake(pageOffsetForChildIndex(index: index), 0), animated: true)
        }
        else {
            containerView.setContentOffset(CGPointMake(pageOffsetForChildIndex(index: index), 0), animated: animated)
        }
    }
    
    public func moveToViewController(viewController: UIViewController, animated: Bool = true) {
        moveToViewControllerAtIndex(viewControllers.indexOf(viewController)!, animated: animated)
    }
    
    //MARK: - PagerTabStripDataSource
    
    public func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        assertionFailure("Sub-class must implement the PagerTabStripDataSource viewControllersForPagerTabStrip: method")
        return []
    }
    
    //MARK: - Helpers
    
    public func updateIfNeeded() {
        if isViewLoaded() && !CGSizeEqualToSize(lastSize, containerView.bounds.size){
            updateContent()
        }
    }
    
    public func canMoveToIndex(index index: Int) -> Bool {
        return currentIndex != index && viewControllers.count > index
    }

    public func pageOffsetForChildIndex(index index: Int) -> CGFloat {
        return CGFloat(index) * CGRectGetWidth(containerView.bounds)
    }
    
    public func offsetForChildIndex(index: Int) -> CGFloat{
        return (CGFloat(index) * CGRectGetWidth(containerView.bounds)) + ((CGRectGetWidth(containerView.bounds) - CGRectGetWidth(view.bounds)) * 0.5)
    }
    
    public func offsetForChildViewController(viewController: UIViewController) throws -> CGFloat{
        guard let index = viewControllers.indexOf(viewController) else {
            throw PagerTabStripError.ViewControllerNotContainedInPagerTabStrip
        }
        return offsetForChildIndex(index)
    }
    
    public func pageForContentOffset(contentOffset: CGFloat) -> Int {
        let result = virtualPageForContentOffset(contentOffset)
        return pageForVirtualPage(result)
    }
    
    public func virtualPageForContentOffset(contentOffset: CGFloat) -> Int {
        return Int((contentOffset + 1.5 * pageWidth) / pageWidth) - 1
    }
    
    public func pageForVirtualPage(virtualPage: Int) -> Int{
        if virtualPage < 0 {
            return 0
        }
        if virtualPage > viewControllers.count - 1 {
            return viewControllers.count - 1
        }
        return virtualPage
    }
    
    public func updateContent() {
        if lastSize.width != containerView.bounds.size.width {
            lastSize = containerView.bounds.size
            containerView.contentOffset = CGPointMake(pageOffsetForChildIndex(index: currentIndex), 0)
        }
        lastSize = containerView.bounds.size
        
        let pagerViewControllers = pagerTabStripChildViewControllersForScrolling ?? viewControllers
        containerView.contentSize = CGSizeMake(CGRectGetWidth(containerView.bounds) * CGFloat(pagerViewControllers.count), containerView.contentSize.height)
        
        for (index, childController) in pagerViewControllers.enumerate() {
            let pageOffsetForChild = pageOffsetForChildIndex(index: index)
            if fabs(containerView.contentOffset.x - pageOffsetForChild) < CGRectGetWidth(containerView.bounds) {
                if let _ = childController.parentViewController {
                    childController.view.frame = CGRectMake(offsetForChildIndex(index), 0, CGRectGetWidth(view.bounds), CGRectGetHeight(containerView.bounds))
                    childController.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
                }
                else {
                    addChildViewController(childController)
                    childController.beginAppearanceTransition(true, animated: false)
                    childController.view.frame = CGRectMake(offsetForChildIndex(index), 0, CGRectGetWidth(view.bounds), CGRectGetHeight(containerView.bounds))
                    childController.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
                    containerView.addSubview(childController.view)
                    childController.didMoveToParentViewController(self)
                    childController.endAppearanceTransition()
                }
            }
            else {
                if let _ = childController.parentViewController {
                    childController.willMoveToParentViewController(nil)
                    childController.beginAppearanceTransition(false, animated: false)
                    childController.view.removeFromSuperview()
                    childController.removeFromParentViewController()
                    childController.endAppearanceTransition()
                }
            }
        }
        
        let oldCurrentIndex = currentIndex
        let virtualPage = virtualPageForContentOffset(containerView.contentOffset.x)
        let newCurrentIndex = pageForVirtualPage(virtualPage)
        currentIndex = newCurrentIndex
        let changeCurrentIndex = newCurrentIndex != oldCurrentIndex
        
        if let progressiveDeledate = self as? PagerTabStripIsProgressiveDelegate where pagerBehaviour.isProgressiveIndicator {
            
            let (fromIndex, toIndex, scrollPercentage) = progressiveIndicatorData(virtualPage)
            progressiveDeledate.pagerTabStripViewController(self, updateIndicatorFromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: scrollPercentage, indexWasChanged: changeCurrentIndex)
        }
        else{
            delegate?.pagerTabStripViewController(self, updateIndicatorFromIndex: min(oldCurrentIndex, pagerViewControllers.count - 1), toIndex: newCurrentIndex)
        }
    }
        
    public func reloadPagerTabStripView() {
        guard isViewLoaded() else { return }
        for childController in viewControllers {
            if let _ = childController.parentViewController {
                childController.view.removeFromSuperview()
                childController.willMoveToParentViewController(nil)
                childController.removeFromParentViewController()
            }
        }
        reloadViewControllers()
        containerView.contentSize = CGSizeMake(CGRectGetWidth(containerView.bounds) * CGFloat(viewControllers.count), containerView.contentSize.height)
        if currentIndex >= viewControllers.count {
            currentIndex = viewControllers.count - 1
        }
        containerView.contentOffset = CGPointMake(pageOffsetForChildIndex(index: currentIndex), 0)
        updateContent()
    }
    
    //MARK: - UIScrollDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if containerView == scrollView {
            updateContent()
        }
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if containerView == scrollView {
            lastPageNumber = pageForContentOffset(scrollView.contentOffset.x)
            lastContentOffset = scrollView.contentOffset.x
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if containerView == scrollView {
            pagerTabStripChildViewControllersForScrolling = nil
            (navigationController?.view ?? view).userInteractionEnabled = true
            updateContent()
        }
    }
    
    //MARK: - Orientation
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        isViewRotating = true
        pageBeforeRotate = currentIndex
        coordinator.animateAlongsideTransition(nil) { [weak self] _ in
            guard let me = self else { return }
            me.isViewRotating = false
            me.currentIndex = me.pageBeforeRotate
            me.updateIfNeeded()
        }
    }
    
    
    //MARK: Private
    
    private func progressiveIndicatorData(virtualPage: Int) -> (Int, Int, CGFloat) {
        let count = viewControllers.count
        var fromIndex = currentIndex
        var toIndex = currentIndex
        let direction = swipeDirection
        
        if direction == .Left {
            if virtualPage > count - 1 {
                fromIndex = count - 1
                toIndex = count
            }
            else {
                if self.scrollPercentage >= 0.5 {
                    fromIndex = max(toIndex - 1, 0)
                }
                else {
                    toIndex = fromIndex + 1
                }
            }
        }
        else if direction == .Right {
            if virtualPage < 0 {
                fromIndex = 0
                toIndex = -1
            }
            else {
                if self.scrollPercentage > 0.5 {
                    fromIndex = min(toIndex + 1, count - 1)
                }
                else {
                    toIndex = fromIndex - 1
                }
            }
        }
        let scrollPercentage = pagerBehaviour.isElasticIndicatorLimit ? self.scrollPercentage : ((toIndex < 0 || toIndex >= count) ? 0.0 : self.scrollPercentage)
        return (fromIndex, toIndex, scrollPercentage)
    }
    
    private func reloadViewControllers(){
        guard let dataSource = datasource else {
            fatalError("dataSource must not be nil")
        }
        viewControllers = dataSource.viewControllersForPagerTabStrip(self)
        // viewControllers
        guard viewControllers.count != 0 else {
            fatalError("viewControllersForPagerTabStrip should provide at least one child view controller")
        }
        viewControllers.forEach { if !($0 is IndicatorInfoProvider) { fatalError("Every view controller provided by PagerTabStripDataSource's viewControllersForPagerTabStrip method must conform to  InfoProvider") }}

    }
    
    private var pagerTabStripChildViewControllersForScrolling : [UIViewController]?
    private var lastPageNumber = 0
    private var lastContentOffset: CGFloat = 0.0
    private var pageBeforeRotate = 0
    private var lastSize = CGSizeMake(0, 0)
    internal var isViewRotating = false
    internal var isViewAppearing = false
    
}
