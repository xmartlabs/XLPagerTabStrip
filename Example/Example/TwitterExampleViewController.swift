//  TwitterExampleViewController.swift
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

class TwitterExampleViewController: TwitterPagerTabStripViewController {
    var isReload = false
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let child_1 = TableChildExampleViewController(style: .plain, itemInfo: "TableView")
        let child_2 = ChildExampleViewController(itemInfo: "View")
        let child_3 = TableChildExampleViewController(style: .grouped, itemInfo: "TableView 2")
        let child_4 = ChildExampleViewController(itemInfo: "View 2")
        let child_5 = TableChildExampleViewController(style: .plain, itemInfo: "TableView 3")
        let child_6 = ChildExampleViewController(itemInfo: "View 3")
        let child_7 = TableChildExampleViewController(style: .grouped, itemInfo: "TableView 4")
        let child_8 = ChildExampleViewController(itemInfo: "View 4")
        
        guard isReload else {
            return [child_1, child_2, child_3, child_4, child_5, child_6, child_7, child_8]
        }
        
        var childViewControllers = [child_1, child_2, child_3, child_4, child_6, child_7, child_8]
        
        for (index, _) in childViewControllers.enumerated(){
            let nElements = childViewControllers.count - index
            let n = (Int(arc4random()) % nElements) + index
            if n != index{
                swap(&childViewControllers[index], &childViewControllers[n])
            }
        }
        let nItems = 1 + (arc4random() % 8)
        return Array(childViewControllers.prefix(Int(nItems)))
    }
    
    @IBAction func reloadTapped(_ sender: AnyObject) {
        isReload = true
        reloadPagerTabStripView()
    }
}
