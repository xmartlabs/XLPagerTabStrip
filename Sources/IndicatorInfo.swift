//  IndicatorInfo.swift
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

public struct IndicatorInfo {
    
    public var title: String
    public var image: UIImage?
    public var highlightedImage: UIImage?
    
    public init(title: String) {
        self.title = title
    }
    
    public init(title: String, image: UIImage?) {
        self.init(title: title)
        self.image = image
    }
    
    public init(title: String, image: UIImage?, highlightedImage: UIImage?) {
        self.init(title: title, image: image)
        self.highlightedImage = highlightedImage
    }
}


extension IndicatorInfo : ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String){
        title = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String){
        title = value
    }
    
    public init(unicodeScalarLiteral value: String){
        title = value
    }
}
