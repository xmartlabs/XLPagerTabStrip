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
{
    BOOL _isReload;
}
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
    
    self.isProgressiveIndicator = YES;
    
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

-(void)reloadNavigatorContainerView
{
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
    return navTitleLabel;
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


#pragma mark - XLPagerTabStripViewControllerDataSource

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    // create child view controllers that will be managed by XLPagerTabStripViewController
    TableChildExampleViewController * child_1 = [[TableChildExampleViewController alloc] initWithStyle:UITableViewStylePlain];
    ChildExampleViewController * child_2 = [[ChildExampleViewController alloc] init];
    TableChildExampleViewController * child_3 = [[TableChildExampleViewController alloc] initWithStyle:UITableViewStyleGrouped];
    ChildExampleViewController * child_4 = [[ChildExampleViewController alloc] init];
    TableChildExampleViewController * child_5 = [[TableChildExampleViewController alloc] initWithStyle:UITableViewStylePlain];
    ChildExampleViewController * child_6 = [[ChildExampleViewController alloc] init];
    TableChildExampleViewController * child_7 = [[TableChildExampleViewController alloc] initWithStyle:UITableViewStyleGrouped];
    ChildExampleViewController * child_8 = [[ChildExampleViewController alloc] init];
    if (!_isReload){
        return @[child_1, child_2, child_3, child_4, child_5, child_6, child_7, child_8];
    }
    
    NSMutableArray * childViewControllers = [NSMutableArray arrayWithObjects:child_1, child_2, child_3, child_4, child_5, child_6, child_7, child_8, nil];
    NSUInteger count = [childViewControllers count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [childViewControllers exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    NSUInteger nItems = 1 + (rand() % 8);
    return [childViewControllers subarrayWithRange:NSMakeRange(0, nItems)];
}

-(void)reloadPagerTabStripView
{
    _isReload = YES;
    self.isProgressiveIndicator = (rand() % 2 == 0);
    self.isElasticIndicatorLimit = (rand() % 2 == 0);
    [super reloadPagerTabStripView];
}


@end
