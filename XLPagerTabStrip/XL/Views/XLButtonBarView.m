//
//  XLButtonBarView.m
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2014 Xmartlabs ( http://xmartlabs.com )
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


#import "XLButtonBarView.h"

@interface XLButtonBarView ()

@property UIView * selectedBar;
@property NSUInteger selectedOptionIndex;

@end

@implementation XLButtonBarView


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeXLButtonBarView];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeXLButtonBarView];
    }
    return self;
}

-(void)initializeXLButtonBarView
{
    _selectedOptionIndex = 0;
    [self addSubview:self.selectedBar];
}


-(void)moveToIndex:(NSUInteger)index animated:(BOOL)animated swipeDirection:(XLPagerTabStripDirection)swipeDirection
{
    self.selectedOptionIndex = index;
    [self updateSelectedBarPositionWithAnimation:animated swipeDirection:swipeDirection];
}


-(void)updateSelectedBarPositionWithAnimation:(BOOL)animation swipeDirection:(XLPagerTabStripDirection)swipeDirection
{
    CGRect frame = self.selectedBar.frame;
    UICollectionViewCell * cell = [self.dataSource collectionView:self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedOptionIndex inSection:0]];
    if (cell){
        if (swipeDirection != XLPagerTabStripDirectionNone){
            if (swipeDirection == XLPagerTabStripDirectionLeft)
            {
                float xValue = MIN(self.contentSize.width - self.frame.size.width, cell.frame.origin.x <= 35 ? 0 : cell.frame.origin.x - 35);
                [self  setContentOffset:CGPointMake(xValue, 0) animated:animation];
            }
            else if (swipeDirection == XLPagerTabStripDirectionRight){
                float xValue = MAX(0, cell.frame.origin.x + cell.frame.size.width - self.frame.size.width + 35);
                [self  setContentOffset:CGPointMake(xValue, 0) animated:animation];
            }
            
        }
    }
    frame.size.width = cell.frame.size.width;
    frame.origin.x = cell.frame.origin.x;
    frame.origin.y = cell.frame.size.height - frame.size.height;
    if (animation){
        [UIView animateWithDuration:0.3 animations:^{
            [self.selectedBar setFrame:frame];
        }];
    }
    else{
        self.selectedBar.frame = frame;
    }
}


#pragma mark - Properties

-(UIView *)selectedBar
{
    if (_selectedBar) return _selectedBar;
    _selectedBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 5, self.frame.size.width, 5)];
    _selectedBar.layer.zPosition = 9999;
    _selectedBar.backgroundColor = [UIColor blackColor];
    return _selectedBar;
}


@end
