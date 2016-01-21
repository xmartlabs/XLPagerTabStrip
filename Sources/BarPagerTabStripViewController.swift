//  BarPagerTabStripViewController.swift
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

public class BarPagerTabStripViewController: PagerTabStripViewController {
    
    @IBOutlet lazy public var barView: BarView! = { [unowned self] in
        let barView = BarView(frame: CGRectMake(0, 0, self.view.frame.size.width, 5.0))
        barView.backgroundColor = .orangeColor()
        barView.selectedBar.backgroundColor = .blackColor()
        barView.autoresizingMask = .FlexibleWidth
        return barView
    }()
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if barView.superview == nil {
            view.addSubview(barView)
        }
        barView.optionsCount = pagerTabStripChildViewControllers.count
        barView.moveToIndex(index: currentIndex, animated: false)
    }
    
    public override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        barView.optionsCount = pagerTabStripChildViewControllers.count
        if isViewLoaded(){
            barView.moveToIndex(index: currentIndex, animated: false)
        }
    }
    
    // MARK: - PagerTabStripViewControllerDelegate
    
    public override func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) throws {
        barView.moveToIndex(index: toIndex, animated: true)
    }
    
    public override func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: Float, indexWasChanged: Bool) throws {
        barView.moveToIndex(fromIndex: fromIndex, toIndex: toIndex, progressPercentage: progressPercentage)
    }
}
