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

public enum ButtonBarItemSpec<CellType: UICollectionViewCell> {
    
    case NibFile(nibName: String, bundle: NSBundle?, width:((IndicatorInfo)-> CGFloat))
    case CellClass(width:((IndicatorInfo)-> CGFloat))
    
    public var weight: ((IndicatorInfo) -> CGFloat) {
        switch self {
        case .CellClass(let widthCallback):
            return widthCallback
        case .NibFile(_, _, let widthCallback):
            return widthCallback
        }
    }
}

public struct ButtonBarPagerTabStripSettings {
    
    public struct Style {
        public var buttonBarBackgroundColor: UIColor?
        @available(*, deprecated=4.0.2) public var buttonBarMinimumInteritemSpacing: CGFloat? = 0
        public var buttonBarMinimumLineSpacing: CGFloat?
        public var buttonBarLeftContentInset: CGFloat?
        public var buttonBarRightContentInset: CGFloat?

        public var selectedBarBackgroundColor = UIColor.blackColor()
        public var selectedBarHeight: CGFloat = 5
        
        public var buttonBarItemBackgroundColor: UIColor?
        public var buttonBarItemFont = UIFont.systemFontOfSize(18)
        public var buttonBarItemLeftRightMargin: CGFloat = 8
        public var buttonBarItemTitleColor: UIColor?
        public var buttonBarItemsShouldFillAvailiableWidth = true
       
        // only used if button bar is created programaticaly and not using storyboards or nib files
        public var buttonBarHeight: CGFloat?
    }
    
    public var style = Style()
}

public class ButtonBarPagerTabStripViewController: PagerTabStripViewController, PagerTabStripDataSource, PagerTabStripIsProgressiveDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    public var settings = ButtonBarPagerTabStripSettings()
    
    lazy public var buttonBarItemSpec: ButtonBarItemSpec<ButtonBarViewCell> = .NibFile(nibName: "ButtonCell", bundle: NSBundle(forClass: ButtonBarViewCell.self), width:{ [weak self] (childItemInfo) -> CGFloat in
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = self?.settings.style.buttonBarItemFont
        label.text = childItemInfo.title
        let labelSize = label.intrinsicContentSize()
        return labelSize.width + (self?.settings.style.buttonBarItemLeftRightMargin ?? 8) * 2
    })
    
    public var changeCurrentIndex: ((oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, animated: Bool) -> Void)?
    public var changeCurrentIndexProgressive: ((oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void)?
    
    @IBOutlet public lazy var buttonBarView: ButtonBarView! = { [unowned self] in
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        let buttonBarHeight = self.settings.style.buttonBarHeight ?? 44
        let buttonBar = ButtonBarView(frame: CGRectMake(0, 0, self.view.frame.size.width, buttonBarHeight), collectionViewLayout: flowLayout)
        buttonBar.backgroundColor = .orangeColor()
        buttonBar.selectedBar.backgroundColor = .blackColor()
        buttonBar.autoresizingMask = .FlexibleWidth
        var newContainerViewFrame = self.containerView.frame
        newContainerViewFrame.origin.y = buttonBarHeight
        newContainerViewFrame.size.height = self.containerView.frame.size.height - (buttonBarHeight - self.containerView.frame.origin.y)
        self.containerView.frame = newContainerViewFrame
        return buttonBar
    }()
    
    lazy private var cachedCellWidths: [CGFloat]? = { [unowned self] in
        return self.calculateWidths()
    }()
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
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
        buttonBarView.scrollsToTop = false
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = settings.style.buttonBarMinimumLineSpacing ?? flowLayout.minimumLineSpacing
        let sectionInset = flowLayout.sectionInset
        flowLayout.sectionInset = UIEdgeInsetsMake(sectionInset.top, self.settings.style.buttonBarLeftContentInset ?? sectionInset.left, sectionInset.bottom, self.settings.style.buttonBarRightContentInset ?? sectionInset.right)

        buttonBarView.showsHorizontalScrollIndicator = false
        buttonBarView.backgroundColor = settings.style.buttonBarBackgroundColor ?? buttonBarView.backgroundColor
        buttonBarView.selectedBar.backgroundColor = settings.style.selectedBarBackgroundColor
        
        buttonBarView.selectedBarHeight = settings.style.selectedBarHeight ?? buttonBarView.selectedBarHeight
        // register button bar item cell
        switch buttonBarItemSpec {
        case .NibFile(let nibName, let bundle, _):
            buttonBarView.registerNib(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier:"Cell")
        case .CellClass:
            buttonBarView.registerClass(ButtonBarViewCell.self, forCellWithReuseIdentifier:"Cell")
        }
        //-
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        buttonBarView.layoutIfNeeded()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard isViewAppearing || isViewRotating else { return }
        
        // Force the UICollectionViewFlowLayout to get laid out again with the new size if
        // a) The view is appearing.  This ensures that
        //    collectionView:layout:sizeForItemAtIndexPath: is called for a second time
        //    when the view is shown and when the view *frame(s)* are actually set
        //    (we need the view frame's to have been set to work out the size's and on the
        //    first call to collectionView:layout:sizeForItemAtIndexPath: the view frame(s)
        //    aren't set correctly)
        // b) The view is rotating.  This ensures that
        //    collectionView:layout:sizeForItemAtIndexPath: is called again and can use the views
        //    *new* frame so that the buttonBarView cell's actually get resized correctly
        cachedCellWidths = calculateWidths()
        buttonBarView.collectionViewLayout.invalidateLayout()
        // When the view first appears or is rotated we also need to ensure that the barButtonView's
        // selectedBar is resized and its contentOffset/scroll is set correctly (the selected
        // tab/cell may end up either skewed or off screen after a rotation otherwise)
        buttonBarView.moveToIndex(currentIndex, animated: false, swipeDirection: .None, pagerScroll: .ScrollOnlyIfOutOfScreen)
    }
    
    // MARK: - Public Methods
    
    public override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        guard isViewLoaded() else { return }
        buttonBarView.reloadData()
        cachedCellWidths = calculateWidths()
        buttonBarView.moveToIndex(currentIndex, animated: false, swipeDirection: .None, pagerScroll: .Yes)
    }
    
    public func calculateStretchedCellWidths(minimumCellWidths: [CGFloat], suggestedStretchedCellWidth: CGFloat, previousNumberOfLargeCells: Int) -> CGFloat {
        var numberOfLargeCells = 0
        var totalWidthOfLargeCells: CGFloat = 0
        
        for minimumCellWidthValue in minimumCellWidths where minimumCellWidthValue > suggestedStretchedCellWidth {
            totalWidthOfLargeCells += minimumCellWidthValue
            numberOfLargeCells += 1
        }
        
        guard numberOfLargeCells > previousNumberOfLargeCells else { return suggestedStretchedCellWidth }
        
        let flowLayout = buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout
        let collectionViewAvailiableWidth = buttonBarView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        let numberOfCells = minimumCellWidths.count
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumLineSpacing
        
        let numberOfSmallCells = numberOfCells - numberOfLargeCells
        let newSuggestedStretchedCellWidth = (collectionViewAvailiableWidth - totalWidthOfLargeCells - cellSpacingTotal) / CGFloat(numberOfSmallCells)
        
        return calculateStretchedCellWidths(minimumCellWidths, suggestedStretchedCellWidth: newSuggestedStretchedCellWidth, previousNumberOfLargeCells: numberOfLargeCells)
    }
    
    public func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) {
        guard shouldUpdateButtonBarView else { return }
        buttonBarView.moveToIndex(toIndex, animated: true, swipeDirection: toIndex < fromIndex ? .Right : .Left, pagerScroll: .Yes)
        
        if let changeCurrentIndex = changeCurrentIndex {
            let oldCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex != fromIndex ? fromIndex : toIndex, inSection: 0)) as? ButtonBarViewCell
            let newCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0)) as? ButtonBarViewCell
            changeCurrentIndex(oldCell: oldCell, newCell: newCell, animated: true)
        }
    }
    
    public func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        guard shouldUpdateButtonBarView else { return }
        buttonBarView.moveFromIndex(fromIndex, toIndex: toIndex, progressPercentage: progressPercentage, pagerScroll: .Yes)
        if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
            let oldCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex != fromIndex ? fromIndex : toIndex, inSection: 0)) as? ButtonBarViewCell
            let newCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0)) as? ButtonBarViewCell
            changeCurrentIndexProgressive(oldCell: oldCell, newCell: newCell, progressPercentage: progressPercentage, changeCurrentIndex: indexWasChanged, animated: true)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayut
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let cellWidthValue = cachedCellWidths?[indexPath.row] else {
            fatalError("cachedCellWidths for \(indexPath.row) must not be nil")
        }
        return CGSizeMake(cellWidthValue, collectionView.frame.size.height)
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.item != currentIndex else { return }
        
        buttonBarView.moveToIndex(indexPath.item, animated: true, swipeDirection: .None, pagerScroll: .Yes)
        shouldUpdateButtonBarView = false
        
        let oldCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0)) as? ButtonBarViewCell
        let newCell = buttonBarView.cellForItemAtIndexPath(NSIndexPath(forItem: indexPath.item, inSection: 0)) as? ButtonBarViewCell
        if pagerBehaviour.isProgressiveIndicator {
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
            fatalError("UICollectionViewCell should be or extend from ButtonBarViewCell")
        }
        let childController = viewControllers[indexPath.item] as! IndicatorInfoProvider
        let indicatorInfo = childController.indicatorInfoForPagerTabStrip(self)
        
        cell.label.text = indicatorInfo.title
        cell.label.font = settings.style.buttonBarItemFont ?? cell.label.font
        cell.label.textColor = settings.style.buttonBarItemTitleColor ?? cell.label.textColor
        cell.contentView.backgroundColor = settings.style.buttonBarItemBackgroundColor ?? cell.contentView.backgroundColor
        cell.backgroundColor = settings.style.buttonBarItemBackgroundColor ?? cell.backgroundColor
        if let image = indicatorInfo.image {
            cell.imageView.image = image
        }
        if let highlightedImage = indicatorInfo.highlightedImage {
            cell.imageView.highlightedImage = highlightedImage
        }

        configureCell(cell, indicatorInfo: indicatorInfo)
        
        if pagerBehaviour.isProgressiveIndicator {
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
    
    public func configureCell(cell: ButtonBarViewCell, indicatorInfo: IndicatorInfo){
    }
    
    private func calculateWidths() -> [CGFloat] {
        let flowLayout = self.buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout
        let numberOfCells = self.viewControllers.count
        
        var minimumCellWidths = [CGFloat]()
        var collectionViewContentWidth: CGFloat = 0
        
        for viewController in self.viewControllers {
            let childController = viewController as! IndicatorInfoProvider
            let indicatorInfo = childController.indicatorInfoForPagerTabStrip(self)
            switch buttonBarItemSpec {
            case .CellClass(let widthCallback):
                let width = widthCallback(indicatorInfo)
                minimumCellWidths.append(width)
                collectionViewContentWidth += width
            case .NibFile(_, _, let widthCallback):
                let width = widthCallback(indicatorInfo)
                minimumCellWidths.append(width)
                collectionViewContentWidth += width
            }
        }
        
        let cellSpacingTotal = CGFloat(numberOfCells - 1) * flowLayout.minimumLineSpacing
        collectionViewContentWidth += cellSpacingTotal
        
        let collectionViewAvailableVisibleWidth = self.buttonBarView.frame.size.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        
        if !settings.style.buttonBarItemsShouldFillAvailiableWidth || collectionViewAvailableVisibleWidth < collectionViewContentWidth {
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
    
    private var shouldUpdateButtonBarView = true
    
}
