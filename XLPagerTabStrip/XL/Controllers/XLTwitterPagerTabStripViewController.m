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

@property (nonatomic) IBOutlet UIView * navigationView;
@property (nonatomic) UIScrollView * navigationScrollView;
@property (nonatomic) FXPageControl * navigationPageControl;
@property (nonatomic, strong) NSMutableArray * navigationItemsViews;

@end


@implementation XLTwitterPagerTabStripViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.navigationView.superview) {
        [self.navigationController.navigationBar addSubview:self.navigationView];
    }
    if (!self.navigationScrollView.superview) {
        [self.navigationView addSubview:self.navigationScrollView];
    }
    
    if (!self.navigationPageControl.superview) {
        [self.navigationView addSubview:self.navigationPageControl];
    }
    
    _navigationScrollView.bounces = YES;
    _navigationScrollView.scrollsToTop = NO;
    _navigationScrollView.delegate = self;
    _navigationScrollView.showsVerticalScrollIndicator = NO;
    _navigationScrollView.showsHorizontalScrollIndicator = NO;
    _navigationScrollView.pagingEnabled = YES;
    _navigationScrollView.userInteractionEnabled = NO;
    [_navigationScrollView setAlwaysBounceHorizontal:YES];
    [_navigationScrollView setAlwaysBounceVertical:NO];
    
    [self reloadNavigatorContainerView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setCurrentNavigationScrollViewOffset];
}

-(void)reloadPagerTabStripView
{
    [super reloadPagerTabStripView];
    if ([self isViewLoaded])
    {
        [self reloadNavigatorContainerView];
        [self setCurrentNavigationScrollViewOffset];
    }
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
            withProgressPercentage:(CGFloat)progressPercentage
{
    CGFloat distance = CGRectGetWidth(self.navigationScrollView.frame) / 2;
    UIAccelerationValue xOffset = fromIndex < toIndex ? distance * fromIndex + distance * progressPercentage : distance * fromIndex - distance * progressPercentage;
    [self.navigationScrollView setContentOffset:CGPointMake(xOffset, 0)];
    [self setAlphaToItemAtIndex:fromIndex withOffset:xOffset];
    [self setAlphaToItemAtIndex:toIndex withOffset:xOffset];
    
    [_navigationPageControl setCurrentPage:self.currentIndex];
}


#pragma mark - Helpers

-(void)reloadNavigatorContainerView
{
    [self.navigationItemsViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.navigationItemsViews removeAllObjects];
    
    __block NSMutableArray *items = [[NSMutableArray alloc] init];
    [self.pagerTabStripChildViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSAssert([obj conformsToProtocol:@protocol(XLPagerTabStripChildItem)], @"child view controller must conform to XLPagerTabStripChildItem");
        UIViewController<XLPagerTabStripChildItem> * childViewController = (UIViewController<XLPagerTabStripChildItem> *)obj;
        if ([childViewController respondsToSelector:@selector(titleForPagerTabStripViewController:)]){
            UILabel *navTitleLabel = [self createNewLabelWithText:[childViewController titleForPagerTabStripViewController:self]];
            [navTitleLabel setAlpha: self.currentIndex == idx ? 1 : 0];
            [items addObject:navTitleLabel];
        }
    }];
    
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:UIView.class])
            [self addNavigationViewItem:obj index:idx];
    }];
    
    // Update Navigation Page Control
    [self.navigationPageControl setNumberOfPages:[self.navigationItemsViews count]];
    [self.navigationPageControl setCurrentPage:self.currentIndex];
    CGSize viewSize = [self.navigationPageControl sizeForNumberOfPages:[self.navigationItemsViews count]];
    CGFloat distance = CGRectGetWidth(self.navigationScrollView.frame) / 2;
    CGFloat originX = (distance - viewSize.width/2);
    [self.navigationPageControl setFrame:(CGRect){originX, 34, viewSize.width, viewSize.height}];
}

- (void)addNavigationViewItem:(UIView*)view index:(NSInteger)index
{
    CGFloat distance = CGRectGetWidth(self.navigationScrollView.frame) / 2;
    CGSize viewSize = [view isKindOfClass:[UILabel class]] ? [self getLabelSize:(UILabel*)view] : view.frame.size;
    CGFloat originX = (distance - viewSize.width/2) + self.navigationItemsViews.count * distance;
    view.frame = (CGRect){originX, 8, viewSize.width, viewSize.height};
    view.tag = index;
    
    [_navigationScrollView addSubview:view];
    [_navigationItemsViews addObject:view];
}

-(void)setAlphaToItemAtIndex:(NSInteger)index withOffset:(UIAccelerationValue)xOffset
{
    if (index<0 || index>=[self.navigationItemsViews count]) {
        return;
    }
    
    CGFloat distance = CGRectGetWidth(self.navigationScrollView.frame) / 2;
    CGFloat alpha;
    
    if(xOffset < distance * index) {
        alpha = (xOffset - distance * (index - 1)) / distance;
    }else{
        alpha = 1 - ((xOffset - distance * index) / distance);
    }
    
    UILabel *label = (UILabel*)[self.navigationItemsViews objectAtIndex:index];
    [label setAlpha:alpha];
}

-(CGSize) getLabelSize:(UILabel *)label
{
    return [[label text] sizeWithAttributes:@{NSFontAttributeName:[label font]}];;
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

-(void)setCurrentNavigationScrollViewOffset
{
    CGFloat distance = CGRectGetWidth(self.navigationScrollView.frame) / 2;
    UIAccelerationValue xOffset = distance * self.currentIndex;
    [self.navigationScrollView setContentOffset:CGPointMake(xOffset, 0)];
}

@end
