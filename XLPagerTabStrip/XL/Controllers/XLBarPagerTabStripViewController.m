//
//  XLBarPagerTabStripViewController.m
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

#import "XLBarPagerTabStripViewController.h"

@implementation XLBarPagerTabStripViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.barView.superview){
        [self.view addSubview:self.barView];
    }
    else{
        [self.barView setOptionsAmount:self.pagerTabStripChildViewControllers.count animated:NO];
        [self.barView moveToIndex:self.currentIndex animated:NO];
    }
}


-(void)reloadPagerTabStripView
{
    [super reloadPagerTabStripView];
    if ([self isViewLoaded])
    {
        [self.barView setOptionsAmount:self.pagerTabStripChildViewControllers.count animated:NO];
        [self.barView moveToIndex:self.currentIndex animated:NO];
    }
}


#pragma mark - Properties

-(XLBarView *)barView
{
    if (_barView) return _barView;
    _barView = [[XLBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5.0f) optionsAmount:self.pagerTabStripChildViewControllers.count selectedOptionIndex:self.currentIndex];
    _barView.backgroundColor = [UIColor orangeColor];
    _barView.selectedBar.backgroundColor = [UIColor blackColor];
    _barView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    return _barView;
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
          updateIndicatorFromIndex:(NSInteger)fromIndex
                           toIndex:(NSInteger)toIndex
{
    [self.barView moveToIndex:toIndex
                     animated:YES];
}

-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
          updateIndicatorFromIndex:(NSInteger)fromIndex
                           toIndex:(NSInteger)toIndex
            withProgressPercentage:(CGFloat)progressPercentage
                   indexWasChanged:(BOOL)indexWasChanged
{
    [self.barView moveFromIndex:fromIndex
                        toIndex:toIndex
         withProgressPercentage:progressPercentage];
}



@end
