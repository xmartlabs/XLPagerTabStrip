//
//  PagerTabStripError.swift
//  XLPagerTabStrip
//
//  Created by Martin Barreto on 1/20/16.
//
//

import Foundation

public enum PagerTabStripError: ErrorType {
    case DataSourceMustNotBeNil
    case ChildViewControllerMustConformToPagerTabStripChildItem
    case CurrentIndexIsGreaterThanChildsCount
    case PagerTabStripChildViewControllersMustContainAtLeastOneViewController
    case ViewControllerNotContainedInPagerTabStripChildViewControllers
}