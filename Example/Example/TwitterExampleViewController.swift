//
//  TwitterExampleViewController.swift
//  Example
//
//  Created by Santiago on 1/22/16.
//
//

import Foundation
import XLPagerTabStrip

public class TwitterExampleViewController: TwitterPagerTabStripViewController {
    var isReload = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        pagerOptions = pagerOptions.union(.IsProgressiveIndicator)
        pagerOptions = pagerOptions.union(.IsElasticIndicatorLimit)
    }
    
    public override func childViewControllersForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let child_1 = TableChildExampleViewController(style: .Plain)
        let child_2 = ChildExampleViewController()
        let child_3 = TableChildExampleViewController(style: .Grouped)
        let child_4 = ChildExampleViewController()
        let child_5 = TableChildExampleViewController(style: .Plain)
        let child_6 = ChildExampleViewController()
        let child_7 = TableChildExampleViewController(style: .Grouped)
        let child_8 = ChildExampleViewController()
        
        guard isReload else {
            return [child_1, child_2, child_3, child_4, child_5, child_6, child_7, child_8]
        }
        
        var childViewControllers = [child_1, child_2, child_3, child_4, child_6, child_7, child_8] as Array
        let count = childViewControllers.count
        
        for (index, _) in childViewControllers.enumerate(){
            let nElements = count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index{
                swap(&childViewControllers[index], &childViewControllers[n])
            }
        }
        let nItems = 1 + (rand() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    @IBAction func reloadTapped(sender: AnyObject) {
        isReload = true
        reloadPagerTabStripView()
    }
}
