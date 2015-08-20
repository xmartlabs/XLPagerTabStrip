//
//  XLButtonBarPagerTabStripViewController.m
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

#import "XLButtonBarViewCell.h"
#import "XLButtonBarPagerTabStripViewController.h"

@interface XLButtonBarPagerTabStripViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) IBOutlet XLButtonBarView * buttonBarView;
@property (nonatomic) BOOL shouldUpdateButtonBarView;

@end

@implementation XLButtonBarPagerTabStripViewController
{
    XLButtonBarViewCell * _sizeCell;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldUpdateButtonBarView = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.shouldUpdateButtonBarView = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.buttonBarView.superview){
        [self.view addSubview:self.buttonBarView];
    }
    if (!self.buttonBarView.delegate){
        self.buttonBarView.delegate = self;
    }
    if (!self.buttonBarView.dataSource){
        self.buttonBarView.dataSource = self;
    }
    self.buttonBarView.labelFont = [UIFont boldSystemFontOfSize:18.0f];
    self.buttonBarView.leftRightMargin = 8;
    [self.buttonBarView setScrollsToTop:NO];
    UICollectionViewFlowLayout * flowLayout = (id)self.buttonBarView.collectionViewLayout;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.buttonBarView setShowsHorizontalScrollIndicator:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.buttonBarView layoutIfNeeded];
    [self.buttonBarView moveToIndex:self.currentIndex animated:NO swipeDirection:XLPagerTabStripDirectionNone pagerScroll:(self.isProgressiveIndicator ? XLPagerScrollYES  :XLPagerScrollOnlyIfOutOfScreen)];
}

-(void)reloadPagerTabStripView
{
    [super reloadPagerTabStripView];
    if ([self isViewLoaded]){
        [self.buttonBarView reloadData];
        [self.buttonBarView moveToIndex:self.currentIndex animated:NO swipeDirection:XLPagerTabStripDirectionNone pagerScroll:XLPagerScrollYES];
    }
}


#pragma mark - Properties

-(XLButtonBarView *)buttonBarView
{
    if (_buttonBarView) return _buttonBarView;
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0, 35, 0, 35)];
    _buttonBarView = [[XLButtonBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f) collectionViewLayout:flowLayout];
    _buttonBarView.backgroundColor = [UIColor orangeColor];
    _buttonBarView.selectedBar.backgroundColor = [UIColor blackColor];
    _buttonBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return _buttonBarView;
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
          updateIndicatorFromIndex:(NSInteger)fromIndex
                           toIndex:(NSInteger)toIndex
{
    if (self.shouldUpdateButtonBarView){
        XLPagerTabStripDirection direction = XLPagerTabStripDirectionLeft;
        if (toIndex < fromIndex){
            direction = XLPagerTabStripDirectionRight;
        }
        [self.buttonBarView moveToIndex:toIndex animated:YES swipeDirection:direction pagerScroll:XLPagerScrollYES];
        if (self.changeCurrentIndexBlock) {
            XLButtonBarViewCell *oldCell = (XLButtonBarViewCell*)[self.buttonBarView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex != fromIndex ? fromIndex : toIndex inSection:0]];
            XLButtonBarViewCell *newCell = (XLButtonBarViewCell*)[self.buttonBarView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
            self.changeCurrentIndexBlock(oldCell, newCell, YES);
        }
    }
}

-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
          updateIndicatorFromIndex:(NSInteger)fromIndex
                           toIndex:(NSInteger)toIndex
            withProgressPercentage:(CGFloat)progressPercentage
                   indexWasChanged:(BOOL)indexWasChanged
{
    if (self.shouldUpdateButtonBarView){
        [self.buttonBarView moveFromIndex:fromIndex
                                  toIndex:toIndex
                   withProgressPercentage:progressPercentage pagerScroll:XLPagerScrollYES];
        
        if (self.changeCurrentIndexProgressiveBlock) {
            XLButtonBarViewCell *oldCell = (XLButtonBarViewCell*)[self.buttonBarView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex != fromIndex ? fromIndex : toIndex inSection:0]];
            XLButtonBarViewCell *newCell = (XLButtonBarViewCell*)[self.buttonBarView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
            self.changeCurrentIndexProgressiveBlock(oldCell, newCell, progressPercentage, indexWasChanged, YES);
        }
    }
}

#pragma merk - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel * label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    label.font = self.buttonBarView.labelFont;
    UIViewController<XLPagerTabStripChildItem> * childController =   [self.pagerTabStripChildViewControllers objectAtIndex:indexPath.item];
    [label setText:[childController titleForPagerTabStripViewController:self]];
    CGSize labelSize = [label intrinsicContentSize];
    
    return CGSizeMake(labelSize.width + (self.buttonBarView.leftRightMargin * 2), collectionView.frame.size.height);
}

#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //There's nothing to do if we select the current selected tab
	if (indexPath.item == self.currentIndex)
		return;
	
    [self.buttonBarView moveToIndex:indexPath.item animated:YES swipeDirection:XLPagerTabStripDirectionNone pagerScroll:XLPagerScrollYES];
    self.shouldUpdateButtonBarView = NO;
    
    XLButtonBarViewCell *oldCell = (XLButtonBarViewCell*)[self.buttonBarView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
    XLButtonBarViewCell *newCell = (XLButtonBarViewCell*)[self.buttonBarView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
    if (self.isProgressiveIndicator) {
        if (self.changeCurrentIndexProgressiveBlock) {
            self.changeCurrentIndexProgressiveBlock(oldCell, newCell, 1, YES, YES);
        }
    }
    else{
        if (self.changeCurrentIndexBlock) {
            self.changeCurrentIndexBlock(oldCell, newCell, YES);
        }
    }
    
    [self moveToViewControllerAtIndex:indexPath.item];
}

#pragma merk - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pagerTabStripChildViewControllers.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XLButtonBarViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if (!cell){
        cell = [[XLButtonBarViewCell alloc] initWithFrame:CGRectMake(0, 0, 50, self.buttonBarView.frame.size.height)];
    }
    NSAssert([cell isKindOfClass:[XLButtonBarViewCell class]], @"UICollectionViewCell should be or extend XLButtonBarViewCell");
    XLButtonBarViewCell * buttonBarCell = (XLButtonBarViewCell *)cell;
    UIViewController<XLPagerTabStripChildItem> * childController =   [self.pagerTabStripChildViewControllers objectAtIndex:indexPath.item];
    
    [buttonBarCell.label setText:[childController titleForPagerTabStripViewController:self]];
    
    
    if (self.isProgressiveIndicator) {
        if (self.changeCurrentIndexProgressiveBlock) {
            self.changeCurrentIndexProgressiveBlock(self.currentIndex == indexPath.item ? nil : cell , self.currentIndex == indexPath.item ? cell : nil, 1, YES, NO);
        }
    }
    else{
        if (self.changeCurrentIndexBlock) {
            self.changeCurrentIndexBlock(self.currentIndex == indexPath.item ? nil : cell , self.currentIndex == indexPath.item ? cell : nil, NO);
        }
    }
    
    return buttonBarCell;
}


#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [super scrollViewDidEndScrollingAnimation:scrollView];
    if (scrollView == self.containerView){
        self.shouldUpdateButtonBarView = YES;
    }
}


@end
