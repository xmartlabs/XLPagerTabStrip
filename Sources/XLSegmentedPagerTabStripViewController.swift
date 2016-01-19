//
//  XLSegmentedPagerTabStripViewController.swift
//  XLPagerTabStrip
//
//  Created by Santiago on 1/19/16.
//
//

import Foundation

public class XLSegmentedPagerTabStripViewController : XLPagerTabStripViewController{
    var segmentedControl : UISegmentedControl
    var shouldUpdateSegmentedControl : Bool
    
    required public init?(coder aDecoder: NSCoder) {
        segmentedControl = UISegmentedControl()
        shouldUpdateSegmentedControl = true
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        segmentedControl = UISegmentedControl()
        shouldUpdateSegmentedControl = true
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if segmentedControl.superview != nil{
            navigationItem.titleView = segmentedControl
        }
        
        segmentedControl.addTarget(self, action: "segmentedControlChanged:", forControlEvents: .ValueChanged)
    }
    
    public override func reloadPagerTabStripView() {
        super.reloadPagerTabStripView()
        if (isViewLoaded()){
            reloadSegmentedControl()
        }
    }
    
    func reloadSegmentedControl() -> Void{
        segmentedControl.removeAllSegments()
        for (index, item) in pagerTabStripChildViewControllers!.enumerate(){
            
            let child = item as! XLPagerTabStripChildItem
            
            if let image = child.childHeaderForPagerTabStripViewController(self).image{
                segmentedControl.insertSegmentWithImage(image, atIndex: index, animated: false)
            }
            else{
                segmentedControl.insertSegmentWithTitle(child.childHeaderForPagerTabStripViewController(self).title, atIndex: index, animated: false)
            }
        }
        
        let child : XLPagerTabStripChildItem = pagerTabStripChildViewControllers![currentIndex] as! XLPagerTabStripChildItem
        
        segmentedControl.selectedSegmentIndex = currentIndex
        
        if let color = child.childHeaderForPagerTabStripViewController(self).color{
            segmentedControl.tintColor = color
        }
    }
    
    func segmentedControlChanged(sender: UISegmentedControl) -> Void{
        let index = sender.selectedSegmentIndex
        pagerTabStripViewController(self, updateIndicatorFromIndex: 0, toIndex: index)
        shouldUpdateSegmentedControl = false
        moveToViewControllerAtIndex(index)
    }
    
    // MARK: - XLPagerTabStripViewControllerDelegate
    
    override public func pagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex index: Int) {
        if shouldUpdateSegmentedControl{
            let child = pagerTabStripChildViewControllers![index] as! XLPagerTabStripChildItem
            if let color = child.childHeaderForPagerTabStripViewController(self).color{
                segmentedControl.tintColor = color
            }
            segmentedControl.selectedSegmentIndex = pagerTabStripChildViewControllers!.indexOf(pagerTabStripChildViewControllers![index])!
        }
    }
    
    public override func pagerTabStripViewController(pagerTabStripViewController: XLPagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex index: Int, withProgressPercentage progressPercentage: Float, indexWasChanged changed: Bool) {
        if shouldUpdateSegmentedControl{
            let currentIndex = (progressPercentage > 0.5) ? index : fromIndex
            let child = pagerTabStripChildViewControllers![currentIndex] as! XLPagerTabStripChildItem
            if let color = child.childHeaderForPagerTabStripViewController(self).color{
                segmentedControl.tintColor = color
            }
            segmentedControl.selectedSegmentIndex = min(max(0, currentIndex), pagerTabStripChildViewControllers!.count - 1)
            
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    public override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        shouldUpdateSegmentedControl = true
    }
}