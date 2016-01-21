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


public protocol PagerTabStripChildItem {
    func childHeaderForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> ChildItemInfo
}

public protocol PagerTabStripViewControllerDelegate: class {
    func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) throws
    func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: Float, indexWasChanged: Bool) throws
}

public protocol PagerTabStripViewControllerDataSource: class {
    func childViewControllersForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) ->[UIViewController]
}


//MARK: PagerTabStripViewController

public class PagerTabStripViewController: UIViewController, UIScrollViewDelegate, PagerTabStripViewControllerDataSource, PagerTabStripViewControllerDelegate {
    
    
    @IBOutlet lazy public var containerView: UIScrollView! = { [unowned self] in
        let containerView = UIScrollView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)))
        containerView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        return containerView
    }()
    
    public weak var delegate: PagerTabStripViewControllerDelegate?
    public weak var datasource: PagerTabStripViewControllerDataSource?
    
    public var pagerOptions = PagerTabStripOptions.SkipIntermediateViewControllers.union(.IsProgressiveIndicator).union(.IsElasticIndicatorLimit)
    
    private(set) var pagerTabStripChildViewControllers = [UIViewController]()
    private(set) var currentIndex = 0
    
    public var pageWidth: CGFloat {
        return CGRectGetWidth(containerView.bounds)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
        datasource = self
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        datasource = self
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if containerView.superview == nil {
            view.addSubview(containerView!)
        }
        containerView.bounces = true
        containerView.alwaysBounceHorizontal = true
        containerView.alwaysBounceVertical = false
        containerView.scrollsToTop = false
        containerView.delegate = self
        containerView.showsVerticalScrollIndicator = false
        containerView.showsHorizontalScrollIndicator = false
        containerView.pagingEnabled = true
        guard let dataSource = datasource else {
            fatalError("dataSource must not be nil")
        }
        let childViewControllers = dataSource.childViewControllersForPagerTabStripViewController(self)
        guard childViewControllers.count != 0 else {
            fatalError("childViewControllersForPagerTabStripViewController should provide at least one child view controller")
        }
        pagerTabStripChildViewControllers = childViewControllers
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        lastSize = containerView!.bounds.size
        updateIfNeeded()
    }
    
    override public func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        updateIfNeeded()
    }
    
    public func moveToViewControllerAtIndex(index: Int) {
        moveToViewControllerAtIndex(index, animated: true)
    }
    
    public func moveToViewControllerAtIndex(index: Int, animated: Bool) {
        if !isViewLoaded() || view.window == nil {
            currentIndex = index
        }
        if animated && pagerOptions.contains(.SkipIntermediateViewControllers) && abs(currentIndex - index) > 1 {
            var tmpChildViewControllers = pagerTabStripChildViewControllers
            let currentChildVC = pagerTabStripChildViewControllers[currentIndex]
            let fromIndex = currentIndex < index ? index - 1 : index + 1
            let fromChildVC = pagerTabStripChildViewControllers[fromIndex]
            tmpChildViewControllers[currentIndex] = fromChildVC
            tmpChildViewControllers[fromIndex] = currentChildVC
            pagerTabStripChildViewControllersForScrolling = tmpChildViewControllers
            containerView.setContentOffset(CGPointMake(pageOffsetForChildIndex(index: fromIndex), 0), animated: false)
            (navigationController?.view ?? view).userInteractionEnabled = false
            containerView.setContentOffset(CGPointMake(pageOffsetForChildIndex(index: index), 0), animated: true)
        }
        else {
            containerView.setContentOffset(CGPointMake(pageOffsetForChildIndex(index: index), 0), animated: animated)
        }
    }
    
    public func moveToViewController(viewController: UIViewController) {
        moveToViewControllerAtIndex(pagerTabStripChildViewControllers.indexOf(viewController)!)
    }

    public func moveToViewController(viewController: UIViewController, animated: Bool) {
        moveToViewControllerAtIndex(pagerTabStripChildViewControllers.indexOf(viewController)!, animated: animated)
    }
    
    //MARK: - PagerTabStripViewControllerDataSource
    
    public func childViewControllersForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        assertionFailure("Sub-class must implement the PagerTabStripViewControllerDataSource childViewControllersForPagerTabStripViewController: method")
        return []
    }
    
    //MARK: - PagerTabStripViewControllerDelegate
    
    public func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) throws {
    }
    
    public func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: Float, indexWasChanged: Bool) throws {
    }
    
    //MARK: - Helpers
    
    public func updateIfNeeded() {
        if !CGSizeEqualToSize(lastSize, containerView!.bounds.size){
            updateContent()
        }
    }
    
    public func swipeDirection() -> SwipeDirection {
        if containerView.contentOffset.x > lastContentOffset {
            return .Left
        }
        else if containerView.contentOffset.x < lastContentOffset {
            return .Right
        }
        return .None
    }
    
    public func canMoveToIndex(index index: Int) -> Bool{
        return currentIndex != index && pagerTabStripChildViewControllers.count > index
    }

    public func pageOffsetForChildIndex(index index: Int) -> CGFloat{
        return CGFloat(index) * CGRectGetWidth(containerView.bounds)
    }
    
    public func offsetForChildIndex(index index: Int) -> CGFloat{
        return (CGFloat(index) * CGRectGetWidth(containerView.bounds)) + ((CGRectGetWidth(containerView.bounds) - CGRectGetWidth(view.bounds)) * 0.5)
    }
    
    public func offsetForChildViewController(viewController: UIViewController) throws -> CGFloat{
        guard let index = self.pagerTabStripChildViewControllers.indexOf(viewController) else {
            throw PagerTabStripError.ViewControllerNotContainedInPagerTabStripChildViewControllers
        }
        return offsetForChildIndex(index: index)
    }
    
    public func pageForContentOffset(contentOffset contentOffset: CGFloat) -> Int{
        let result = self.virtualPageForContentOffset(contentOffset: contentOffset)
        return self.pageForVirtualPage(virtualPage: result)
    }
    
    public func virtualPageForContentOffset(contentOffset contentOffset: CGFloat) -> Int{
        return Int((contentOffset + 1.5 * pageWidth) / pageWidth) - 1
    }
    
    public func pageForVirtualPage(virtualPage virtualPage: Int) -> Int{
        if virtualPage < 0 {
            return 0
        }
        if virtualPage > pagerTabStripChildViewControllers.count - 1 { return pagerTabStripChildViewControllers.count - 1 }
        return virtualPage
    }
    
    public func scrollPercentage() -> CGFloat{
        if swipeDirection() != .Right {
            if fmod(containerView.contentOffset.x, pageWidth) == 0.0{
                return 1.0
            }
            return fmod(containerView.contentOffset.x, pageWidth) / pageWidth
        }
        return 1 - fmod(containerView.contentOffset.x >= 0 ? containerView!.contentOffset.x : pageWidth + containerView.contentOffset.x, pageWidth) / pageWidth;
    }
    
    public func updateContent() {
        if !CGSizeEqualToSize(lastSize, containerView.bounds.size) {
            if lastSize.width != containerView.bounds.size.width {
                lastSize = containerView.bounds.size
                containerView.contentOffset = CGPointMake(pageOffsetForChildIndex(index: currentIndex), 0)
            }
            else {
                lastSize = containerView.bounds.size
            }
        }
        
        let childViewControllers = getPagerTabStripChildViewControllersForScrolling
        containerView.contentSize = CGSizeMake(CGRectGetWidth(containerView.bounds) * CGFloat(childViewControllers.count), containerView.contentSize.height)
        
        for (index, childController) in childViewControllers.enumerate(){
            let pageOffsetForChild = pageOffsetForChildIndex(index: index)
            if fabs(containerView.contentOffset.x - pageOffsetForChild) < CGRectGetWidth(containerView.bounds) {
                if childController.parentViewController == nil {
                    addChildViewController(childController)
                    childController.beginAppearanceTransition(true, animated: false)
                    
                    let childPosition = offsetForChildIndex(index: index)
                    childController.view.frame = CGRectMake(childPosition, 0, CGRectGetWidth(view.bounds), CGRectGetHeight(containerView.bounds))
                    childController.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
                    
                    containerView.addSubview(childController.view)
                    childController.didMoveToParentViewController(self)
                    childController.endAppearanceTransition()
                }
                else {
                    let childPosition = offsetForChildIndex(index: index)
                    childController.view.frame = CGRectMake(childPosition, 0, CGRectGetWidth(view.bounds), CGRectGetHeight(containerView.bounds))
                    childController.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
                    
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
        let virtualPage = virtualPageForContentOffset(contentOffset: containerView.contentOffset.x)
        let newCurrentIndex = pageForVirtualPage(virtualPage: virtualPage)
        currentIndex = newCurrentIndex
        let changeCurrentIndex = newCurrentIndex != oldCurrentIndex
        
        if pagerOptions.contains(.IsProgressiveIndicator) {
            // FIXME: - check if delegate implements? pagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex index: Int, withProgressPercentage progressPercentage: Float, indexWasChanged changed: Bool)
            
            let scrollPercentage = self.scrollPercentage()
            if scrollPercentage > 0 {
                var fromIndex = currentIndex
                var toIndex = currentIndex
                let direction = swipeDirection()
                
                if direction == .Left {
                    if virtualPage > getPagerTabStripChildViewControllersForScrolling.count - 1 {
                        fromIndex = getPagerTabStripChildViewControllersForScrolling.count - 1
                        toIndex = getPagerTabStripChildViewControllersForScrolling.count
                    }
                    else {
                        if scrollPercentage >= 0.5 {
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
                        if scrollPercentage > 0.5 {
                            fromIndex = min(toIndex + 1, getPagerTabStripChildViewControllersForScrolling.count - 1)
                        }
                        else {
                            toIndex = fromIndex - 1
                        }
                    }
                }
                
                try! delegate?.pagerTabStripViewController(self, updateIndicatorFromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: Float(pagerOptions.contains(.IsElasticIndicatorLimit) ? scrollPercentage : (toIndex < 0 || toIndex >= getPagerTabStripChildViewControllersForScrolling.count ? CGFloat(0) : scrollPercentage)), indexWasChanged: changeCurrentIndex)
            }
        }
        else{
            try! delegate?.pagerTabStripViewController(self, updateIndicatorFromIndex: min(oldCurrentIndex, getPagerTabStripChildViewControllersForScrolling.count - 1), toIndex: newCurrentIndex)
        }
    }
    
    public func reloadPagerTabStripView() {
        if isViewLoaded() {
            for childController in pagerTabStripChildViewControllers {
                if let _ = childController.parentViewController {
                    childController.view.removeFromSuperview()
                    childController.willMoveToParentViewController(nil)
                    childController.removeFromParentViewController()
                }
            }
            
            pagerTabStripChildViewControllers = datasource?.childViewControllersForPagerTabStripViewController(self) ?? []
            containerView.contentSize = CGSizeMake(CGRectGetWidth(containerView.bounds) * CGFloat(pagerTabStripChildViewControllers.count), containerView.contentSize.height)
            if currentIndex >= pagerTabStripChildViewControllers.count {
                currentIndex = pagerTabStripChildViewControllers.count - 1
            }
            containerView.contentOffset = CGPointMake(pageOffsetForChildIndex(index: currentIndex), 0)
            updateContent()
        }
    }
    
    //MARK: - UIScrollDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if containerView == scrollView {
            updateContent()
        }
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if containerView == scrollView {
            lastPageNumber = pageForContentOffset(contentOffset: scrollView.contentOffset.x)
            lastContentOffset = scrollView.contentOffset.x
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if containerView == scrollView {
            pagerTabStripChildViewControllersForScrolling = nil
            if let navigationController = navigationController {
                navigationController.view.userInteractionEnabled = true
            }
            else{
                view.userInteractionEnabled = true
            }
            updateContent()
        }
    }
    
    //MARK: - Orientation
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        pageBeforeRotate = currentIndex
        coordinator.animateAlongsideTransition(nil) { (context) -> Void in
            self.currentIndex = self.pageBeforeRotate
            self.updateIfNeeded()
        }
    }
    
    public override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        pageBeforeRotate = currentIndex
    }
    
    
    private var pagerTabStripChildViewControllersForScrolling : [UIViewController]?
    private var getPagerTabStripChildViewControllersForScrolling : [UIViewController] {
        return pagerTabStripChildViewControllersForScrolling ?? pagerTabStripChildViewControllers
    }
    private var lastPageNumber = 0
    private var lastContentOffset: CGFloat = 0.0
    private var pageBeforeRotate = 0
    private var lastSize = CGSizeMake(0, 0)
    
}
