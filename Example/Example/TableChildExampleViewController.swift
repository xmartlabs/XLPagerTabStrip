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
    
    var posts : [AnyObject]
    
    override init(style: UITableViewStyle) {
        posts = XLJSONSerialization.sharedInstance.postsData as! [AnyObject]
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder){
        posts = XLJSONSerialization.sharedInstance.postsData as! [AnyObject]
        super.init(coder: aDecoder)
    }
    
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
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : PostCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as! PostCell
        
        return cell
    }
    
    // MARK: - XLPagerTabStripChildItem
    
    func childHeaderForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> ChildHeaderData {
        return ChildHeaderData(title: "Table View", image: nil, highlightedImage: nil, color: .whiteColor())
    }
    
    // MARK: Helpers
    
    func timeAgo(date : NSDate) -> String{
        let distanceBetweenDates = date.timeIntervalSinceDate(NSDate.init()) * (-1)
        var distance = floor(distanceBetweenDates)
        
        let SECONDS_IN_A_MINUTE = 60.0
        let SECONDS_IN_A_HOUR = 3600.0
        let SECONDS_IN_A_DAY = 86400.0
        let SECONDS_IN_A_MONTH_OF_30_DAYS = 259200.0
        let SECONDS_IN_A_YEAR_OF_MONTH_OF_30_DAYS = 31104000.0
        
        if (distance <= 0){
            return "now"
        }
        else if (distance < SECONDS_IN_A_MINUTE){
            return String(format: "%ds", arguments: [distance])
        }
        else if (distance < SECONDS_IN_A_HOUR){
            distance = distance / SECONDS_IN_A_MINUTE
            return String(format: "%dm", arguments: [distance])
        }
        else if (distance < SECONDS_IN_A_DAY){
            distance = distance / SECONDS_IN_A_HOUR
            return String(format: "%dh", arguments: [distance])
        }
        else if (distance < SECONDS_IN_A_MONTH_OF_30_DAYS){
            distance = distance / SECONDS_IN_A_DAY
            return String(format: "%dd", arguments: [distance])
        }
        else if (distance < SECONDS_IN_A_YEAR_OF_MONTH_OF_30_DAYS){
            distance = distance / SECONDS_IN_A_MONTH_OF_30_DAYS
            return String(format: "%dmo", arguments: [distance])
        }
        else{
            distance = distance / SECONDS_IN_A_YEAR_OF_MONTH_OF_30_DAYS
            return String(format: "%dy", arguments: [distance])
        }
    }
    
    func dateFromString(dateString : String) -> NSDate{
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(abbreviation: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        return formatter.dateFromString(dateString)!
    }
}
