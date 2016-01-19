//
//  XLPagerTabStripViewController.swift
//  XLPagerTabStrip
//
//  Created by Santiago on 12/30/15.
//  Copyright © 2015 Xmartlabs. All rights reserved.
//

import Foundation

public struct ChildHeader {
    
    public var title: String
    public var image: UIImage?
    public var highlightedImage: UIImage?
    public var color: UIColor?
    
    public init(title: String) {
        self.title = title
    }
    
    public init(title: String, image: UIImage?) {
        self.init(title: title)
        self.image = image
    }
    
    public init(title: String, image: UIImage?, highlightedImage: UIImage?) {
        self.init(title: title, image: image)
        self.highlightedImage = highlightedImage
    }
    
    public init(title: String, image: UIImage?, highlightedImage: UIImage?, color: UIColor?){
        self.init(title: title, image: image, highlightedImage: highlightedImage)
        self.color = color
    }
}

public protocol XLPagerTabStripChildItem{
    func childHeaderForPagerTabStripViewController(pagerTabStripController: XLPagerTabStripViewController) -> ChildHeader
}

public enum XLPagerTabStripDirection{
    case Left
    case Right
    case None
}

public protocol XLPagerTabStripViewControllerDelegate{
    func pagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex index: Int)
    func pagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex index: Int, withProgressPercentage progressPercentage: Float, indexWasChanged changed: Bool)
}

public protocol XLPagerTabStripViewControllerDataSource{
    func childViewControllersForPagerTabStripViewController(pagerTabStripController: XLPagerTabStripViewController) ->[UIViewController]?
}

public class XLPagerTabStripViewController: UIViewController, UIScrollViewDelegate, XLPagerTabStripViewControllerDataSource, XLPagerTabStripViewControllerDelegate{
    private(set) var pagerTabStripChildViewControllers : [UIViewController]?
    public var containerView: UIScrollView?
    public var delegate: XLPagerTabStripViewControllerDelegate?
    public var datasource: XLPagerTabStripViewControllerDataSource?

    
    private(set) var currentIndex: Int = 0
    public var skipIntermediateViewControllers: Bool = false
    public var isProgressiveIndicator: Bool = false
    public var isElasticIndicatorLimit: Bool = false
    
    private var pagerTabStripChildViewControllersForScrolling : [UIViewController]?
    
    private var lastPageNumber: Int = 0
    private var lastContentOffset: Float = 0.0
    private var pageBeforeRotate: Int = 0
    private var lastSize: CGSize = CGSizeMake(0, 0)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.pagerTabStripViewControllerInit()
    }

    required public init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        self.pagerTabStripViewControllerInit()
    }
    
    func pagerTabStripViewControllerInit(){
        self.delegate = self;
        self.datasource = self;
    }
    
    override public func viewDidLoad(){
        super.viewDidLoad()
        
        if (self.containerView == nil){
            self.containerView = UIScrollView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)))
            self.containerView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.view.addSubview(self.containerView!)
        }
        
        self.containerView?.bounces = true
        self.containerView?.alwaysBounceHorizontal = true
        self.containerView?.alwaysBounceVertical = false
        self.containerView?.scrollsToTop = false
        self.containerView?.delegate = self
        self.containerView?.showsVerticalScrollIndicator = false
        self.containerView?.showsHorizontalScrollIndicator = false
        self.containerView?.pagingEnabled = true
        
        self.pagerTabStripChildViewControllers = self.datasource?.childViewControllersForPagerTabStripViewController(self)
    }
    
    override public func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated)
        self.lastSize = self.containerView!.bounds.size
        self.updateIfNeeded()
    }
    
    override public func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        self.updateIfNeeded()
        switch UIDevice.currentDevice().systemVersion.compare("8.0", options: NSStringCompareOptions.NumericSearch){
            case .OrderedAscending:
                self.view.layoutSubviews()
            default: break
        }

    }
    
    public func moveToViewControllerAtIndex(index: Int){
        self.moveToViewControllerAtIndex(index, animated: true)
    }
    
    public func moveToViewControllerAtIndex(index: Int, animated: Bool){
        if (!self.isViewLoaded() || self.view.window == nil){
            self.currentIndex = index
        }
        else{
            if (animated && self.skipIntermediateViewControllers && abs(self.currentIndex - index) > 1){
                var tmpChildViewControllers = self.pagerTabStripChildViewControllers
                let currentChildVC = self.pagerTabStripChildViewControllers![self.currentIndex]
                let fromIndex = self.currentIndex < index ? index - 1 :index + 1
                let fromChildVC = self.pagerTabStripChildViewControllers![fromIndex]
                tmpChildViewControllers![self.currentIndex] = fromChildVC
                tmpChildViewControllers![fromIndex] = currentChildVC
                pagerTabStripChildViewControllersForScrolling = tmpChildViewControllers
                self.containerView?.contentOffset = CGPointMake(self.pageOffsetForChildIndex(index: fromIndex), 0)
                if((self.navigationController) != nil){
                    self.navigationController?.view.userInteractionEnabled = false;
                }
                else{
                    self.view.userInteractionEnabled = false
                }
                self.containerView?.contentOffset = CGPointMake(self.pageOffsetForChildIndex(index: index), 0)
            }
            else{
                self.containerView?.setContentOffset(CGPointMake(self.pageOffsetForChildIndex(index: index), 0), animated: true)
            }
        }
    }
    
    public func moveToViewController(viewController: UIViewController){
        self.moveToViewControllerAtIndex(self.pagerTabStripChildViewControllers!.indexOf(viewController)!)
    }

    public func moveToViewController(viewController: UIViewController, animated: Bool){
        self.moveToViewControllerAtIndex(self.pagerTabStripChildViewControllers!.indexOf(viewController)!, animated: animated)
    }
    
    //MARK: - XLPagerTabStripViewControllerDataSource
    public func childViewControllersForPagerTabStripViewController(pagerTabStripController: XLPagerTabStripViewController) -> [UIViewController]?{
        assert(false, "Sub-class must implement the XLPagerTabStripViewControllerDataSource childViewControllersForPagerTabStripViewController: method")
        return nil
    }
    
    //MARK: - XLPagerTabStripViewControllerDelegate
    public func pagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex index: Int){
        
    }
    
    public func pagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex index: Int, withProgressPercentage progressPercentage: Float, indexWasChanged changed: Bool){
        
    }
    
    //MARK: - Helpers
    func getPagerTabStripChildViewControllersForScrolling() -> [UIViewController]?{
        if let controllers = self.pagerTabStripChildViewControllersForScrolling{
            return controllers
        }
        
        return pagerTabStripChildViewControllers!
    }
    
    public func updateIfNeeded(){
        if (!CGSizeEqualToSize(self.lastSize, self.containerView!.bounds.size)){
            self.updateContent()
        }
    }
    
    public func scrollDirection() -> XLPagerTabStripDirection{
        if (Float(self.containerView!.contentOffset.x) > self.lastContentOffset){
            return XLPagerTabStripDirection.Left
        }
        else if (Float(self.containerView!.contentOffset.x) < self.lastContentOffset){
            return XLPagerTabStripDirection.Right
        }
        
        return XLPagerTabStripDirection.None
    }
    
    public func canMoveToIndex(index index: Int) -> Bool{
        return (self.currentIndex != index && self.pagerTabStripChildViewControllers?.count > index)
    }

    public func pageOffsetForChildIndex(index index: Int) -> CGFloat{
        return (CGFloat(index) * CGRectGetWidth(self.containerView!.bounds))
    }
    
    public func offsetForChildIndex(index index: Int) -> CGFloat{
        return (CGFloat(index) * CGRectGetWidth(self.containerView!.bounds) + ((CGRectGetWidth(self.containerView!.bounds) - CGRectGetWidth(self.view.bounds)) * 0.5))
    }
    
    enum Exception : ErrorType {
        case RangeException(String)
    }
    
    public func offsetForChildViewController(viewController: UIViewController) throws -> CGFloat{
        if let index = self.pagerTabStripChildViewControllers?.indexOf(viewController){
            return self.offsetForChildIndex(index: index)
        }
        
        throw Exception.RangeException(NSRangeException)
    }
    
    public func pageForContentOffset(contentOffset contentOffset: Float) -> Int{
        let result = self.virtualPageForContentOffset(contentOffset: contentOffset)
        return self.pageForVirtualPage(virtualPage: result)
    }
    
    public func virtualPageForContentOffset(contentOffset contentOffset: Float) -> Int{
        let result: Int = Int((contentOffset + (1.5 * self.pageWidth())) / self.pageWidth())
        return result - 1
    }
    
    public func pageForVirtualPage(virtualPage virtualPage: Int) -> Int{
        if (virtualPage < 0){
            return 0
        }
        if (virtualPage > self.pagerTabStripChildViewControllers!.count - 1){
            return self.pagerTabStripChildViewControllers!.count - 1
        }
        return virtualPage
    }
    
    public func pageWidth() -> Float{
        return Float(CGRectGetWidth(self.containerView!.bounds))
    }
    
    public func scrollPercentage() -> Float{
        if (self.scrollDirection() == .Left || self.scrollDirection() == .None){
            if (fmodf(Float(self.containerView!.contentOffset.x), self.pageWidth()) == 0.0){
                return 1.0
            }
            return fmodf(Float(self.containerView!.contentOffset.x), self.pageWidth() / self.pageWidth())
        }
        return 1 - fmodf(self.containerView!.contentOffset.x >= 0 ? Float(self.containerView!.contentOffset.x) : self.pageWidth() + Float(self.containerView!.contentOffset.x), self.pageWidth()) / self.pageWidth();
    }
    
    public func updateContent(){
        if (!CGSizeEqualToSize(self.lastSize, self.containerView!.bounds.size)){
            if (self.lastSize.width != self.containerView!.bounds.size.width){
                self.lastSize = self.containerView!.bounds.size
                self.containerView?.contentOffset = CGPointMake(self.pageOffsetForChildIndex(index: self.currentIndex), 0)
            }
            else{
                self.lastSize = self.containerView!.bounds.size
            }
        }
        
        let childViewControllers = self.getPagerTabStripChildViewControllersForScrolling()
        self.containerView?.contentSize = CGSizeMake(CGRectGetWidth(self.containerView!.bounds) * CGFloat(childViewControllers!.count), self.containerView!.contentSize.height)
        
        for (index, childController) in childViewControllers!.enumerate(){
            let pageOffsetForChild = self.pageOffsetForChildIndex(index: index)
            if (fabs(self.containerView!.contentOffset.x - pageOffsetForChild) < CGRectGetWidth(self.containerView!.bounds)){
                if (childController.parentViewController == nil){
                    self.addChildViewController(childController)
                    childController.beginAppearanceTransition(true, animated: false)
                    
                    let childPosition = self.offsetForChildIndex(index: index)
                    childController.view.frame = CGRectMake(childPosition, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.containerView!.bounds))
                    childController.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
                    
                    self.containerView?.addSubview(childController.view)
                    childController.didMoveToParentViewController(self)
                    childController.endAppearanceTransition()
                }
                else{
                    let childPosition = self.offsetForChildIndex(index: index)
                    childController.view.frame = CGRectMake(childPosition, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.containerView!.bounds))
                    childController.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
                    
                }
            }
            else{
                if (childController.parentViewController != nil){
                    childController.willMoveToParentViewController(nil)
                    childController.beginAppearanceTransition(false, animated: false)
                    childController.view.removeFromSuperview()
                    childController.removeFromParentViewController()
                    childController.endAppearanceTransition()
                }
            }
        }
        
        let oldCurrentIndex = self.currentIndex
        let virtualPage = self.virtualPageForContentOffset(contentOffset: Float(self.containerView!.contentOffset.x))
        let newCurrentIndex = self.pageForVirtualPage(virtualPage: virtualPage)
        self.currentIndex = newCurrentIndex
        let changeCurrentIndex = newCurrentIndex != oldCurrentIndex
        
        if (self.isProgressiveIndicator){
            // FIXME: - check if delegate implements? pagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex index: Int, withProgressPercentage progressPercentage: Float, indexWasChanged changed: Bool)
            
            let scrollPercentage = self.scrollPercentage()
            if (scrollPercentage > 0){
                var fromIndex = self.currentIndex
                var toIndex = self.currentIndex
                let scrollDirection = self.scrollDirection()
                
                if (scrollDirection == .Left){
                    if (virtualPage > self.getPagerTabStripChildViewControllersForScrolling()!.count - 1){
                        fromIndex = self.getPagerTabStripChildViewControllersForScrolling()!.count - 1
                        toIndex = self.getPagerTabStripChildViewControllersForScrolling()!.count
                    }
                    else{
                        if (scrollPercentage >= 0.5){
                            fromIndex = max(toIndex - 1, 0)
                        }
                        else{
                            toIndex = fromIndex + 1
                        }
                    }
                }
                else if (scrollDirection == .Right){
                    if (virtualPage < 0){
                        fromIndex = 0
                        toIndex = -1
                    }
                    else{
                        if (scrollPercentage > 0.5){
                            fromIndex = min(toIndex + 1, self.getPagerTabStripChildViewControllersForScrolling()!.count - 1)
                        }
                        else{
                            toIndex = fromIndex - 1
                        }
                    }
                }
                self.delegate?.pagerTabStripViewController(self, updateIndicatorFromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: (self.isElasticIndicatorLimit ? scrollPercentage : (toIndex < 0 || toIndex >= self.getPagerTabStripChildViewControllersForScrolling()!.count ? 0 : scrollPercentage)), indexWasChanged: changeCurrentIndex)
            }
        }
        else{
            self.delegate?.pagerTabStripViewController(self, updateIndicatorFromIndex: min(oldCurrentIndex, self.getPagerTabStripChildViewControllersForScrolling()!.count - 1), toIndex: newCurrentIndex)
        }
    }
    
    public func reloadPagerTabStripView()
    {
        if (self.isViewLoaded()){
            for item in self.pagerTabStripChildViewControllers!.enumerate(){
                let childController = item.element
                if (childController.parentViewController != nil){
                    childController.view.removeFromSuperview()
                    childController.willMoveToParentViewController(nil)
                    childController.removeFromParentViewController()
                }
            }
            
            pagerTabStripChildViewControllers = (self.datasource != nil) ? self.datasource?.childViewControllersForPagerTabStripViewController(self) : []
            self.containerView?.contentSize = CGSizeMake(CGRectGetWidth(self.containerView!.bounds) * CGFloat(self.pagerTabStripChildViewControllers!.count), self.containerView!.contentSize.height)
            if (currentIndex >= self.pagerTabStripChildViewControllers!.count){
                currentIndex = pagerTabStripChildViewControllers!.count - 1
            }
            self.containerView?.contentOffset = CGPointMake(self.pageOffsetForChildIndex(index: currentIndex), 0)
            self.updateContent()
        }
    }
    
    //MARK: - UIScrollDelegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.containerView == scrollView){
            self.updateContent()
        }
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if (self.containerView == scrollView){
            lastPageNumber = self.pageForContentOffset(contentOffset: Float(scrollView.contentOffset.x))
            lastContentOffset = Float(scrollView.contentOffset.x)
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if (self.containerView == scrollView && getPagerTabStripChildViewControllersForScrolling() != nil){
            pagerTabStripChildViewControllersForScrolling = nil
            if (navigationController != nil){
                self.navigationController?.view.userInteractionEnabled = true
            }
            else{
                self.view.userInteractionEnabled = true
            }
            self.updateContent()
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
}
