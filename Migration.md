## How to migrate from Swift 2 to Swift 3

To migrate from Swift 2 to Swift 3 you have to change the naming of some of the functions you call or override. These are the name changes for version 6.0+ in `PagerTabStripViewController`:

| Swift 2 function name | Swift 3 function name |
| --------------------- | --------------------- |
| `func viewControllersForPagerTabStrip(_ pagerTabStripController: PagerTabStripViewController) -> [UIViewController]` | `func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController]` |
| `func indicatorInfoForPagerTabStrip(_ pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo` | `func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo` |
| `func pagerTabStripViewController(_ pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int)` | `func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int)` |
| `func pagerTabStripViewController(_ pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool)` | `func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool)` |
| `func moveToViewControllerAtIndex(_ index: Int, animated: Bool = true)` | `func moveToViewController(at index: Int, animated: Bool = true)` |
| `func moveToViewController(_ viewController: UIViewController, animated: Bool = true)` | `func moveTo(viewController: UIViewController, animated: Bool = true)` |
| `func canMoveToIndex(index: Int) -> Bool` | `func canMoveTo(index: Int) -> Bool` |
| ` func pageOffsetForChildIndex(index: Int) -> CGFloat` | `func pageOffsetForChild(at index: Int) -> CGFloat` |
| `func offsetForChildIndex(_ index: Int) -> CGFloat` | `func offsetForChild(at index: Int) -> CGFloat` |
| `func offsetForChildViewController(_ viewController: UIViewController) throws -> CGFloat` | `func offsetForChild(viewController: UIViewController) throws -> CGFloat` |
| `func pageForContentOffset(_ contentOffset: CGFloat) -> Int` | `func pageFor(contentOffset: CGFloat) -> Int` |
| `func virtualPageForContentOffset(_ contentOffset: CGFloat) -> Int` | `func virtualPageFor(contentOffset: CGFloat) -> Int` |
| `func pageForVirtualPage(_ virtualPage: Int) -> Int` | `func pageFor(virtualPage: Int) -> Int` |

You can check all the changes in [this pull request](https://github.com/xmartlabs/XLPagerTabStrip/pull/226)