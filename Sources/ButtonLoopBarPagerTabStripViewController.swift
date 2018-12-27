//
//  ButtonLoopBarPagerTabStripViewController.swift
//  Pods
//
//  Created by tsugita on 2016/05/20.
//
//

import UIKit

open class ButtonLoopBarPagerTabStripViewController: ButtonBarPagerTabStripViewController {

    open var indexAheadForLoop = 0

    open override var viewControllers: [UIViewController] {
        return rotatedArray(array: super.viewControllers, rotation: indexAheadForLoop)
    }

    open override var currentIndex: Int {
        return (super.currentIndex - indexAheadForLoop + viewControllers.count) % viewControllers.count
    }

    override var cachedCellWidths: [CGFloat]? {
        guard let widths = super.cachedCellWidths else { return nil }
        return rotatedArray(array: widths, rotation: indexAheadForLoop)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !scrollingBySelectingButton {
            shiftButtonsIndex()
        }
    }

    // MARK: - UICollectionViewDelegate

    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        scrollingBySelectingButton = true

        super.collectionView(collectionView, didSelectItemAt: indexPath)
    }

    // MARK: - UIScrollViewDelegate

    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        if scrollView == buttonBarView && !scrollingBySelectingButton {
            scrollToSelectedButton = false
            shiftButtonsIndex()
        }
    }

    open override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)

        guard scrollView == containerView else { return }

        scrollingBySelectingButton = false
        shiftButtonsIndex()
    }

    // MARK: - Public Methods

    open override func pageFor(virtualPage: Int) -> Int {
        return virtualPage + indexAheadForLoop
    }

    open override func calculateWidths() -> [CGFloat] {
        let tmp = self.indexAheadForLoop
        self.indexAheadForLoop = 0

        let widths = super.calculateWidths()

        self.indexAheadForLoop = tmp
        return widths
    }

    open override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        guard shouldUpdateButtonBarView else { return }
        buttonBarView.move(fromIndex: fromIndex, toIndex: toIndex, progressPercentage: progressPercentage, pagerScroll: .yes, scrollToSelectedButton: scrollToSelectedButton)
        scrollToSelectedButton = true
        if let changeCurrentIndexProgressive = changeCurrentIndexProgressive {
            let oldCell = buttonBarView.cellForItem(at: IndexPath(item: currentIndex != fromIndex ? fromIndex : toIndex, section: 0)) as? ButtonBarViewCell
            let newCell = buttonBarView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ButtonBarViewCell
            changeCurrentIndexProgressive(oldCell, newCell, progressPercentage, indexWasChanged, true)
        }
    }

    // MARK: - Private Methods

    private func shiftButtonsIndex() {
        let visibleIndexs = buttonBarView.indexPathsForVisibleItems.map { $0.item }
        guard !visibleIndexs.isEmpty else { return }
        let mostLeftVisibleIndex = visibleIndexs.min()!
        let mostRightVisibleIndex = visibleIndexs.max()!

        var shiftIndex = 0

        if mostLeftVisibleIndex == 0 {
            shiftIndex = -1
        } else if mostRightVisibleIndex == viewControllers.count - 1 {
            shiftIndex = 1
        } else {
            return
        }

        indexAheadForLoop = (indexAheadForLoop + shiftIndex + viewControllers.count) % viewControllers.count

        let buttonBarContentWidth = cachedCellWidths![0...viewControllers.count-1].reduce(0, +)
        let buttonBarShiftWidth: CGFloat = shiftIndex == 1 ? -cachedCellWidths!.last! : cachedCellWidths!.first!

        buttonBarView.bounds.origin.x = (buttonBarView.bounds.origin.x + buttonBarShiftWidth + buttonBarContentWidth).truncatingRemainder(dividingBy: buttonBarContentWidth)
        buttonBarView.reloadData()

        let containerViewContentWidth = containerView.contentSize.width
        let containerViewShiftWidth = -CGFloat(shiftIndex) * pageWidth

        containerView.bounds.origin.x = (containerView.bounds.origin.x + containerViewShiftWidth + containerViewContentWidth).truncatingRemainder(dividingBy: containerViewContentWidth)
        updateContent()
    }

    private func rotatedArray<T>(array: [T], rotation: Int) -> [T] {
        guard rotation > 0 else { return array }
        return Array(array[rotation...array.count-1] + array[0...rotation-1])
    }

    private var scrollToSelectedButton = true
    private var scrollingBySelectingButton = false

}
