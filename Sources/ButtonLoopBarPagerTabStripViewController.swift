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

    private func rotatedArray<T>(array: [T], rotation: Int) -> [T] {
        guard rotation > 0 else { return array }
        return Array(array[rotation...array.count-1] + array[0...rotation-1])
    }

}
