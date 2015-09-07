//
//  XLButtonBarView.m
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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeXLButtonBarView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initializeXLButtonBarView];
    }
    return self;
}


-(void)initializeXLButtonBarView
{
    _selectedOptionIndex = 0;
    _selectedBarHeight = 5;
    if ([self.selectedBar superview] == nil){
        [self addSubview:self.selectedBar];
    }
}


-(void)moveToIndex:(NSUInteger)index animated:(BOOL)animated swipeDirection:(XLPagerTabStripDirection)swipeDirection pagerScroll:(XLPagerScroll)pagerScroll
{
    self.selectedOptionIndex = index;
    [self updateSelectedBarPositionWithAnimation:animated swipeDirection:swipeDirection pagerScroll:pagerScroll];
}

-(void)moveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex withProgressPercentage:(CGFloat)progressPercentage pagerScroll:(XLPagerScroll)pagerScroll
{
    self.selectedOptionIndex = (progressPercentage > 0.5 ) ? toIndex : fromIndex;
    
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]];
    CGRect fromFrame = attributes.frame;
    NSInteger numberOfItems = [self.dataSource collectionView:self numberOfItemsInSection:0];
    CGRect toFrame;
    if (toIndex < 0 || toIndex > [self.dataSource collectionView:self numberOfItemsInSection:0] - 1){
        if (toIndex < 0) {
            UICollectionViewLayoutAttributes * cellAtts = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            toFrame = CGRectOffset(cellAtts.frame, -cellAtts.frame.size.width, 0);
        }
        else{
            UICollectionViewLayoutAttributes * cellAtts = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:(numberOfItems - 1) inSection:0]];
            toFrame = CGRectOffset(cellAtts.frame, cellAtts.frame.size.width, 0);
        }
    }
    else{
        toFrame = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]].frame;
    }
    CGRect targetFrame = fromFrame;
    targetFrame.size.height = self.selectedBar.frame.size.height;
    targetFrame.size.width += (toFrame.size.width - fromFrame.size.width) * progressPercentage;
    targetFrame.origin.x += (toFrame.origin.x - fromFrame.origin.x) * progressPercentage;
    NSUInteger offset = 35;
    float xValue = 0;
    if (self.contentSize.width > self.frame.size.width){
        xValue = MIN(self.contentSize.width - self.frame.size.width, targetFrame.origin.x - offset <= 0 ? 0 : targetFrame.origin.x - offset);
    }
    [self setContentOffset:CGPointMake(xValue, 0) animated:(ABS(self.contentOffset.x - xValue) > 30)];
    self.selectedBar.frame = CGRectMake(targetFrame.origin.x, self.selectedBar.frame.origin.y, targetFrame.size.width, self.selectedBar.frame.size.height);
}


-(void)updateSelectedBarPositionWithAnimation:(BOOL)animation swipeDirection:(XLPagerTabStripDirection __unused)swipeDirection pagerScroll:(XLPagerScroll)pagerScroll
{
    CGRect frame = self.selectedBar.frame;
    
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedOptionIndex inSection:0]];
    CGRect cellFrame = attributes.frame;
    
    [self updateContentOffsetAnimated:animation pagerScroll:pagerScroll toFrame:cellFrame];
    
    frame.size.width = cellFrame.size.width;
    frame.origin.x = cellFrame.origin.x;
    if (animation){
        [UIView animateWithDuration:0.3 animations:^{
            [self.selectedBar setFrame:frame];
        }];
    }
    else{
        self.selectedBar.frame = frame;
    }
}



#pragma mark - Helpers

-(void)updateContentOffsetAnimated:(BOOL)animated pagerScroll:(XLPagerScroll)pageScroller toFrame:(CGRect)frame
{
    if (pageScroller != XLPagerScrollNO){
        CGFloat leftInset = ((UICollectionViewFlowLayout *)self.collectionViewLayout).sectionInset.left;
        if (pageScroller == XLPagerScrollOnlyIfOutOfScreen){
            if  (frame.origin.x  >= self.contentOffset.x && frame.origin.x < (self.contentOffset.x + self.frame.size.width - leftInset)){
                return;
            }
        }
        NSUInteger offset = 30;
        float xValue = MIN(
                           MAX(0,
                               self.collectionViewLayout.collectionViewContentSize.width - self.frame.size.width), // dont scroll if we are at the end of scroll view, if content is smaller than container width we scroll 0
                           MAX(leftInset - frame.origin.x, frame.origin.x - leftInset -  offset)
                           );
        [self setContentOffset:CGPointMake(xValue, 0) animated:animated];
    }
}


#pragma mark - Properties

-(void)setSelectedBarHeight:(CGFloat)selectedBarHeight
{
    _selectedBarHeight = selectedBarHeight;
    _selectedBar.frame = CGRectMake(_selectedBar.frame.origin.x, self.frame.size.height - _selectedBarHeight, _selectedBar.frame.size.width, _selectedBarHeight);
}

-(UIView *)selectedBar
{
    if (_selectedBar) return _selectedBar;
    _selectedBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - _selectedBarHeight, 0, _selectedBarHeight)];
    _selectedBar.layer.zPosition = 9999;
    _selectedBar.backgroundColor = [UIColor blackColor];
    return _selectedBar;
}

@end
