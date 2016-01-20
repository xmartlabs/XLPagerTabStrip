//
//  ReloadExampleViewController.swift
//  Example
//
//  Created by Santiago on 1/20/16.
//
//

import UIKit
import XLPagerTabStrip

public class ReloadExampleViewController: UIViewController {
    @IBOutlet public var titleLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = navigationController {
            let bigLabel = UILabel()
            bigLabel.backgroundColor = .clearColor()
            bigLabel.textColor = .whiteColor()
            bigLabel.font = UIFont.boldSystemFontOfSize(20)
            bigLabel.adjustsFontSizeToFitWidth = true
            navigationItem.titleView = bigLabel
            bigLabel.sizeToFit()
        }
        
        for childViewController in childViewControllers {
            if let child = childViewController as? PagerTabStripViewController {
                updateTitle(child)
                break;
            }
        }
    }
    
    @IBAction func reloadTapped(sender: UIBarButtonItem) {
        for childViewController in childViewControllers {
            if let child = childViewController as? PagerTabStripViewController {
                child.reloadPagerTabStripView()
                updateTitle(child)
                break;
            }
        }
    }
    
    
    func updateTitle(pagerTabStripViewController: PagerTabStripViewController) -> Void {
        let title = String(format: "Progressive = \(stringFromBool(pagerTabStripViewController.isProgressiveIndicator))  ElasticLimit = \(stringFromBool(pagerTabStripViewController.isElasticIndicatorLimit))")
        titleLabel.text = title
        
        if let titleview = navigationItem.titleView as? UILabel {
            titleview.text = title
            navigationItem.titleView?.sizeToFit()
        }
    }
    
    func stringFromBool(bool: Bool) -> String {
        if bool {
            return "YES"
        }
        else {
            return "NO"
        }
    }
}