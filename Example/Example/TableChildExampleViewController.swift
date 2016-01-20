//
//  TableChildExampleViewController.swift
//  Example
//
//  Created by Santiago on 1/18/16.
//
//

import Foundation
import XLPagerTabStrip

class TableChildExampleViewController: UITableViewController, PagerTabStripChildItem {
    let kCellIdentifier = "postCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "PostCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: kCellIdentifier)
        self.tableView.estimatedRowHeight = 60.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : PostCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! PostCell
        return cell
    }
    
    // MARK: - XLPagerTabStripChildItem
    
    func childHeaderForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> ChildHeaderData {
        return ChildHeaderData(title: "Table View", image: nil, highlightedImage: nil, color: .whiteColor())
    }
}
