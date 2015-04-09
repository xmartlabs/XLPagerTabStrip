//
//  TableChildExampleViewController.m
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

#import "XLJSONSerialization.h"
#import "PostCell.h"
#import "TableChildExampleViewController.h"

NSString *const kCellIdentifier = @"PostCell";

@implementation TableChildExampleViewController
{
    NSArray * _posts;
    PostCell * _offScreenCell;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _posts = [[XLJSONSerialization sharedInstance] postsData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[PostCell class] forCellReuseIdentifier:kCellIdentifier];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PostCell *cell = (PostCell *) [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    cell.userName.text = [_posts objectAtIndex:indexPath.row][@"post"][@"user"][@"name"];
    cell.postDate.text = [self timeAgo:[self dateFromString:[_posts objectAtIndex:indexPath.row][@"post"][@"created_at"]]];
    cell.postText.text = [_posts objectAtIndex:indexPath.row][@"post"][@"text"];
    [cell.postText setPreferredMaxLayoutWidth:self.view.bounds.size.width];
    [cell.userImage setImage:[UIImage imageNamed:[cell.userName.text stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_offScreenCell)
    {
        _offScreenCell = (PostCell *)[self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        // Dummy Data
        _offScreenCell.userName.text = @"offscreen name";
        _offScreenCell.postDate.text = @"7m";
        [_offScreenCell.userImage setImage:[UIImage imageNamed:@"default-avatar"]];
    }
    _offScreenCell.postText.text = [_posts objectAtIndex:indexPath.row][@"post"][@"text"];
    [_offScreenCell.postText setPreferredMaxLayoutWidth:self.view.bounds.size.width];
    [_offScreenCell.contentView setNeedsLayout];
    [_offScreenCell.contentView layoutIfNeeded];
    CGSize size = [_offScreenCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return @"Table View";
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor whiteColor];
}


#pragma mark - Helpers

#define SECONDS_IN_A_MINUTE 60
#define SECONDS_IN_A_HOUR  3600
#define SECONDS_IN_A_DAY 86400
#define SECONDS_IN_A_MONTH_OF_30_DAYS 2592000
#define SECONDS_IN_A_YEAR_OF_MONTH_OF_30_DAYS 31104000

- (NSString *)timeAgo:(NSDate *)date {
    NSTimeInterval distanceBetweenDates = [date timeIntervalSinceDate:[NSDate date]] * (-1);
    int distance = (int)floorf(distanceBetweenDates);
    if (distance <= 0) {
        return @"now";
    }
    else if (distance < SECONDS_IN_A_MINUTE) {
        return   [NSString stringWithFormat:@"%ds", distance];
    }
    else if (distance < SECONDS_IN_A_HOUR) {
        distance = distance / SECONDS_IN_A_MINUTE;
        return   [NSString stringWithFormat:@"%dm", distance];
    }
    else if (distance < SECONDS_IN_A_DAY) {
        distance = distance / SECONDS_IN_A_HOUR;
        return   [NSString stringWithFormat:@"%dh", distance];
    }
    else if (distance < SECONDS_IN_A_MONTH_OF_30_DAYS) {
        distance = distance / SECONDS_IN_A_DAY;
        return   [NSString stringWithFormat:@"%dd", distance];
    }
    else if (distance < SECONDS_IN_A_YEAR_OF_MONTH_OF_30_DAYS) {
        distance = distance / SECONDS_IN_A_MONTH_OF_30_DAYS;
        return   [NSString stringWithFormat:@"%dmo", distance];
    } else {
        distance = distance / SECONDS_IN_A_YEAR_OF_MONTH_OF_30_DAYS;
        return   [NSString stringWithFormat:@"%dy", distance];
    }
}

-(NSDate *)dateFromString:(NSString *)dateString
{
    // date formatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    // hot fix from date
    NSRange range = [dateString rangeOfString:@"."];
    if (range.location != NSNotFound){
        dateString = [dateString substringToIndex:range.location];
    }
    return [formatter dateFromString:dateString];
}


@end
