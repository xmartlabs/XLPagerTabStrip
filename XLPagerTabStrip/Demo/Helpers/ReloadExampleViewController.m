//
//  NavigationExampleViewController.m
//  XLPagerTabStrip
//
//  Created by Martin Barreto on 12/20/14.
//  Copyright (c) 2015 Xmartlabs. All rights reserved.
//
#import "XLPagerTabStripViewController.h"
#import "ReloadExampleViewController.h"

@interface ReloadExampleViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ReloadExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.navigationController){
        UILabel *bigLabel = [[UILabel alloc] init];
        bigLabel.backgroundColor = [UIColor clearColor];
        bigLabel.textColor = [UIColor whiteColor];
        bigLabel.font = [UIFont boldSystemFontOfSize:20];
        bigLabel.adjustsFontSizeToFitWidth = YES;
        self.navigationItem.titleView = bigLabel;
        [bigLabel sizeToFit];
    }
    [[self childViewControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[XLPagerTabStripViewController class]]){
            XLPagerTabStripViewController * pagerController = (id)obj;
            [self updateTitle:pagerController];
            *stop = YES;
        }
    }];

    
}

- (IBAction)reloadTapped:(id)sender {
    [[self childViewControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[XLPagerTabStripViewController class]]){
            XLPagerTabStripViewController * pagerController = (id)obj;
            [pagerController reloadPagerTabStripView];
            [self updateTitle:pagerController];
            *stop = YES;
        }
    }];
}

-(void)updateTitle:(XLPagerTabStripViewController *)pagerController
{
    NSString * title = [NSString stringWithFormat:@"Progressive = %@  ElasticLimit = %@",[self stringFromBool:pagerController.isProgressiveIndicator] ,[self stringFromBool:pagerController.isElasticIndicatorLimit]];
    self.titleLabel.text = title;
    ((UILabel *)self.navigationItem.titleView).text = title;
    [((UILabel *)self.navigationItem.titleView) sizeToFit];
}

-(NSString *)stringFromBool:(BOOL)value
{
    return value ? @"YES" : @"NO";
}

@end
