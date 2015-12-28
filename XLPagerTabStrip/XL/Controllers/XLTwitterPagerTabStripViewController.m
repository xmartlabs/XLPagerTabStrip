//
//  XLTwitterPagerTabStripViewController.m
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

#import "XLTwitterPagerTabStripViewController.h"
#import "FXPageControl.h"

@interface XLTwitterPagerTabStripViewController ()

@property (nonatomic) UIView * navigationView;
@property (nonatomic) UIScrollView * navigationScrollView;
@property (nonatomic) FXPageControl * navigationPageControl;
@property (nonatomic, strong) NSMutableArray * navigationItemsViews;

@end


@implementation XLTwitterPagerTabStripViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.navigationView.superview) {
        self.navigationItem.titleView = self.navigationView;
    }
    
    
    [self.navigationView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
    [self.navigationView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.navigationController.navigationBar.frame) , CGRectGetHeight(self.navigationController.navigationBar.frame))];
    
    if (!self.navigationScrollView.superview) {
        [self.navigationView addSubview:self.navigationScrollView];
    }
    
    if (!self.navigationPageControl.superview) {
        [self.navigationView addSubview:self.navigationPageControl];
    }
    
    [self reloadNavigationViewItems];
}

-(void)reloadPagerTabStripView
{
    [super reloadPagerTabStripView];
    if ([self isViewLoaded])
    {
        [self reloadNavigationViewItems];
        [self setNavigationViewItemsPosition];
    }
}

-(void)setIsProgressiveIndicator:(BOOL)isProgressiveIndicator
{
    super.isProgressiveIndicator = YES;
}


#pragma mark - Properties

-(UIView *)navigationView
{
    if (_navigationView) return _navigationView;
    _navigationView = [[UIView alloc] init];
    _navigationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    return _navigationView;
}

- (UIScrollView *)navigationScrollView
{
    if (_navigationScrollView) return _navigationScrollView;
    _navigationScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    _navigationScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _navigationScrollView.bounces = YES;
    _navigationScrollView.scrollsToTop = NO;
    _navigationScrollView.delegate = self;
    _navigationScrollView.showsVerticalScrollIndicator = NO;
    _navigationScrollView.showsHorizontalScrollIndicator = NO;
    _navigationScrollView.pagingEnabled = YES;
    _navigationScrollView.userInteractionEnabled = NO;
    [_navigationScrollView setAlwaysBounceHorizontal:YES];
    [_navigationScrollView setAlwaysBounceVertical:NO];
    return _navigationScrollView;
}

-(NSMutableArray *)navigationItemsViews
{
    if (_navigationItemsViews) return _navigationItemsViews;
    _navigationItemsViews = [[NSMutableArray alloc] init];
    return _navigationItemsViews;
}

-(FXPageControl *)navigationPageControl
{
    if (_navigationPageControl) return _navigationPageControl;
    _navigationPageControl = [[FXPageControl alloc] init];
    [_navigationPageControl setBackgroundColor:[UIColor clearColor]];
    [_navigationPageControl setDotSize:3.8f];
    [_navigationPageControl setDotSpacing:4.0f];
    [_navigationPageControl setDotColor:[UIColor colorWithWhite:1 alpha:0.4]];
    [_navigationPageControl setSelectedDotColor:[UIColor whiteColor]];
    [_navigationPageControl setUserInteractionEnabled:false];
    return _navigationPageControl;
}


#pragma mark - XLPagerTabStripViewControllerDataSource

-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
          updateIndicatorFromIndex:(NSInteger)fromIndex
                           toIndex:(NSInteger)toIndex
{
    // not accept no progressive indicator
}

-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
          updateIndicatorFromIndex:(NSInteger)fromIndex
                           toIndex:(NSInteger)toIndex
            withProgressPercentage:(CGFloat)progressPercentage
             indexWasChanged:(BOOL)indexWasChanged
{
    CGFloat distance = [self getDistanceValue];
    UIAccelerationValue xOffset = 0;
    if (fromIndex < toIndex ){
        xOffset = distance * fromIndex + distance * progressPercentage;
    }
    else if (fromIndex > toIndex){
        xOffset = distance * fromIndex - distance * progressPercentage;
    }
    else{
        xOffset = distance * fromIndex;
    }
    [self.navigationScrollView setContentOffset:CGPointMake(xOffset, 0)];
    [self setAlphaWithOffset:xOffset];
    [_navigationPageControl setCurrentPage:self.currentIndex];
}


#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((object == self.navigationView && [keyPath isEqualToString:@"frame"])){
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeSetting)]){
            CGRect oldRect = [change[NSKeyValueChangeOldKey] CGRectValue];
            CGRect newRect = [change[NSKeyValueChangeNewKey] CGRectValue];
            if (!CGRectEqualToRect(newRect,oldRect)) {
                [self.navigationScrollView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.navigationView.frame) , CGRectGetHeight(self.navigationScrollView.frame))];
                [self setNavigationViewItemsPosition];
            }
        }
    }
}

-(void)dealloc
{
    // Perform a try catch when removing a observer in case it was never registered
    @try {
        [self.navigationView removeObserver:self forKeyPath:@"frame"];
    }
    @catch (NSException * __unused exception) {}
}


#pragma mark - Helpers

-(void)reloadNavigationViewItems
{
    [self.navigationItemsViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.navigationItemsViews removeAllObjects];
    

    [self.pagerTabStripChildViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSAssert([obj conformsToProtocol:@protocol(XLPagerTabStripChildItem)], @"child view controller must conform to XLPagerTabStripChildItem");
        UIViewController<XLPagerTabStripChildItem> * childViewController = (UIViewController<XLPagerTabStripChildItem> *)obj;
        NSString * childText = [childViewController respondsToSelector:@selector(titleForPagerTabStripViewController:)] ? [childViewController titleForPagerTabStripViewController:self] : NSStringFromClass([obj class]);
        UILabel *navTitleLabel = [self createNewLabelWithText:childText];
        [navTitleLabel setAlpha: self.currentIndex == idx ? 1 : 0];
        UIColor * childTextColor = [childViewController respondsToSelector:@selector(colorForPagerTabStripViewController:)] ? [childViewController colorForPagerTabStripViewController:self] : [UIColor whiteColor];;
        [navTitleLabel setTextColor:childTextColor];
        [_navigationScrollView addSubview:navTitleLabel];
        [_navigationItemsViews addObject:navTitleLabel];
    }];
}

-(void)setNavigationViewItemsPosition
{
    [self setNavigationViewItemsPosition:YES];
}

-(void)setNavigationViewItemsPosition:(BOOL)updateAlpha
{
    CGFloat distance = [self getDistanceValue];
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation);
    CGFloat labelHeighSpace = isPortrait ? 34: 25;
    [self.navigationItemsViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int index = (int)idx;
        UILabel *label = (UILabel *)obj;
        if (updateAlpha){
            [label setAlpha:self.currentIndex == idx ? 1 : 0];
        }
        label.font = isPortrait ? self.portraitTitleFont : self.landscapeTitleFont;
        CGSize viewSize = [self getLabelSize:label];
        CGFloat originX = (distance - viewSize.width/2) + index * distance;
        CGFloat originY = (labelHeighSpace - viewSize.height) / 2;
        label.frame = (CGRect){originX, originY + 2, viewSize.width, viewSize.height};
        label.tag = index;
    }];
    
    UIAccelerationValue xOffset = distance * self.currentIndex;
    [self.navigationScrollView setContentOffset:CGPointMake(xOffset, 0)];
    
    // Update Navigation Page Control
    [self.navigationPageControl setNumberOfPages:[self.navigationItemsViews count]];
    [self.navigationPageControl setCurrentPage:self.currentIndex];
    CGSize viewSize = [self.navigationPageControl sizeForNumberOfPages:[self.navigationItemsViews count]];
    CGFloat originX = (distance - viewSize.width/2);
    [self.navigationPageControl setFrame:(CGRect){originX, labelHeighSpace, viewSize.width, viewSize.height}];
}

-(void)setAlphaWithOffset:(UIAccelerationValue)xOffset
{
    CGFloat distance = [self getDistanceValue];
    [self.navigationItemsViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int index = (int)idx;
        CGFloat alpha = xOffset < distance * index ? (xOffset - distance * (index - 1)) / distance : 1 - ((xOffset - distance * index) / distance);
        [obj setAlpha:alpha];
    }];
}

-(UILabel *)createNewLabelWithText:(NSString *)text
{
    UILabel *navTitleLabel = [UILabel new];
    navTitleLabel.text = text;
    navTitleLabel.font = self.landscapeTitleFont;
    navTitleLabel.textColor = [UIColor whiteColor];
    navTitleLabel.alpha = 0;
    return navTitleLabel;
}

-(CGSize)getLabelSize:(UILabel *)label
{
    return [[label text] sizeWithAttributes:@{NSFontAttributeName:[label font]}];;
}

-(CGFloat)getDistanceValue
{
    CGPoint middle = [self.navigationController.navigationBar convertPoint:self.navigationController.navigationBar.center toView:self.navigationView];
    return middle.x ;
}


-(UIFont *)landscapeTitleFont
{
    if (_landscapeTitleFont) return _landscapeTitleFont;
    _landscapeTitleFont = [UIFont systemFontOfSize:14];
    return _landscapeTitleFont;
}

-(UIFont *)portraitTitleFont
{
    if (_portraitTitleFont) return _portraitTitleFont;
    _portraitTitleFont = [UIFont systemFontOfSize:18];
    return _portraitTitleFont;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setNavigationViewItemsPosition:NO];
}

@end
