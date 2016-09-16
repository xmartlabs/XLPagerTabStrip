# Change Log
All notable changes to XLPagerTabStrip will be documented in this file.

### [6.0.0](https://github.com/xmartlabs/XLPagerTabStrip/releases/tag/5.0.0)

* Swift 3 support
* **Breaking change**: Swiftified names of functions (you can see more details about it [here](https://github.com/xmartlabs/XLPagerTabStrip/Migration.md))

### [5.1.0](https://github.com/xmartlabs/XLPagerTabStrip/releases/tag/5.0.0)

* Xcode 8 support. (Swift 2.3)

### [5.0.0](https://github.com/xmartlabs/XLPagerTabStrip/releases/tag/5.0.0)

* Xcode 7.3 support.
* Bug fixes and stability improvements.

### [4.0.2](https://github.com/xmartlabs/XLPagerTabStrip/releases/tag/4.0.2)

* Bug fixes

### [4.0.1](https://github.com/xmartlabs/XLPagerTabStrip/releases/tag/4.0.1)

* Bug fixes and stability improvements

### [4.0.0](https://github.com/xmartlabs/XLPagerTabStrip/releases/tag/4.0.0)
<!-- Released on 2016-01-20. -->

* Base code migration from obj-c to swift.
* Removed XL prefix from all types.

### [3.0.0](https://github.com/xmartlabs/XLPagerTabStrip/releases/tag/3.0.0)

* `selectedBarAlignment` added to `XLButtonBarView`.
* `shouldCellsFillAvailableWidth` added to `XLButtonBarView`.
* Bug fixes and Stability improvements.

### [2.0.0](https://github.com/xmartlabs/XLPagerTabStrip/releases/tag/v2.0.0)

* Added ability to change look and feel of selected tab.
* `changeCurrentIndexProgressiveBlock` added to `XLButtonBarPagerTabStripViewController`.
* `changeCurrentIndexBlock` added to `XLButtonBarPagerTabStripViewController`.
* indxWasChanged parameter was added to `-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController updateIndicatorFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex withProgressPercentage:(CGFloat)progressPercentage indexWasChanged:(BOOL)indexWasChanged;`
* Bug Fix Issue #45: When the current tab is tapped by the user, and later swiping to another tab, the indicator now changes as expected.
* Bug Fix: When scrolling between tabs with progressive indicator, the indicator now scrolls swiftly. It used to jump for an instant.
* Bug Fix Issue #54: Twitter PagerTabStrip wasn't loading the navigation title correctly.
* Bug Fix Issue #32: Demo for Nav Button Bar Example fix.
* Bug Fix Issue #32: Twitter Pager white dots that mark which tab is currently selected is non selectable now.
* Bug Fix Issue #22: moveToViewControllerAtIndex: in viewDidLoad or viewWillAppear is not reflected in buttonBarView.

### [1.1.1](https://github.com/xmartlabs/XLPagerTabStrip/releases/tag/v1.1.1)

* Nav Button example added
* Support for iOS 7.0 and above

### [1.1.0](https://github.com/xmartlabs/XLPagerTabStrip/releases/tag/v1.1.0)

* Twitter pager added
* Bug fixes and stability improvements

### [1.0.0](https://github.com/xmartlabs/XLPagerTabStrip/releases/tag/v1.0.0)

* Initial release
