//
//  ChildExampleViewController.swift
//  Example
//
//  Created by Santiago on 1/18/16.
//
//

import Foundation
import XLPagerTabStrip

class ChildExampleViewController : UIViewController, PagerTabStripChildItem {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "XLPagerTabStrip"
        
        view.addSubview(label)
        view.backgroundColor = UIColor.whiteColor()
        
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: -50))
    }
    
    // MARK: - XLPagerTabStripViewControllerDelegate
    
    func childHeaderForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> ChildHeaderData {
        return ChildHeaderData(title: "View", image: nil, highlightedImage: nil, color: .whiteColor())
    }
}
