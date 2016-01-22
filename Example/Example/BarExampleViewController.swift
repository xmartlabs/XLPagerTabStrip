//
//  BarExampleViewController.swift
//  Example
//
//  Created by Santiago on 1/20/16.
//
//

import Foundation
import XLPagerTabStrip

public class BarExampleViewController: BarPagerTabStripViewController {
    var isReload = false
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        barView.selectedBar.backgroundColor = .orangeColor()
    }
    
    // MARK: - PagerTabStripViewControllerDataSource
    
    public override func childViewControllersForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let child_1 = TableChildExampleViewController(style: .Plain)
        let child_2 = ChildExampleViewController()
        let child_3 = TableChildExampleViewController(style: .Grouped)
        let child_4 = ChildExampleViewController()
        
        guard isReload else {
            return [child_1, child_2, child_3, child_4]
        }
        
        var childViewControllers = [child_1, child_2, child_3, child_4]
        for (index, _) in childViewControllers.enumerate(){
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index{
                swap(&childViewControllers[index], &childViewControllers[n])
            }
        }
        let nItems = 1 + (rand() % 4)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    public override func reloadPagerTabStripView() {
        isReload = true
        pagerOptions = rand() % 2 == 0 ? pagerOptions.union(.SkipIntermediateViewControllers) : (pagerOptions.remove(.SkipIntermediateViewControllers) ?? pagerOptions)
        pagerOptions = rand() % 2 == 0 ? pagerOptions.union(.IsProgressiveIndicator) : (pagerOptions.remove(.IsProgressiveIndicator) ?? pagerOptions)
        pagerOptions = rand() % 2 == 0 ? pagerOptions.union(.IsElasticIndicatorLimit) : (pagerOptions.remove(.IsElasticIndicatorLimit) ?? pagerOptions)
        super.reloadPagerTabStripView()
    }
}
