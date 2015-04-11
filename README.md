XLPagerTabStrip
---------------

By [XMARTLABS](http://xmartlabs.com).

Android [PagerTabStrip](http://developer.android.com/reference/android/support/v4/view/PagerTabStrip.html) for iOS!

**XLPagerTabStrip** is a *Container View Controller* that allows us to switch easily among a collection of view controllers. Pan gesture can be used to move on to next or previous view controller. It shows a interactive indicator of the current, previous, next child view controllers.  

![Screenshot of native Calendar Event Example](XLPagerTabStrip/Demo/PagerSlidingTabStrip.gif)

XLPagerTabStrip was originally inspired by [Tell market](http://about.tellmarket.com/) app.

Purpose
--------
 **XLPagerTabStrip** helps us deal with view controllers that have the same relevance for the user like Android PagerTabStrip and PageView do.  Since you're able to navigate between a large amount of view controllers, XLPagerTabStrip is an scalable and nice solution for this problem.


How to use it
--------------

Integrate `XLPagerTabStrip` is as easy as following these steps:

1. Create a UIViewController class that should extend from either `XLSegmentedPagerTabStripViewController`, `XLBarPagerTabStripViewController`, `XLButtonBarPagerTabStripViewController`, `XLTwitterPagerTabStripViewController`.

2. The recently created concrete view controller should conform to `XLPagerTabStripViewControllerDataSource` implementing: `-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController;`

3. (Recomended) Set up your view controllers using a nib file or a Storyboard. We need to connect some IBOutlets (take a look at the [Demo folder](XLPagerTabStrip/Demo)).

4.  Enjoy!

For further details take a look at the [Demo folder](XLPagerTabStrip/Demo) to see the code of examples shown above.

FAQ
----------------------

#####How to change the visible child view controller programmatically

`XLPagerTabStripViewController` provides the following methods to programmatically change the visible child view controller:

```objc
-(void)moveToViewControllerAtIndex:(NSUInteger)index;
-(void)moveToViewController:(UIViewController *)viewController;
```

Installation
--------------------------

The easiest way to use `XLPagerTabStrip` in your app is via [CocoaPods](http://cocoapods.org/ "CocoaPods").

1. Add the following line in the project's Podfile file:
`pod 'XLPagerTabStrip', '~> 1.0'`.
2. Run the command `pod install` from the Podfile folder directory.


Customization
--------------

The most interesting customizable features are:

* Ability to skip intermediate view controllers when tapped on a "tab".
* Indicators can be added at any position of the screen through storyboard layouts.
* Choose between progressive, non-progressive indicators.
* Add space padding between view controllers.



Requirements
-----------------------------

* ARC
* iOS 7.1 and above


Release Notes
--------------

Version 1.1.0

* Twitter pager added
* Bug fixes and stability improvements

Version 1.0.0

* Initial release

Author
-----------------

[Martin Barreto](https://www.github.com/mtnBarreto "Martin Barreto Github") ([@mtnBarreto](http://twitter.com/mtnBarreto "@mtnBarreto"))

Contributors
----------------

* Washington Miranda
* Martin Pastorin
* [Full contributors list](https://github.com/xmartlabs/XLPagerTabStrip/graphs/contributors)

Contact
----------------

Any suggestion or question? Please create a Github issue or reach us out.

[xmartlabs.com](http://xmartlabs.com).
[@xmartlabs](http://twitter.com/xmartlabs "@xmartlabs")
