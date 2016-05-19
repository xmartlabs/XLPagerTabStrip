//
//  ButtonLoopBarPagerTabStripViewController.swift
//  Pods
//
//  Created by tsugita on 2016/05/20.
//
//

import UIKit

public class ButtonLoopBarPagerTabStripViewController: ButtonBarPagerTabStripViewController {

    public var indexAheadForLoop = 0

    public override var viewControllers: [UIViewController] {
        return rotatedArray(super.viewControllers, rotation: indexAheadForLoop)
    }

    public override var currentIndex: Int {
        return (super.currentIndex - indexAheadForLoop + viewControllers.count) % viewControllers.count
    }

    override var cachedCellWidths: [CGFloat]? {
        guard let widths = super.cachedCellWidths else { return nil }
        return rotatedArray(widths, rotation: indexAheadForLoop)
    }

    public override func calculateWidths() -> [CGFloat] {
        let tmp = self.indexAheadForLoop
        self.indexAheadForLoop = 0

        let widths = super.calculateWidths()

        self.indexAheadForLoop = tmp
        return widths
    }

    // MARK: - Private Methods

    private func shiftButtonsIndex() {
        let visibleIndexs = buttonBarView.indexPathsForVisibleItems().map { $0.item }
        guard visibleIndexs.count != 0 else { return }
        var leftIndex = visibleIndexs.minElement()!
        var rightIndex = visibleIndexs.maxElement()!

        var shiftIndex = 0

        if leftIndex == 0 {
            shiftIndex = -1
        } else if rightIndex == viewControllers.count - 1 {
            shiftIndex = 1
        } else {
            return
        }

        indexAheadForLoop = (indexAheadForLoop + shiftIndex + viewControllers.count) % viewControllers.count

        let buttonBarContentWidth = cachedCellWidths![0...viewControllers.count-1].reduce(0, combine: +)
        var buttonBarShiftWidth: CGFloat = shiftIndex == 1 ? -cachedCellWidths!.last! : cachedCellWidths!.first!

        buttonBarView.bounds.origin.x = (buttonBarView.bounds.origin.x + buttonBarShiftWidth + buttonBarContentWidth) % buttonBarContentWidth
        buttonBarView.reloadData()

        let containerViewContentWidth = containerView.contentSize.width
        var containerViewShiftWidth = -CGFloat(shiftIndex) * pageWidth

        containerView.bounds.origin.x = (containerView.bounds.origin.x + containerViewShiftWidth + containerViewContentWidth) % containerViewContentWidth
        updateContent()
    }

    private func rotatedArray<T>(array: [T], rotation: Int) -> [T] {
        guard rotation > 0 else { return array }
        return Array(array[rotation...array.count-1] + array[0...rotation-1])
    }

}
