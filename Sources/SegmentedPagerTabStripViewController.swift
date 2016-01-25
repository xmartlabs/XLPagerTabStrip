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

public struct SegmentedPagerTabStripSettings {
    
    public struct Style {
        public var segmentedControlColor: UIColor?
    }
    
    public var style = Style()
}


public class SegmentedPagerTabStripViewController: PagerTabStripViewController, PagerTabStripViewControllerDataSource, PagerTabStripViewControllerDelegate {
    
    @IBOutlet lazy public var segmentedControl: UISegmentedControl! = UISegmentedControl()
    
    public var settings = SegmentedPagerTabStripSettings()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
        datasource = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        datasource = self
    }
    
    private(set) var shouldUpdateSegmentedControl = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if segmentedControl.superview == nil {
            navigationItem.titleView = segmentedControl
        }
        segmentedControl.tintColor = settings.style.segmentedControlColor ?? segmentedControl.tintColor
        segmentedControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: .ValueChanged)
        try! reloadSegmentedControl()
    }
    
    public override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        if isViewLoaded() {
            try! reloadSegmentedControl()
        }
    }
    
    func reloadSegmentedControl() throws {
        segmentedControl.removeAllSegments()
        for (index, item) in viewControllers.enumerate(){
            let child = item as! PagerTabStripChildItem
            if let image = child.childHeaderForPagerTabStripViewController(self).image {
                segmentedControl.insertSegmentWithImage(image, atIndex: index, animated: false)
            }
            else {
                segmentedControl.insertSegmentWithTitle(child.childHeaderForPagerTabStripViewController(self).title, atIndex: index, animated: false)
            }
        }
        segmentedControl.selectedSegmentIndex = currentIndex
    }
    
    func segmentedControlChanged(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        try! pagerTabStripViewController(self, updateIndicatorFromIndex: currentIndex, toIndex: index)
        shouldUpdateSegmentedControl = false
        moveToViewControllerAtIndex(index)
    }
    
    // MARK: - PagerTabStripViewControllerDelegate
    
    public func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) throws {
        if shouldUpdateSegmentedControl {
            segmentedControl.selectedSegmentIndex = toIndex
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    public override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        shouldUpdateSegmentedControl = true
    }
}