//  PagerTabStripViewController.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2017 Xmartlabs ( http://xmartlabs.com )
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

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo

}

public protocol PagerTabStripDelegate: class {

    func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int)
}

public protocol PagerTabStripIsProgressiveDelegate: PagerTabStripDelegate {

    func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool)
}

public protocol PagerTabStripDataSource: class {

    func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController]
}

// MARK: PagerTabStripViewController

open class PagerTabStripViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak public var containerView: UIScrollView!

    open weak var delegate: PagerTabStripDelegate?
    open weak var datasource: PagerTabStripDataSource?

    open var pagerBehaviour = PagerTabStripBehaviour.progressive(skipIntermediateViewControllers: true, elasticIndicatorLimit: true)

    open private(set) var viewControllers = [UIViewController]()
    open private(set) var currentIndex = 0
    open private(set) var preCurrentIndex = 0 // used *only* to store the index to which move when the pager becomes visible

    open var pageWidth: CGFloat {
        return containerView.bounds.width
    }

    open var scrollPercentage: CGFloat {
        if swipeDirection != .right {
            let module = fmod(containerView.contentOffset.x, pageWidth)
            return module == 0.0 ? 1.0 : module / pageWidth
        }
        return 1 - fmod(containerView.contentOffset.x >= 0 ? containerView.contentOffset.x : pageWidth + containerView.contentOffset.x, pageWidth) / pageWidth
    }

    open var swipeDirection: SwipeDirection {
        if containerView.contentOffset.x > lastContentOffset {
            return .left
        } else if containerView.contentOffset.x < lastContentOffset {
            return .right
        }
        return .none
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        let conteinerViewAux = containerView ?? {
            let containerView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
            containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return containerView
        }()
        containerView = conteinerViewAux
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
        containerView.isPagingEnabled = true
        reloadViewControllers()

        let childController = viewControllers[currentIndex]
        addChildViewController(childController)
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewAppearing = true
        childViewControllers.forEach { $0.beginAppearanceTransition(true, animated: animated) }
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lastSize = containerView.bounds.size
        updateIfNeeded()
        let needToUpdateCurrentChild = preCurrentIndex != currentIndex
        if needToUpdateCurrentChild {
            moveToViewController(at: preCurrentIndex)
        }
        isViewAppearing = false
        childViewControllers.forEach { $0.endAppearanceTransition() }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        childViewControllers.forEach { $0.beginAppearanceTransition(false, animated: animated) }
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        childViewControllers.forEach { $0.endAppearanceTransition() }
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateIfNeeded()
    }

    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    open func moveToViewController(at index: Int, animated: Bool = true) {
        guard isViewLoaded && view.window != nil && currentIndex != index else {
            preCurrentIndex = index
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
            containerView.setContentOffset(CGPoint(x: pageOffsetForChild(at: fromIndex), y: 0), animated: false)
            (navigationController?.view ?? view).isUserInteractionEnabled = !animated
            containerView.setContentOffset(CGPoint(x: pageOffsetForChild(at: index), y: 0), animated: true)
        } else {
            (navigationController?.view ?? view).isUserInteractionEnabled = !animated
            containerView.setContentOffset(CGPoint(x: pageOffsetForChild(at: index), y: 0), animated: animated)
        }
    }

    open func moveTo(viewController: UIViewController, animated: Bool = true) {
        moveToViewController(at: viewControllers.index(of: viewController)!, animated: animated)
    }

    // MARK: - PagerTabStripDataSource

    open func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        assertionFailure("Sub-class must implement the PagerTabStripDataSource viewControllers(for:) method")
        return []
    }

    // MARK: - Helpers

    open func updateIfNeeded() {
        if isViewLoaded && !lastSize.equalTo(containerView.bounds.size) {
            updateContent()
        }
    }

    open func canMoveTo(index: Int) -> Bool {
        return currentIndex != index && viewControllers.count > index
    }

    open func pageOffsetForChild(at index: Int) -> CGFloat {
        return CGFloat(index) * containerView.bounds.width
    }

    open func offsetForChild(at index: Int) -> CGFloat {
        return (CGFloat(index) * containerView.bounds.width) + ((containerView.bounds.width - view.bounds.width) * 0.5)
    }

    open func offsetForChild(viewController: UIViewController) throws -> CGFloat {
        guard let index = viewControllers.index(of: viewController) else {
            throw PagerTabStripError.viewControllerOutOfBounds
        }
        return offsetForChild(at: index)
    }

    open func pageFor(contentOffset: CGFloat) -> Int {
        let result = virtualPageFor(contentOffset: contentOffset)
        return pageFor(virtualPage: result)
    }

    open func virtualPageFor(contentOffset: CGFloat) -> Int {
        return Int((contentOffset + 1.5 * pageWidth) / pageWidth) - 1
    }

    open func pageFor(virtualPage: Int) -> Int {
        if virtualPage < 0 {
            return 0
        }
        if virtualPage > viewControllers.count - 1 {
            return viewControllers.count - 1
        }
        return virtualPage
    }

    open func updateContent() {
        if lastSize.width != containerView.bounds.size.width {
            lastSize = containerView.bounds.size
            containerView.contentOffset = CGPoint(x: pageOffsetForChild(at: currentIndex), y: 0)
        }
        lastSize = containerView.bounds.size

        let pagerViewControllers = pagerTabStripChildViewControllersForScrolling ?? viewControllers
        containerView.contentSize = CGSize(width: containerView.bounds.width * CGFloat(pagerViewControllers.count), height: containerView.contentSize.height)

        for (index, childController) in pagerViewControllers.enumerated() {
            let pageOffsetForChild = self.pageOffsetForChild(at: index)
            if fabs(containerView.contentOffset.x - pageOffsetForChild) < containerView.bounds.width {
                if childController.parent != nil {
                    childController.view.frame = CGRect(x: offsetForChild(at: index), y: 0, width: view.bounds.width, height: containerView.bounds.height)
                    childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                } else {
                    childController.beginAppearanceTransition(true, animated: false)
                    addChildViewController(childController)
                    childController.view.frame = CGRect(x: offsetForChild(at: index), y: 0, width: view.bounds.width, height: containerView.bounds.height)
                    childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    containerView.addSubview(childController.view)
                    childController.didMove(toParentViewController: self)
                    childController.endAppearanceTransition()
                }
            } else {
                if childController.parent != nil {
                    childController.beginAppearanceTransition(false, animated: false)
                    childController.willMove(toParentViewController: nil)
                    childController.view.removeFromSuperview()
                    childController.removeFromParentViewController()
                    childController.endAppearanceTransition()
                }
            }
        }

        let oldCurrentIndex = currentIndex
        let virtualPage = virtualPageFor(contentOffset: containerView.contentOffset.x)
        let newCurrentIndex = pageFor(virtualPage: virtualPage)
        currentIndex = newCurrentIndex
        preCurrentIndex = currentIndex
        let changeCurrentIndex = newCurrentIndex != oldCurrentIndex

        if let progressiveDeledate = self as? PagerTabStripIsProgressiveDelegate, pagerBehaviour.isProgressiveIndicator {

            let (fromIndex, toIndex, scrollPercentage) = progressiveIndicatorData(virtualPage)
            progressiveDeledate.updateIndicator(for: self, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: scrollPercentage, indexWasChanged: changeCurrentIndex)
        } else {
            delegate?.updateIndicator(for: self, fromIndex: min(oldCurrentIndex, pagerViewControllers.count - 1), toIndex: newCurrentIndex)
        }
    }

    open func reloadPagerTabStripView() {
        guard isViewLoaded else { return }
        for childController in viewControllers where childController.parent != nil {
            childController.beginAppearanceTransition(false, animated: false)
            childController.willMove(toParentViewController: nil)
            childController.view.removeFromSuperview()
            childController.removeFromParentViewController()
            childController.endAppearanceTransition()
        }
        reloadViewControllers()
        containerView.contentSize = CGSize(width: containerView.bounds.width * CGFloat(viewControllers.count), height: containerView.contentSize.height)
        if currentIndex >= viewControllers.count {
            currentIndex = viewControllers.count - 1
        }
        preCurrentIndex = currentIndex
        containerView.contentOffset = CGPoint(x: pageOffsetForChild(at: currentIndex), y: 0)
        updateContent()
    }

    // MARK: - UIScrollDelegate

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if containerView == scrollView {
            updateContent()
            lastContentOffset = scrollView.contentOffset.x
        }
    }

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if containerView == scrollView {
            lastPageNumber = pageFor(contentOffset: scrollView.contentOffset.x)
        }
    }

    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if containerView == scrollView {
            pagerTabStripChildViewControllersForScrolling = nil
            (navigationController?.view ?? view).isUserInteractionEnabled = true
            updateContent()
        }
    }

    // MARK: - Orientation

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isViewRotating = true
        pageBeforeRotate = currentIndex
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            guard let me = self else { return }
            me.isViewRotating = false
            me.currentIndex = me.pageBeforeRotate
            me.preCurrentIndex = me.currentIndex
            me.updateIfNeeded()
        }
    }

    // MARK: Private

    private func progressiveIndicatorData(_ virtualPage: Int) -> (Int, Int, CGFloat) {
        let count = viewControllers.count
        var fromIndex = currentIndex
        var toIndex = currentIndex
        let direction = swipeDirection

        if direction == .left {
            if virtualPage > count - 1 {
                fromIndex = count - 1
                toIndex = count
            } else {
                if self.scrollPercentage >= 0.5 {
                    fromIndex = max(toIndex - 1, 0)
                } else {
                    toIndex = fromIndex + 1
                }
            }
        } else if direction == .right {
            if virtualPage < 0 {
                fromIndex = 0
                toIndex = -1
            } else {
                if self.scrollPercentage > 0.5 {
                    fromIndex = min(toIndex + 1, count - 1)
                } else {
                    toIndex = fromIndex - 1
                }
            }
        }
        let scrollPercentage = pagerBehaviour.isElasticIndicatorLimit ? self.scrollPercentage : ((toIndex < 0 || toIndex >= count) ? 0.0 : self.scrollPercentage)
        return (fromIndex, toIndex, scrollPercentage)
    }

    private func reloadViewControllers() {
        guard let dataSource = datasource else {
            fatalError("dataSource must not be nil")
        }
        viewControllers = dataSource.viewControllers(for: self)
        // viewControllers
        guard !viewControllers.isEmpty else {
            fatalError("viewControllers(for:) should provide at least one child view controller")
        }
        viewControllers.forEach { if !($0 is IndicatorInfoProvider) { fatalError("Every view controller provided by PagerTabStripDataSource's viewControllers(for:) method must conform to  InfoProvider") }}

    }

    private var pagerTabStripChildViewControllersForScrolling: [UIViewController]?
    private var lastPageNumber = 0
    private var lastContentOffset: CGFloat = 0.0
    private var pageBeforeRotate = 0
    private var lastSize = CGSize(width: 0, height: 0)
    internal var isViewRotating = false
    internal var isViewAppearing = false

}
