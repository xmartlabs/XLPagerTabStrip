//
//  XLTwitterPagerTabStripViewController.m
//  XLPagerTabStrip
//
//  Created by Martin Pastorin on 2/12/15.
//  Copyright (c) 2015 Xmartlabs. All rights reserved.
//

#import "XLTwitterPagerTabStripViewController.h"
#import "TableChildExampleViewController.h"
#import "ChildExampleViewController.h"
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
    if (!self.navigationScrollView.superview) {
        [self.navigationView addSubview:self.navigationScrollView];
    }
    
    if (!self.navigationPageControl.superview) {
        [self.navigationView addSubview:self.navigationPageControl];
    }
    
    [self reloadNavigationViewItems];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.navigationController.navigationBar.frame) , CGRectGetHeight(self.navigationController.navigationBar.frame))];
    [self.navigationView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:0];
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
    [super setIsProgressiveIndicator:YES];
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
{
    CGFloat distance = [self getDistanceValue];
    UIAccelerationValue xOffset = fromIndex < toIndex ? distance * fromIndex + distance * progressPercentage : distance * fromIndex - distance * progressPercentage;
    [self.navigationScrollView setContentOffset:CGPointMake(xOffset, 0)];
    [self setAlphaWithOffset:xOffset];
    [_navigationPageControl setCurrentPage:self.currentIndex];
}


#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ((object == self.navigationItem.titleView && [keyPath isEqualToString:@"frame"])){
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
    [self.navigationView removeObserver:self forKeyPath:@"frame"];
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
        if ([childViewController respondsToSelector:@selector(titleForPagerTabStripViewController:)]){
            UILabel *navTitleLabel = [self createNewLabelWithText:[childViewController titleForPagerTabStripViewController:self]];
            [navTitleLabel setAlpha: self.currentIndex == idx ? 1 : 0];
            [_navigationScrollView addSubview:navTitleLabel];
            [_navigationItemsViews addObject:navTitleLabel];
        }
    }];
}

-(void)setNavigationViewItemsPosition
{
    CGFloat distance = [self getDistanceValue];
    
    [self.navigationItemsViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int index = (int)idx;
        UIView *view = (UIView *)obj;
        [view setAlpha: self.currentIndex == idx ? 1 : 0];
        CGSize viewSize = [view isKindOfClass:[UILabel class]] ? [self getLabelSize:(UILabel*)view] : view.frame.size;
        CGFloat originX = (distance - viewSize.width/2) + index * distance;
        view.frame = (CGRect){originX, 8, viewSize.width, viewSize.height};
        view.tag = index;
    }];
    
    UIAccelerationValue xOffset = distance * self.currentIndex;
    [self.navigationScrollView setContentOffset:CGPointMake(xOffset, 0)];
    
    // Update Navigation Page Control
    [self.navigationPageControl setNumberOfPages:[self.navigationItemsViews count]];
    [self.navigationPageControl setCurrentPage:self.currentIndex];
    CGSize viewSize = [self.navigationPageControl sizeForNumberOfPages:[self.navigationItemsViews count]];
    CGFloat originX = (distance - viewSize.width/2);
    [self.navigationPageControl setFrame:(CGRect){originX, 34, viewSize.width, viewSize.height}];
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
    navTitleLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
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



@end
