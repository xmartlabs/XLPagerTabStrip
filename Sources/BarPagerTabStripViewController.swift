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

public struct BarPagerTabStripSettings {
    
    public struct Style {
        public var barBackgroundColor: UIColor?
        public var selectedBarBackgroundColor: UIColor?
        public var barHeight: CGFloat = 5 // barHeight is ony set up when the bar is created programatically and not using storyboards or xib files.
    }
    
    public var style = Style()
}

open class BarPagerTabStripViewController: PagerTabStripViewController, PagerTabStripDataSource, PagerTabStripIsProgressiveDelegate {
    
    open var settings = BarPagerTabStripSettings()
    
    @IBOutlet lazy open var barView: BarView! = { [unowned self] in
        let barView = BarView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.settings.style.barHeight))
        barView.autoresizingMask = .flexibleWidth
        barView.backgroundColor = .black
        barView.selectedBar.backgroundColor = .white
        return barView
    }()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
        datasource = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        barView.backgroundColor = self.settings.style.barBackgroundColor ?? barView.backgroundColor
        barView.selectedBar.backgroundColor = self.settings.style.selectedBarBackgroundColor ?? barView.selectedBar.backgroundColor
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        datasource = self
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if barView.superview == nil {
            view.addSubview(barView)
        }
        barView.optionsCount = viewControllers.count
        barView.moveToIndex(index: currentIndex, animated: false)
    }
    
    open override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        barView.optionsCount = viewControllers.count
        if isViewLoaded{
            barView.moveToIndex(index: currentIndex, animated: false)
        }
    }
    
    // MARK: - PagerTabStripDelegate
    
    open func pagerTabStripViewController(_ pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int) {
        barView.moveToIndex(index: toIndex, animated: true)
    }
    
    open func pagerTabStripViewController(_ pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        barView.moveToIndex(fromIndex: fromIndex, toIndex: toIndex, progressPercentage: progressPercentage)
    }
}
