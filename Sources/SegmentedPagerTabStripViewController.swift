//  SegmentedPagerTabStripViewController.swift
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


public class SegmentedPagerTabStripViewController: PagerTabStripViewController {
    
    @IBOutlet lazy public var segmentedControl: UISegmentedControl! = UISegmentedControl()
    
    var shouldUpdateSegmentedControl = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if segmentedControl.superview == nil {
            navigationItem.titleView = segmentedControl
        }
        segmentedControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: .ValueChanged)
        try! reloadSegmentedControl()
    }
    
    public override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        if isViewLoaded() {
            try! reloadSegmentedControl()
        }
    }
    
    func reloadSegmentedControl() throws -> Void {
        segmentedControl.removeAllSegments()
        for (index, item) in pagerTabStripChildViewControllers.enumerate(){
            guard let child = item as? PagerTabStripChildItem else {
                throw PagerTabStripError.ChildViewControllerMustConformToPagerTabStripChildItem
            }
            if let image = child.childHeaderForPagerTabStripViewController(self).image {
                segmentedControl.insertSegmentWithImage(image, atIndex: index, animated: false)
            }
            else {
                segmentedControl.insertSegmentWithTitle(child.childHeaderForPagerTabStripViewController(self).title, atIndex: index, animated: false)
            }
        }
        
        guard let child = pagerTabStripChildViewControllers[currentIndex] as? PagerTabStripChildItem else {
            throw PagerTabStripError.CurrentIndexIsGreaterThanChildsCount
        }
        segmentedControl.selectedSegmentIndex = currentIndex
        if let color = child.childHeaderForPagerTabStripViewController(self).color {
            segmentedControl.tintColor = color
        }
    }
    
    func segmentedControlChanged(sender: UISegmentedControl) -> Void{
        let index = sender.selectedSegmentIndex
        try! pagerTabStripViewController(self, updateIndicatorFromIndex: currentIndex, toIndex: index)
        shouldUpdateSegmentedControl = false
        moveToViewControllerAtIndex(index)
    }
    
    // MARK: - PagerTabStripViewControllerDelegate
    
    override public func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) throws {
        try super.pagerTabStripViewController(pagerTabStripViewController, updateIndicatorFromIndex: fromIndex, toIndex: toIndex)
        if shouldUpdateSegmentedControl  {
            guard let child = pagerTabStripChildViewControllers[toIndex] as? PagerTabStripChildItem else {
                throw PagerTabStripError.CurrentIndexIsGreaterThanChildsCount
            }
            if let color = child.childHeaderForPagerTabStripViewController(self).color{
                segmentedControl.tintColor = color
            }
            segmentedControl.selectedSegmentIndex = toIndex
        }
    }
    
    public override func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex index: Int, withProgressPercentage progressPercentage: Float, indexWasChanged changed: Bool) throws {
        if shouldUpdateSegmentedControl{
            let currentIndex = (progressPercentage > 0.5) ? index : fromIndex
            guard let child = pagerTabStripChildViewControllers[currentIndex] as? PagerTabStripChildItem else {
                throw PagerTabStripError.CurrentIndexIsGreaterThanChildsCount
            }
            if let color = child.childHeaderForPagerTabStripViewController(self).color{
                segmentedControl.tintColor = color
            }
            segmentedControl.selectedSegmentIndex = min(currentIndex, pagerTabStripChildViewControllers.count - 1)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    public override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        shouldUpdateSegmentedControl = true
    }
}
