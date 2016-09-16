//  SegmentedExampleViewController.swift
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

class SegmentedExampleViewController: SegmentedPagerTabStripViewController {
    
    var isReload = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // change segmented style
        settings.style.segmentedControlColor = .white
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = TableChildExampleViewController(style: .plain, itemInfo: "Table View")
        let child_2 = ChildExampleViewController(itemInfo: "View")
        let child_3 = TableChildExampleViewController(style: .grouped, itemInfo: "Table View 2")
        let child_4 = ChildExampleViewController(itemInfo: "View 2")
        
        guard isReload else {
            return [child_1, child_2, child_3, child_4]
        }
        
        var childViewControllers = [child_1, child_2, child_3, child_4]
        let count = childViewControllers.count
        
        for (index, _) in childViewControllers.enumerated(){
            let nElements = count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index{
                swap(&childViewControllers[index], &childViewControllers[n])
            }
        }
        let nItems = 1 + (arc4random() % 4)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    @IBAction func reloadTapped(_ sender: UIBarButtonItem) {
        isReload = true
        pagerBehaviour = .common(skipIntermediateViewControllers: arc4random() % 2 == 0)
        reloadPagerTabStripView()
    }
}
