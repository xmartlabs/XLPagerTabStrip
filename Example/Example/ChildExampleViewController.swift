//
//  ChildExampleViewController.swift
//  Example
//
//  Created by Santiago on 1/18/16.
//
//

import Foundation
import XLPagerTabStrip

class ChildExampleViewController : UIViewController, XLPagerTabStripChildItem {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel.init()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "XLPagertabStrip"
        
        self.view.addSubview(label)
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.view.addConstraint(NSLayoutConstraint.init(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint.init(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: -50.0))
    }
    
    // MARK: - XLPagerTabStripViewControllerDelegate
    
    func childHeaderForPagerTabStripViewController(pagerTabStripController: XLPagerTabStripViewController) -> ChildHeader {
        return ChildHeader(title: "View", image: nil, highlightedImage: nil, color: UIColor.whiteColor())
    }
}
