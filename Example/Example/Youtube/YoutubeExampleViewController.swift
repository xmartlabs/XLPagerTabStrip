//  YoutubeExampleViewController.swift
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
import XLPagerTabStrip

class YoutubeExampleViewController: BaseButtonBarPagerTabStripViewController<YoutubeIconCell> {

    let redColor = UIColor(red: 221/255.0, green: 0/255.0, blue: 19/255.0, alpha: 1.0)
    let unselectedIconColor = UIColor(red: 73/255.0, green: 8/255.0, blue: 10/255.0, alpha: 1.0)

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buttonBarItemSpec = ButtonBarItemSpec.nibFile(nibName: "YoutubeIconCell", bundle: Bundle(for: YoutubeIconCell.self), width: { (cell: IndicatorInfo) -> CGFloat in
                return 55.0
        })
    }
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = redColor
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0)
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: YoutubeIconCell?, newCell: YoutubeIconCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.iconImage.tintColor = self?.unselectedIconColor
            newCell?.iconImage.tintColor = .white
            
        }
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = TableChildExampleViewController(style: .plain, itemInfo: IndicatorInfo(title: " HOME", image: UIImage(named: "home")))
        let child_2 = TableChildExampleViewController(style: .plain, itemInfo: IndicatorInfo(title: " TRENDING", image: UIImage(named: "trending")))
        let child_3 = ChildExampleViewController(itemInfo: IndicatorInfo(title: " ACCOUNT", image: UIImage(named: "profile")))
        return [child_1, child_2, child_3]
    }
    
    
    override func configure(cell: YoutubeIconCell, for indicatorInfo: IndicatorInfo) {
        cell.iconImage.image = indicatorInfo.image?.withRenderingMode(.alwaysTemplate)
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex, withProgressPercentage: progressPercentage, indexWasChanged: indexWasChanged)
        if indexWasChanged && toIndex > -1 && toIndex < viewControllers.count {
            let child = viewControllers[toIndex] as! IndicatorInfoProvider
            UIView.performWithoutAnimation({ [weak self] () -> Void in
                guard let me = self else { return }
                me.navigationItem.leftBarButtonItem?.title =  child.indicatorInfo(for: me).title
            })
        }
    }
    
    // MARK: - Actions

    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}





