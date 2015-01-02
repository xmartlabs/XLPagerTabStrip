//
//  NavigationExampleViewController.m
//  XLPagerTabStrip
//
//  Created by Martin Barreto on 12/20/14.
//  Copyright (c) 2014 Xmartlabs. All rights reserved.
//
#import "XLPagerTabStripViewController.h"
#import "ReloadExampleViewController.h"

@interface ReloadExampleViewController ()

@end

@implementation ReloadExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)reloadTapped:(id)sender {
    [[self childViewControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[XLPagerTabStripViewController class]]){
            XLPagerTabStripViewController * pagerController = (id)obj;
            [pagerController reloadPagerTabStripView];
            *stop = YES;
        }
    }];
}

@end
