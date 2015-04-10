//
//  XLBarView.m
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
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

#import "XLBarView.h"

@interface XLBarView()

@property UIView * selectedBar;
@property NSUInteger optionsAmount;
@property NSUInteger selectedOptionIndex;

@end

@implementation XLBarView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _optionsAmount = 1;
        _selectedOptionIndex = 0;
        [self addSubview:self.selectedBar];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _optionsAmount = 1;
        _selectedOptionIndex = 0;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame optionsAmount:(NSUInteger)optionsAmount selectedOptionIndex:(NSUInteger)selectedOptionIndex
{
    self = [self initWithFrame:frame];
    if (self){
        _optionsAmount = optionsAmount;
        _selectedOptionIndex = selectedOptionIndex;
        [self addSubview:self.selectedBar];
    }
    return self;
}

-(UIView *)selectedBar
{
    if (_selectedBar) return _selectedBar;
    _selectedBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self updateSelectedBarPositionWithAnimation:NO];
    return _selectedBar;
}


#pragma mark - Helpers

-(void)updateSelectedBarPositionWithAnimation:(BOOL)animation
{
    CGRect frame = self.selectedBar.frame;
    frame.size.width = self.frame.size.width / self.optionsAmount;
    frame.origin.x = frame.size.width * self.selectedOptionIndex;
    if (animation){
        [UIView animateWithDuration:0.3 animations:^{
            [self.selectedBar setFrame:frame];
        }];
    }
    else{
        self.selectedBar.frame = frame;
    }
}

-(void)moveToIndex:(NSUInteger)index animated:(BOOL)animated
{
    self.selectedOptionIndex = index;
    [self updateSelectedBarPositionWithAnimation:animated];
}

-(void)moveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex withProgressPercentage:(CGFloat)progressPercentage
{
    self.selectedOptionIndex = (progressPercentage > 0.5) ? toIndex : fromIndex;
    
    CGRect newFrame = self.selectedBar.frame;
    newFrame.size.width = self.frame.size.width / self.optionsAmount;
    CGRect fromFrame = newFrame;
    fromFrame.origin.x = newFrame.size.width * fromIndex;
    CGRect toFrame = newFrame;
    toFrame.origin.x = toFrame.size.width * toIndex;
    CGRect targetFrame = fromFrame;
    targetFrame.origin.x += (toFrame.origin.x-targetFrame.origin.x)*progressPercentage;
    self.selectedBar.frame = targetFrame;
}


-(void)setOptionsAmount:(NSUInteger)optionsAmount animated:(BOOL)animated
{
    self.optionsAmount = optionsAmount;
    if (self.optionsAmount <= self.selectedOptionIndex){
        self.selectedOptionIndex = self.optionsAmount - 1;
    }
    [self updateSelectedBarPositionWithAnimation:animated];
}

-(void)layoutSubviews
{
    [self updateSelectedBarPositionWithAnimation:NO];
}

@end
