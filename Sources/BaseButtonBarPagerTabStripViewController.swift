//  BaseButtonBarPagerTabStripViewController.swift
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

open class BaseButtonBarPagerTabStripViewController<ButtonBarCellType : UICollectionViewCell>: PagerTabStripViewController, PagerTabStripDataSource, PagerTabStripIsProgressiveDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    open var settings = ButtonBarPagerTabStripSettings()
    open var buttonBarItemSpec: ButtonBarItemSpec<ButtonBarCellType>!
    open var changeCurrentIndex: ((_ oldCell: ButtonBarCellType?, _ newCell: ButtonBarCellType?, _ animated: Bool) -> Void)?
    open var changeCurrentIndexProgressive: ((_ oldCell: ButtonBarCellType?, _ newCell: ButtonBarCellType?, _ progressPercentage: CGFloat, _ changeCurrentIndex: Bool, _ animated: Bool) -> Void)?


    @IBOutlet open lazy var buttonBarView: ButtonBarView! = { [unowned self] in
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = UIEdgeInsetsMake(0, self.settings.style.buttonBarLeftContentInset ?? 35, 0, self.settings.style.buttonBarRightContentInset ?? 35)
        let buttonBarHeight = self.settings.style.buttonBarHeight ?? 44
        let buttonBar = ButtonBarView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: buttonBarHeight), collectionViewLayout: flowLayout)
        buttonBar.backgroundColor = .orange
        buttonBar.selectedBar.backgroundColor = .black
        buttonBar.autoresizingMask = .flexibleWidth
        var newContainerViewFrame = self.containerView.frame
        newContainerViewFrame.origin.y = buttonBarHeight
        newContainerViewFrame.size.height = self.containerView.frame.size.height - (buttonBarHeight - self.containerView.frame.origin.y)
        self.containerView.frame = newContainerViewFrame
        return buttonBar
        }()

    lazy fileprivate var cachedCellWidths: [CGFloat]? = { [unowned self] in
        return self.calculateWidths()
        }()

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
        datasource = self
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        datasource = self
    }

    open override func viewDidLoad() {
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
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = settings.style.buttonBarMinimumLineSpacing ?? flowLayout.minimumLineSpacing
        flowLayout.minimumLineSpacing = settings.style.buttonBarMinimumLineSpacing ?? flowLayout.minimumLineSpacing
        let sectionInset = flowLayout.sectionInset
        flowLayout.sectionInset = UIEdgeInsetsMake(sectionInset.top, self.settings.style.buttonBarLeftContentInset ?? sectionInset.left, sectionInset.bottom, self.settings.style.buttonBarRightContentInset ?? sectionInset.right)
        buttonBarView.showsHorizontalScrollIndicator = false
        buttonBarView.backgroundColor = settings.style.buttonBarBackgroundColor ?? buttonBarView.backgroundColor
        buttonBarView.selectedBar.backgroundColor = settings.style.selectedBarBackgroundColor

        buttonBarView.selectedBarHeight = settings.style.selectedBarHeight
        // register button bar item cell
        switch buttonBarItemSpec! {
        case .nibFile(let nibName, let bundle, _):
            buttonBarView.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier:"Cell")
        case .cellClass:
            buttonBarView.register(ButtonBarCellType.self, forCellWithReuseIdentifier:"Cell")
        }
        //-
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buttonBarView.layoutIfNeeded()
        isViewAppearing = true
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isViewAppearing = false
    }

    open override func viewDidLayoutSubviews() {
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
        buttonBarView.moveToIndex(currentIndex, animated: false, swipeDirection: .none, pagerScroll: .scrollOnlyIfOutOfScreen)
    }

    // MARK: - View Rotation

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    // MARK: - Public Methods

    open override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        guard isViewLoaded else { return }
        buttonBarView.reloadData()
        cachedCellWidths = calculateWidths()
        buttonBarView.moveToIndex(currentIndex, animated: false, swipeDirection: .none, pagerScroll: .yes)
    }

    open func calculateStretchedCellWidths(_ minimumCellWidths: [CGFloat], suggestedStretchedCellWidth: CGFloat, previousNumberOfLargeCells: Int) -> CGFloat {
        var numberOfLargeCells = 0
        var totalWidthOfLargeCells: CGFloat = 0

        for minimumCellWidthValue in minimumCellWidths {
            if minimumCellWidthValue > suggestedStretchedCellWidth {
                totalWidthOfLargeCells += minimumCellWidthValue
                numberOfLargeCells += 1
            }
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

    open func pagerTabStripViewController(_ pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) {
        guard shouldUpdateButtonBarView else { return }
        buttonBarView.moveToIndex(toIndex, animated: true, swipeDirection: toIndex < fromIndex ? .right : .left, pagerScroll: .yes)

        if let changeCurrentIndex = changeCurrentIndex {
            let oldCell = buttonBarView.cellForItem(at: IndexPath(item: currentIndex != fromIndex ? fromIndex : toIndex, section: 0)) as? ButtonBarCellType
            let newCell = buttonBarView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ButtonBarCellType
            changeCurrentIndex(oldCell, newCell, true)
        }
    }

    open func pagerTabStripViewController(_ pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        guard shouldUpdateButtonBarView else { return }
        buttonBarView.moveFromIndex(fromIndex, toIndex: toIndex, progressPercentage: progressPercentage, pagerScroll: .yes)
        if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
            let oldCell = buttonBarView.cellForItem(at: IndexPath(item: currentIndex != fromIndex ? fromIndex : toIndex, section: 0)) as? ButtonBarCellType
            let newCell = buttonBarView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ButtonBarCellType
            changeCurrentIndexProgressive(oldCell, newCell, progressPercentage, indexWasChanged, true)
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayut

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        guard let cellWidthValue = cachedCellWidths?[(indexPath as NSIndexPath).row] else {
            fatalError("cachedCellWidths for \((indexPath as NSIndexPath).row) must not be nil")
        }
        return CGSize(width: cellWidthValue, height: collectionView.frame.size.height)
    }

    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard (indexPath as NSIndexPath).item != currentIndex else { return }

        buttonBarView.moveToIndex((indexPath as NSIndexPath).item, animated: true, swipeDirection: .none, pagerScroll: .yes)
        shouldUpdateButtonBarView = false

        let oldCell = buttonBarView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ButtonBarCellType
        let newCell = buttonBarView.cellForItem(at: IndexPath(item: (indexPath as NSIndexPath).item, section: 0)) as? ButtonBarCellType
        if pagerBehaviour.isProgressiveIndicator {
            if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
                changeCurrentIndexProgressive(oldCell, newCell, 1, true, true)
            }
        }
        else {
            if let changeCurrentIndex = changeCurrentIndex {
                changeCurrentIndex(oldCell, newCell, true)
            }
        }
        moveToViewControllerAtIndex((indexPath as NSIndexPath).item)
    }

    // MARK: - UICollectionViewDataSource

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ButtonBarCellType else {
            fatalError("UICollectionViewCell should be or extend from ButtonBarViewCell")
        }
        let childController = viewControllers[(indexPath as NSIndexPath).item] as! IndicatorInfoProvider
        let indicatorInfo = childController.indicatorInfoForPagerTabStrip(self)

        configureCell(cell, indicatorInfo: indicatorInfo)

        if pagerBehaviour.isProgressiveIndicator {
            if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
                changeCurrentIndexProgressive(currentIndex == (indexPath as NSIndexPath).item ? nil : cell, currentIndex == (indexPath as NSIndexPath).item ? cell : nil, 1, true, false)
            }
        }
        else {
            if let changeCurrentIndex = changeCurrentIndex {
                changeCurrentIndex(currentIndex == (indexPath as NSIndexPath).item ? nil : cell, currentIndex == (indexPath as NSIndexPath).item ? cell : nil, false)
            }
        }

        return cell
    }

    // MARK: - UIScrollViewDelegate

    open override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)

        guard scrollView == containerView else { return }
        shouldUpdateButtonBarView = true
    }

    open func configureCell(_ cell: ButtonBarCellType, indicatorInfo: IndicatorInfo){
        fatalError("You must override this method to set up ButtonBarView cell accordingly")
    }

    fileprivate func calculateWidths() -> [CGFloat] {
        let flowLayout = self.buttonBarView.collectionViewLayout as! UICollectionViewFlowLayout
        let numberOfCells = self.viewControllers.count

        var minimumCellWidths = [CGFloat]()
        var collectionViewContentWidth: CGFloat = 0

        for viewController in self.viewControllers {
            let childController = viewController as! IndicatorInfoProvider
            let indicatorInfo = childController.indicatorInfoForPagerTabStrip(self)
            switch buttonBarItemSpec! {
            case .cellClass(let widthCallback):
                let width = widthCallback(indicatorInfo)
                minimumCellWidths.append(width)
                collectionViewContentWidth += width
            case .nibFile(_, _, let widthCallback):
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

    fileprivate var shouldUpdateButtonBarView = true
}


open class ExampleBaseButtonBarPagerTabStripViewController: BaseButtonBarPagerTabStripViewController<ButtonBarViewCell> {

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    open func initialize(){
        buttonBarItemSpec = .nibFile(nibName: "ButtonCell", bundle: Bundle(for: ButtonBarViewCell.self), width:{ [weak self] (childItemInfo) -> CGFloat in
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = self?.settings.style.buttonBarItemFont ?? label.font
            label.text = childItemInfo.title
            let labelSize = label.intrinsicContentSize
            return labelSize.width + CGFloat(self?.settings.style.buttonBarItemLeftRightMargin ?? 8 * 2)
            })
    }

    open override func configureCell(_ cell: ButtonBarViewCell, indicatorInfo: IndicatorInfo){
        cell.label.text = indicatorInfo.title
        if let image = indicatorInfo.image {
            cell.imageView.image = image
        }
        if let highlightedImage = indicatorInfo.highlightedImage {
            cell.imageView.highlightedImage = highlightedImage
        }
    }
}
