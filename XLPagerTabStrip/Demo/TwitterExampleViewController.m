//
//  TwitterExampleViewController.m
//  XLPagerTabStrip
//
//  Created by Archibald on 4/7/15.
//  Copyright (c) 2015 Xmartlabs. All rights reserved.
//

#import "TableChildExampleViewController.h"
#import "ChildExampleViewController.h"
#import "TwitterExampleViewController.h"

@implementation TwitterExampleViewController
{
    BOOL _isReload;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isReload = NO;
    self.isProgressiveIndicator = YES;
    self.isElasticIndicatorLimit = YES;
    // Do any additional setup after loading the view.
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

- (IBAction)reloadTapped:(id)sender {
    _isReload = YES;
    self.isElasticIndicatorLimit = (rand() % 2 == 0);
    [self reloadPagerTabStripView];
}

@end
