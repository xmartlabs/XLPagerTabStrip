//  ButtonBarPagerTabStripViewController.swift
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

public class ButtonBarPagerTabStripViewController: PagerTabStripViewController, PagerTabStripViewControllerDataSource, PagerTabStripViewControllerIsProgressiveDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    public var changeCurrentIndex: ((oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, animated: Bool) -> Void)? = { _ in }
    public var changeCurrentIndexProgressive: ((oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void)? = { _ in }
    
    @IBOutlet public lazy var buttonBarView: ButtonBarView! = { [unowned self] in
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 35, 0, 35)
        
        let buttonBar: ButtonBarView = ButtonBarView(frame: CGRectMake(0, 0, self.view.frame.size.width, 44), collectionViewLayout: flowLayout)
        buttonBar.backgroundColor = .orangeColor()
        buttonBar.selectedBar.backgroundColor = .blackColor()
        buttonBar.autoresizingMask = .FlexibleWidth
        
        var bundle = NSBundle(forClass: ButtonBarView.self)
        if let url = bundle.URLForResource("XLPagerTabStrip", withExtension: "bundle") {
            bundle = NSBundle(URL: url)!
        }
        
        buttonBar.registerNib(UINib(nibName: "ButtonCell", bundle: bundle), forCellWithReuseIdentifier: "Cell")
        var newContainerViewFrame = self.containerView.frame
        newContainerViewFrame.origin.y = 44
        newContainerViewFrame.size.height = self.containerView.frame.size.height - (44 - self.containerView.frame.origin.y)
        self.containerView.frame = newContainerViewFrame
        return buttonBar
    }()
    
    lazy private var cachedCellWidths: [CGFloat]? = { [unowned self] in
        return self.calculateWidths()
    }()
    
    private var shouldUpdateButtonBarView = true
    private var isViewAppearing = false
    private var isViewRotating = false
    
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if buttonBarView.superview == nil {
            view.addSubview(buttonBarView)
        }
        if buttonBarView.delegate == nil {
            buttonBarView.delegate = self
        }
        if buttonBarView.dataSource == nil {
            buttonBarView.dataSource = self
        }
        
        buttonBarView.labelFont = UIFont.boldSystemFontOfSize(18)
        buttonBarView.leftRightMargin = 8
        buttonBarView.scrollsToTop = false
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .Horizontal
        buttonBarView.showsHorizontalScrollIndicator = false
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        buttonBarView.layoutIfNeeded()
        isViewAppearing = true
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        isViewAppearing = true
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard isViewAppearing || isViewRotating else { return }
        
        cachedCellWidths = calculateWidths()
        let flowLayout = buttonBarView.collectionViewLayout
        flowLayout.invalidateLayout()
        
        buttonBarView.layoutIfNeeded()
        
//        buttonBarView.moveToIndex(currentIndex, animated: false, swipeDirection: .None, pagerScroll: .ScrollOnlyIfOutOfScreen)
    }
    
    // MARK: - View Rotation
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        isViewRotating = true
        coordinator.animateAlongsideTransition(nil) { (context) -> Void in
            self.isViewRotating = false
        }
    }
    
    // MARK: - Public Methods
    
    public override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        
        if isViewLoaded() {
            buttonBarView.reloadData()
            cachedCellWidths = calculateWidths()
            buttonBarView.moveToIndex(currentIndex, animated: false, swipeDirection: .None, pagerScroll: .YES)
        }
    }
    
    public func calculateStretchedCellWidths(minimumCellWidths: Array<NSNumber>, suggestedStretchedCellWidth: CGFloat, previousNumberOfLargeCells: Int) -> CGFloat {
        var numberOfLargeCells = 0
        var totalWidthOfLargeCells: CGFloat = 0
        
        for minimumCellWidthValue in minimumCellWidths {
            let minimumCellWidth = minimumCellWidthValue.floatValue
            if CGFloat(minimumCellWidth) > suggestedStretchedCellWidth {
                totalWidthOfLargeCells += CGFloat(minimumCellWidth)
                numberOfLargeCells++
            }
        }
        
        guard numberOfLargeCells > previousNumberOfLargeCells else { return suggestedStretchedCellWidth }
        
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout
        let collectionViewAvailiableWidth = buttonBarView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        let numberOfCells = minimumCellWidths.count
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumInteritemSpacing
        
        let numberOfSmallCells = numberOfCells - numberOfLargeCells
        let newSuggestedStretchedCellWidth = (collectionViewAvailiableWidth - totalWidthOfLargeCells - cellSpacingTotal) / CGFloat(numberOfSmallCells)
        
        return calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: newSuggestedStretchedCellWidth, previousNumberOfLargeCells: numberOfLargeCells)
    }
    
    public func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) throws {
        guard shouldUpdateButtonBarView else { return }
        
        let direction: SwipeDirection = (toIndex < fromIndex) ? .Right : .Left
        buttonBarView.moveToIndex(toIndex, animated: true, swipeDirection: direction, pagerScroll: .YES)
        if let changeCurrentIndex = changeCurrentIndex {
            let oldCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex != fromIndex ? fromIndex : toIndex, inSection: 0)) as? ButtonBarViewCell
            let newCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0)) as? ButtonBarViewCell
            changeCurrentIndex(oldCell: oldCell, newCell: newCell, animated: true)
        }
    }
    
    public func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) throws {
        guard shouldUpdateButtonBarView else { return }
        
        buttonBarView.moveFromIndex(fromIndex, toIndex: toIndex, progressPercentage: progressPercentage, pagerScroll: .YES)
        if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
            let oldCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex != fromIndex ? fromIndex : toIndex, inSection: 0)) as? ButtonBarViewCell
            let newCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0)) as? ButtonBarViewCell
            changeCurrentIndexProgressive(oldCell: oldCell, newCell: newCell, progressPercentage: progressPercentage, changeCurrentIndex: indexWasChanged, animated: true)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayut
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard cachedCellWidths?.count > indexPath.row else { return CGSizeZero }
        
        if let cellWidthValue = cachedCellWidths?[indexPath.row] {
            return CGSizeMake(cellWidthValue, collectionView.frame.size.height)
        }
        
        return CGSizeZero
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.item != currentIndex else { return }
        
        buttonBarView.moveToIndex(indexPath.item, animated: true, swipeDirection: .None, pagerScroll: .YES)
        shouldUpdateButtonBarView = false
        
        let oldCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0)) as! ButtonBarViewCell
        let newCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: indexPath.item, inSection: 0)) as! ButtonBarViewCell
        if pagerOptions.contains(.IsProgressiveIndicator) {
            if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
                changeCurrentIndexProgressive(oldCell: oldCell, newCell: newCell, progressPercentage: 1, changeCurrentIndex: true, animated: true)
            }
        }
        else {
            if let changeCurrentIndex = changeCurrentIndex {
                changeCurrentIndex(oldCell: oldCell, newCell: newCell, animated: true)
            }
        }
        
        moveToViewControllerAtIndex(indexPath.item)
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as? ButtonBarViewCell else {
            fatalError("UICollectionViewCell should be or extend XLButtonBarViewCell")
        }
        
        let childController = viewControllers[indexPath.item] as? PagerTabStripChildItem
        
        cell.label.text = childController?.childHeaderForPagerTabStripViewController(self).title
        if let image = childController?.childHeaderForPagerTabStripViewController(self).image {
            cell.imageView.image = image
        }
        
        if let highlightedImage = childController?.childHeaderForPagerTabStripViewController(self).highlightedImage {
            cell.imageView.highlightedImage = highlightedImage
        }
        
        if pagerOptions.contains(.IsProgressiveIndicator) {
            if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
                changeCurrentIndexProgressive(oldCell: currentIndex == indexPath.item ? nil : cell, newCell: currentIndex == indexPath.item ? cell : nil, progressPercentage: 1, changeCurrentIndex: true, animated: false)
            }
        }
        else {
            if let changeCurrentIndex = changeCurrentIndex {
                changeCurrentIndex(oldCell: currentIndex == indexPath.item ? nil : cell, newCell: currentIndex == indexPath.item ? cell : nil, animated: false)
            }
        }
        
        return cell
    }
    
    // MARK: - UIScrollViewDelegate
    
    public override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        
        guard scrollView == containerView else { return }
        shouldUpdateButtonBarView = true
    }
    
    private func calculateWidths() -> [CGFloat] {
        let flowLayout = self.buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout
        let numberOfCells = self.viewControllers.count
        
        var minimumCellWidths = [CGFloat]()
        var collectionViewContentWidth: CGFloat = 0
        
        for viewController in self.viewControllers {
            let childController = viewController as? PagerTabStripChildItem
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = self.buttonBarView.labelFont!
            label.text = childController?.childHeaderForPagerTabStripViewController(self).title
            let labelSize = label.intrinsicContentSize()
            
            let minimumCellWidth = labelSize.width + CGFloat(self.buttonBarView.leftRightMargin! * 2)
            minimumCellWidths.append(minimumCellWidth)
            
            collectionViewContentWidth += minimumCellWidth
        }
        
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumInteritemSpacing
        collectionViewContentWidth += cellSpacingTotal
        
        let collectionViewAvailableVisibleWidth = self.buttonBarView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        
        if self.buttonBarView.shouldCellsFillAvailiableWidth || collectionViewAvailableVisibleWidth < collectionViewContentWidth {
            return minimumCellWidths
        }
        else {
            let stretchedCellWidthIfAllEqual = (collectionViewAvailableVisibleWidth - cellSpacingTotal) / CGFloat(numberOfCells)
            let generalMinimumCellWidth = self.calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: stretchedCellWidthIfAllEqual, previousNumberOfLargeCells: 0)
            var stretchedCellWidths = [CGFloat]()
            
            for minimumCellWidthValue in minimumCellWidths {
                let cellWidth = (minimumCellWidthValue > generalMinimumCellWidth) ? minimumCellWidthValue : generalMinimumCellWidth
                stretchedCellWidths.append(cellWidth)
            }
            
            return stretchedCellWidths
        }
    }
}
