# XLPagerTabStrip

<p align="left">
<a href="https://travis-ci.org/xmartlabs/XLPagerTabStrip"><img src="https://travis-ci.org/xmartlabs/XLPagerTabStrip.svg?branch=master" alt="Build status" /></a>
<img src="https://img.shields.io/badge/platform-iOS-blue.svg?style=flat" alt="Platform iOS" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat" alt="Swift 2 compatible" /></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
<a href="https://cocoapods.org/pods/XLActionController"><img src="https://img.shields.io/badge/pod-4.0.0-blue.svg" alt="CocoaPods compatible" /></a>
<a href="https://raw.githubusercontent.com/xmartlabs/XLPagerTabStrip/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>
</p>

Made with ❤️ by [Xmartlabs](http://xmartlabs.com).

Android [PagerTabStrip](http://developer.android.com/reference/android/support/v4/view/PagerTabStrip.html) for iOS!

**XLPagerTabStrip** is a *Container View Controller* that allows us to switch easily among a collection of view controllers. Pan gesture can be used to move on to next or previous view controller. It shows a interactive indicator of the current, previous, next child view controllers.

<table>
  <tr>
    <th><img src="Example/instagram.gif" width="250"/></th>
    <th><img src="Example/spotify.gif" width="250"/></th>
    <th><img src="Example/youtube.gif" width="250"/></th>
    <th><img src="Example/pagerTabStripTypes.gif" width="250"/></th>
  </tr>
</table>

The library provides many ways to show the PagerTabStrip menu.

## Usage


Basically we just need to provide the list of child view controllers to show and these view controllers should provide the information (title or image) to show in the associated indicator.

Let's see the steps to do this:

##### Choose which type of pager we want to create

Fist step is choose how we want to show our pager step controller, it must extend from any of the following controllers: `TwitterPagerTabStripViewController`, `ButtonBarPagerTabStripViewController`, `SegmentedPagerTabStripViewController`, `BarPagerTabStripViewController`.

> All these build-in pager controllers extend from the base class `PagerTabStripViewController`.
> You can also make your custom pager controller by extending directly from `PagerTabStripViewController` in case no pager menu type fits your needs.

```swift
import XLPagerTabStrip

class MyPagerTabStripName: ButtonBarPagerTabStripViewController {
  ..
}
```

##### Connect outlets and add layout constraints

We strongly recommend to use IB to set up your page controller views.

Drag into the storyboard a `UIViewController` and set up its class with your pager controller (`MyPagerTabStripName`).
Drag a `UIScrollView` into your view controller view and connect `PagerTabStripViewController` `contentView` outlet with the scroll view.

Depending on which type of paging view controller you are working with you may have to connect more outlets.

For `BarPagerTabStripViewController` you should connect `barView` outlet.
For `ButtonBarPagerTabStripViewController` you should connect `buttonBarView` outlet.
For `SegmentedPagerTabStripViewController` you should connect `segmentedControl` outlet.
`TwitterPagerTabStripViewController` doesn't require to connect any additional outlet.

> The example project contains a example for each pager controller type and you can look into it to see how views were added and how outlets were connected.

##### Provide view controllers that will appear embedded into the PagerTabStrip view controller

You can provide the view controllers by overriding `func childViewControllersForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> [UIViewController]` method.

```swift
override public func childViewControllersForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
  return [MyEmbeddedViewController(), MySecondEmbeddedViewController()]
}
```

> The method above is the only method contained in `PagerTabStripViewControllerDataSource`. We don't need to explicitly conform to it since base pager class already does it.


##### Provide information to show in each indicator

Every UIViewController that will appear in the PagerTabStrip controller should conforms to `PagerTabStripChildItem`. The only method this protocol requires to implement is `func childHeaderForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> ChildItemInfo`
 which provides the information required to show the PagerTabStrip menu (indicator) associated with the view controller.

```swift
class MyEmbeddedViewController: UITableViewController, PagerTabStripChildItem {

  func childInfoForPagerTabStripViewController(pagerTabStripController: PagerTabStripViewController) -> ChildItemInfo {
    return ChildItemInfo(title: "My Child title")
  }
}
```

That's it! We're done! 🍻🍻


## Customization



## Requirements

* iOS 8.0+
* Xcode 7.2+

## Getting involved

* If you **want to contribute** please feel free to **submit pull requests**.
* If you **have a feature request** please **open an issue**.
* If you **found a bug** or **need help** please **check older issues, [FAQ](#faq) and threads on [StackOverflow](http://stackoverflow.com/questions/tagged/XLPagerTabStrip) (Tag 'XLPagerTabStrip') before submitting an issue**.

Before contribute check the [CONTRIBUTING](CONTRIBUTING.md) file for more info.

If you use **XLPagerTabStrip** in your app We would love to hear about it! Drop us a line on [twitter](https://twitter.com/xmartlabs).

## Examples

Follow these 3 steps to run Example project: Clone XLPagerTabStrip repository, open XLPagerTabStrip workspace and run the *Example* project.

You can also experiment and learn with the *XLPagerTabStrip Playground* which is contained in *XLPagerTabStrip.workspace*.

## Installation

#### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

To install XLPagerTabStrip, simply add the following line to your Podfile:

```ruby
pod 'XLPagerTabStrip', '~> 4.0'
```

#### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a simple, decentralized dependency manager for Cocoa.

To install XLPagerTabStrip, simply add the following line to your Cartfile:

```ogdl
github "xmartlabs/XLPagerTabStrip" ~> 4.0
```

## Author

* [Martin Barreto](https://github.com/mtnBarreto) ([@mtnBarreto](https://twitter.com/mtnBarreto))


## Change Log

This can be found in the [CHANGELOG.md](CHANGELOG.md) file.
