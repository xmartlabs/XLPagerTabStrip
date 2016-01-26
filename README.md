# XLPagerTabStrip

<p align="left">
<a href="https://travis-ci.org/xmartlabs/XLPagerTabStrip"><img src="https://travis-ci.org/xmartlabs/XLPagerTabStrip.svg?branch=master" alt="Build status" /></a>
<img src="https://img.shields.io/badge/platform-iOS-blue.svg?style=flat" alt="Platform iOS" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat" alt="Swift 2 compatible" /></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
<a href="https://cocoapods.org/pods/XLActionController"><img src="https://img.shields.io/badge/pod-4.0.0-blue.svg" alt="CocoaPods compatible" /></a>
<a href="https://raw.githubusercontent.com/xmartlabs/XLPagerTabStrip/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>
</p>

Made with ❤️ By [Xmartlabs](http://xmartlabs.com).

Android [PagerTabStrip](http://developer.android.com/reference/android/support/v4/view/PagerTabStrip.html) for iOS!

**XLPagerTabStrip** is a *Container View Controller* that allows us to switch easily among a collection of view controllers. Pan gesture can be used to move on to next or previous view controller. It shows a interactive indicator of the current, previous, next child view controllers.

![Screenshot of native Calendar Event Example](XLPagerTabStrip/Demo/PagerSlidingTabStrip.gif)

## Usage

In order to use the library we just need to provide the list of child view controllers to show, these view controller should provide the information (title or image) to show in the associated indicator.

Let's see how to do this:

The fist step is select the way we want to show the indicator. The library provides  As you may have noticed the library provides differents ways to show

Using XLPagerTabStrip is as easy as following these steps:

1. Import the library

```swift
import XLPagerTabStrip
```

2.







## Requirements

* iOS 8.0+
* Xcode 7.2+

## Getting involved

* If you **want to contribute** please feel free to **submit pull requests**.
* If you **have a feature request** please **open an issue**.
* If you **found a bug** or **need help** please **check older issues, [FAQ](#faq) and threads on [StackOverflow](http://stackoverflow.com/questions/tagged/XLPagerTabStrip) (Tag 'XLPagerTabStrip') before submitting an issue.**.

Before contribute check the [CONTRIBUTING](https://github.com/xmartlabs/XLPagerTabStrip/blob/master/CONTRIBUTING.md) file for more info.

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
github "xmartlabs/XLPagerTabStrip" ~> 1.0
```

## Author

* [Xmartlabs SRL](https://github.com/xmartlabs) ([@xmartlabs](https://twitter.com/xmartlabs))

## FAQ

#### How to .....

You can do it by conforming to .....

# Change Log

This can be found in the [CHANGELOG.md](CHANGELOG.md) file.
