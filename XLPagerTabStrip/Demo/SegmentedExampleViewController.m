//
//  SegmentedContainerViewController.m
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2014 Xmartlabs ( http://xmartlabs.com )
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

#import "ChildExampleViewController.h"
#import "TableChildExampleViewController.h"
#import "SegmentedExampleViewController.h"

@implementation SegmentedExampleViewController
{
    BOOL _isReload;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.skipIntermediateViewControllers = NO;
        _isReload = NO;
    }
    return self;
}

#pragma mark - XLPagerTabStripViewControllerDataSource

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    // create child view controllers that will be managed by XLPagerTabStripViewController
    TableChildExampleViewController * child_1 = [[TableChildExampleViewController alloc] initWithStyle:UITableViewStylePlain];
    ChildExampleViewController * child_2 = [[ChildExampleViewController alloc] init];
    TableChildExampleViewController * child_3 = [[TableChildExampleViewController alloc] initWithStyle:UITableViewStyleGrouped];
    ChildExampleViewController * child_4 = [[ChildExampleViewController alloc] init];
    if (!_isReload){
        return @[child_1, child_2, child_3, child_4];
    }
    
    NSMutableArray * childViewControllers = [NSMutableArray arrayWithObjects:child_1, child_2, child_3, child_4, nil];
    NSUInteger count = [childViewControllers count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [childViewControllers exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    NSUInteger nItems = 1 + (rand() % 4);
    return [childViewControllers subarrayWithRange:NSMakeRange(0, nItems)];
}

- (IBAction)reloadTapped:(id)sender {
    _isReload = YES;
    [self reloadPagerTabStripView];
}

@end
