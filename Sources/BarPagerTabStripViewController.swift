//  BarPagerTabStripViewController.swift
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2017 Xmartlabs ( http://xmartlabs.com )
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
import UIKit

public struct BarPagerTabStripSettings {
    
    public struct Style {
        public var barBackgroundColor: UIColor?
        public var selectedBarBackgroundColor: UIColor?
        public var barHeight: CGFloat = 5 // barHeight is ony set up when the bar is created programatically and not using storyboards or xib files.
    }
    
    public var style = Style()
}

open class BarPagerTabStripViewController: PagerTabStripViewController, PagerTabStripDataSource, PagerTabStripIsProgressiveDelegate {
    
    public var settings = BarPagerTabStripSettings()
    
    @IBOutlet weak public var barView: BarView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        datasource = self
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        delegate = self
        datasource = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        barView = barView ?? {
            let barView = BarView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: settings.style.barHeight))
            barView.autoresizingMask = .flexibleWidth
            barView.backgroundColor = .black
            barView.selectedBar.backgroundColor = .white
            return barView
        }()
        
        barView.backgroundColor = settings.style.barBackgroundColor ?? barView.backgroundColor
        barView.selectedBar.backgroundColor = settings.style.selectedBarBackgroundColor ?? barView.selectedBar.backgroundColor
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if barView.superview == nil {
            view.addSubview(barView)
        }
        barView.optionsCount = viewControllers.count
        barView.moveTo(index: currentIndex, animated: false)
    }
    
    open override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        barView.optionsCount = viewControllers.count
        if isViewLoaded{
            barView.moveTo(index: currentIndex, animated: false)
        }
    }
    
    // MARK: - PagerTabStripDelegate

    open func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {

        barView.move(fromIndex: fromIndex, toIndex: toIndex, progressPercentage: progressPercentage)
    }

    open func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
        barView.moveTo(index: toIndex, animated: true)
    }
}
