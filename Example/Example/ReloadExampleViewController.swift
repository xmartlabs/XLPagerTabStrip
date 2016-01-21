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
    
    public lazy var bigLabel: UILabel = {
        let bigLabel = UILabel()
        bigLabel.backgroundColor = .clearColor()
        bigLabel.textColor = .whiteColor()
        bigLabel.font = UIFont.boldSystemFontOfSize(20)
        bigLabel.adjustsFontSizeToFitWidth = true
        return bigLabel
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = navigationController {
            navigationItem.titleView = bigLabel
            bigLabel.sizeToFit()
        }
        
        if let pagerViewController = childViewControllers.filter( { $0 is PagerTabStripViewController } ).first as? PagerTabStripViewController {
            updateTitle(pagerViewController)
        }
    }
    
    @IBAction func reloadTapped(sender: UIBarButtonItem) {
        for childViewController in childViewControllers {
            guard let child = childViewController as? PagerTabStripViewController else {
                continue
            }
            child.reloadPagerTabStripView()
            updateTitle(child)
            break;
        }
    }
    
    func updateTitle(pagerTabStripViewController: PagerTabStripViewController) {
        func stringFromBool(bool: Bool) -> String {
            return bool ? "YES" : "NO"
        }
        
        titleLabel.text = "Progressive = \(stringFromBool(pagerTabStripViewController.pagerOptions.contains(.IsProgressiveIndicator)))  ElasticLimit = \(stringFromBool(pagerTabStripViewController.pagerOptions.contains(.IsElasticIndicatorLimit)))"
        
        (navigationItem.titleView as? UILabel)?.text = titleLabel.text
        navigationItem.titleView?.sizeToFit()
    }
}
