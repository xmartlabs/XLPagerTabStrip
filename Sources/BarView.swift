//  BarView.swift
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

public class BarView: UIView{
    public lazy var selectedBar: UIView = { [unowned self] in
        let selectedBar = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        return selectedBar
    }()
    
    var optionsAmount: Int = 1
    var selectedOptionIndex: Int = 0
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
        addSubview(selectedBar)
        updateSelectedBarPositionWithAnimation(false)
    }
    
    public init(frame: CGRect, optionsAmount: Int, selectedOptionIndex: Int) {
        self.optionsAmount = optionsAmount
        self.selectedOptionIndex = selectedOptionIndex
        super.init(frame: frame)
        
        selectedBar = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        addSubview(selectedBar)
        updateSelectedBarPositionWithAnimation(false)
    }
    
    // MARK: - Helpers
    
    func updateSelectedBarPositionWithAnimation(animation: Bool) -> Void{
        var frame = selectedBar.frame
        frame.size.width = self.frame.size.width / CGFloat(optionsAmount)
        frame.origin.x = frame.size.width * CGFloat(selectedOptionIndex)
        if animation{
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.selectedBar.frame = frame
            })
        }
        else{
            selectedBar.frame = frame
        }
    }
    
    public func moveToIndex(index index: Int, animated: Bool) -> Void{
        selectedOptionIndex = index
        updateSelectedBarPositionWithAnimation(animated)
    }
    
    public func moveToIndex(fromIndex fromIndex: Int, toIndex: Int, progressPercentage: Float) -> Void {
        selectedOptionIndex = (progressPercentage > 0.5) ? toIndex : fromIndex
        
        var newFrame = selectedBar.frame
        newFrame.size.width = frame.size.width / CGFloat(optionsAmount)
        var fromFrame = newFrame
        fromFrame.origin.x = newFrame.size.width * CGFloat(fromIndex)
        var toFrame = newFrame
        toFrame.origin.x = toFrame.size.width * CGFloat(toIndex)
        var targetFrame = fromFrame
        targetFrame.origin.x += (toFrame.origin.x - targetFrame.origin.x) * CGFloat(progressPercentage)
        selectedBar.frame = targetFrame
    }
    
    public func setOptionsAmount(optionsAmount optionsAmount: Int, animated: Bool) -> Void {
        self.optionsAmount = optionsAmount
        
        if optionsAmount <= selectedOptionIndex {
            selectedOptionIndex = optionsAmount - 1
        }
        
        updateSelectedBarPositionWithAnimation(animated)
    }
    
    public override func layoutSubviews() {
        updateSelectedBarPositionWithAnimation(false)
    }
}
