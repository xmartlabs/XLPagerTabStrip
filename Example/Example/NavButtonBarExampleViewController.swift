//  NavButtonBarExampleViewController.swift
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
import XLPagerTabStrip

public class NavButtonBarExampleViewController: ButtonBarPagerTabStripViewController {
    var isReload = false
    
    public override func viewDidLoad() {
        // set up style before super view did load is executed
        settings.style.buttonBarBackgroundColor = .clearColor()
        settings.style.selectedBarBackgroundColor = .orangeColor()
        //-
        super.viewDidLoad()
        
        if pagerOptions.contains(.IsProgressiveIndicator) {
            pagerOptions = pagerOptions.remove(.IsProgressiveIndicator)!
        }
        
        buttonBarView.removeFromSuperview()
        navigationController?.navigationBar.addSubview(buttonBarView)
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = UIColor(white: 1, alpha: 0.6)
            newCell?.label.textColor = .whiteColor()
            
            if animated {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    newCell?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                    oldCell?.transform = CGAffineTransformMakeScale(0.8, 0.8)
                })
            }
            else {
                newCell?.transform = CGAffineTransformMakeScale(1.0, 1.0)
                oldCell?.transform = CGAffineTransformMakeScale(0.8, 0.8)
            }
        }
    }
    
    // MARK: - PagerTabStripViewControllerDataSource
    
    public override func childViewControllersForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = TableChildExampleViewController(style: .Plain, itemInfo: "Table View")
        let child_2 = ChildExampleViewController(title: "View")
        let child_3 = TableChildExampleViewController(style: .Grouped, itemInfo: "Table View 2")
        let child_4 = ChildExampleViewController(title: "View 1")
        let child_5 = TableChildExampleViewController(style: .Plain, itemInfo: "Table View 3")
        let child_6 = ChildExampleViewController(title: "View 2")
        let child_7 = TableChildExampleViewController(style: .Grouped, itemInfo: "Table View 4")
        let child_8 = ChildExampleViewController(title: "View 3")
        
        guard isReload else {
            return [child_1, child_2, child_3, child_4, child_5, child_6, child_7, child_8]
        }
        
        var childViewControllers = [child_1, child_2, child_3, child_4, child_6, child_7, child_8]
        
        for (index, _) in childViewControllers.enumerate(){
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index{
                swap(&childViewControllers[index], &childViewControllers[n])
            }
        }
        let nItems = 1 + (rand() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    public override func reloadPagerTabStripView() {
        isReload = true
        pagerOptions = rand() % 2 == 0 ? pagerOptions.union(.IsProgressiveIndicator) : (pagerOptions.remove(.IsProgressiveIndicator) ?? pagerOptions)
        pagerOptions = rand() % 2 == 0 ? pagerOptions.union(.IsElasticIndicatorLimit) : (pagerOptions.remove(.IsElasticIndicatorLimit) ?? pagerOptions)
        super.reloadPagerTabStripView()
    }
    
    public override func configureCell(cell: ButtonBarViewCell, childInfo: ChildItemInfo) {
        super.configureCell(cell, childInfo: childInfo)
        cell.backgroundColor = .clearColor()
    }
}
