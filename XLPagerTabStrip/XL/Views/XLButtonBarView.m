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
    if ([self.selectedBar superview] == nil){
        [self addSubview:self.selectedBar];
    }
}


-(void)moveToIndex:(NSUInteger)index animated:(BOOL)animated swipeDirection:(XLPagerTabStripDirection)swipeDirection
{
    self.selectedOptionIndex = index;
    [self updateSelectedBarPositionWithAnimation:animated swipeDirection:swipeDirection];
}

-(void)moveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex withProgressPercentage:(CGFloat)progressPercentage
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
    //NSLog(@"X value: %@", @(xValue));
    [self setContentOffset:CGPointMake(xValue, 0) animated:NO];
    self.selectedBar.frame = CGRectMake(targetFrame.origin.x, self.selectedBar.frame.origin.y, targetFrame.size.width, self.selectedBar.frame.size.height);
}


-(void)updateSelectedBarPositionWithAnimation:(BOOL)animation swipeDirection:(XLPagerTabStripDirection)swipeDirection
{
    CGRect frame = self.selectedBar.frame;
    UICollectionViewCell * cell = [self.dataSource collectionView:self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedOptionIndex inSection:0]];
    
    [self updateContentOffset];
    
    frame.size.width = cell.frame.size.width;
    frame.origin.x = cell.frame.origin.x;
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

-(void)updateContentOffset
{
    UICollectionViewCell * cell = [self.dataSource collectionView:self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedOptionIndex inSection:0]];
    if (cell){
        NSUInteger offset = 35;
        float xValue = MIN(
                           MAX(0,
                               self.contentSize.width - self.frame.size.width), // dont scroll if we are at the end of scroll view, if content is smaller than container width we scroll 0
                           MAX(((UICollectionViewFlowLayout *)self.collectionViewLayout).sectionInset.left - cell.frame.origin.x,
                               cell.frame.origin.x - ((UICollectionViewFlowLayout *)self.collectionViewLayout).sectionInset.left -  offset)
                           
                           );
        [self setContentOffset:CGPointMake(xValue, 0) animated:YES];
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
