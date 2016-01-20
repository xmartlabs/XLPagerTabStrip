//
//  SegmentedExampleViewController.swift
//  Example
//
//  Created by Santiago on 1/19/16.
//
//

import Foundation
import XLPagerTabStrip

public class SegmentedExampleViewController : SegmentedPagerTabStripViewController{
    var isReload: Bool
    
    public required init?(coder aDecoder: NSCoder) {
        isReload = false
        super.init(coder: aDecoder)
        skipIntermediateViewControllers = false
    }
    
    // MARK: - XLPagerTabStripViewControllerDataSource
    
    override public func childViewControllersForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> [UIViewController]? {
        let child_1 = TableChildExampleViewController(style: .Plain)
        let child_2 = ChildExampleViewController()
        let child_3 = TableChildExampleViewController(style: .Grouped)
        let child_4 = ChildExampleViewController()
        
        if isReload == false{
            return [child_1, child_2, child_3, child_4]
        }
        
        var childViewControllers = [child_1, child_2, child_3, child_4] as Array
        let count = childViewControllers.count
        
        for (index, _) in childViewControllers.enumerate(){
            let nElements = count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index{
                swap(&childViewControllers[index], &childViewControllers[n])
            }
        }
        let nItems = 1 + (rand() % 4)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    @IBAction func reloadTapped(sender: UIBarButtonItem) {
        isReload = true
        isProgressiveIndicator = (rand() % 2 == 0)
        isElasticIndicatorLimit = (rand() % 2 == 0)
        reloadPagerTabStripView()
    }
    
}