//  ReloadExampleViewController.swift
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

import UIKit
import XLPagerTabStrip

class ReloadExampleViewController: UIViewController {
    
    @IBOutlet lazy var titleLabel: UILabel! = {
        let label = UILabel()
        return label
    }()
    
    lazy var bigLabel: UILabel = {
        let bigLabel = UILabel()
        bigLabel.backgroundColor = .clear
        bigLabel.textColor = .white
        bigLabel.font = UIFont.boldSystemFont(ofSize: 20)
        bigLabel.adjustsFontSizeToFitWidth = true
        return bigLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = navigationController {
            navigationItem.titleView = bigLabel
            bigLabel.sizeToFit()
        }
        
        if let pagerViewController = childViewControllers.filter( { $0 is PagerTabStripViewController } ).first as? PagerTabStripViewController {
            updateTitle(of: pagerViewController)
        }
    }
    
    @IBAction func reloadTapped(_ sender: UIBarButtonItem) {
        for childViewController in childViewControllers {
            guard let child = childViewController as? PagerTabStripViewController else {
                continue
            }
            child.reloadPagerTabStripView()
            updateTitle(of: child)
            break;
        }
    }
    
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateTitle(of pagerTabStripViewController: PagerTabStripViewController) {
        func stringFromBool(_ bool: Bool) -> String {
            return bool ? "YES" : "NO"
        }
        
        titleLabel.text = "Progressive = \(stringFromBool(pagerTabStripViewController.pagerBehaviour.isProgressiveIndicator))  ElasticLimit = \(stringFromBool(pagerTabStripViewController.pagerBehaviour.isElasticIndicatorLimit))"
        
        (navigationItem.titleView as? UILabel)?.text = titleLabel.text
        navigationItem.titleView?.sizeToFit()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
