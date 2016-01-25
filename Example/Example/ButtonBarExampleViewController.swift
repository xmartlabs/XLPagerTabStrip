//  ButtonBarExampleViewController.swift
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

public class ButtonBarExampleViewController: ButtonBarPagerTabStripViewController {
    
    var isReload = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if pagerOptions.contains(.IsProgressiveIndicator) {
            pagerOptions = pagerOptions.remove(.IsProgressiveIndicator)!
        }
        
        buttonBarView.selectedBar.backgroundColor = .orangeColor()
        buttonBarView.backgroundColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
    }
    
    // MARK: - PagerTabStripVIewControllerDataSource
    
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
}