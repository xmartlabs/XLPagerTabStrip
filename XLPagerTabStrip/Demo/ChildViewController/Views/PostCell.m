//
//  PostCell.m
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

#import "PostCell.h"
    
@implementation PostCell

@synthesize userImage = _userImage;
@synthesize userName  = _userName;
@synthesize postText  = _postText;
@synthesize postDate  = _postDate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self.contentView addSubview:self.userImage];
        [self.contentView addSubview:self.userName];
        [self.contentView addSubview:self.postText];
        [self.contentView addSubview:self.postDate];
        
        [self.contentView addConstraints:[self layoutConstraints]];
    }
    return self;
}

#pragma mark - Views

-(UIImageView *)userImage
{
    if (_userImage) return _userImage;
    _userImage = [UIImageView new];
    [_userImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    _userImage.layer.masksToBounds = YES;
    _userImage.layer.cornerRadius = 10.0f;
    return _userImage;
}

-(UILabel *)userName
{
    if (_userName) return _userName;
    _userName = [UILabel new];
    [_userName setTranslatesAutoresizingMaskIntoConstraints:NO];
    _userName.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    [_userName setContentCompressionResistancePriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    
    return _userName;
}

-(PostTextLabel *)postText
{
    if (_postText) return _postText;
    _postText = [PostTextLabel new];
    [_postText setTranslatesAutoresizingMaskIntoConstraints:NO];
    _postText.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    
    _postText.lineBreakMode = NSLineBreakByWordWrapping;
    _postText.numberOfLines = 0;

    return _postText;
}

-(UILabel *)postDate
{
    if (_postDate) return _postDate;
    _postDate = [UILabel new];
    [_postDate setTranslatesAutoresizingMaskIntoConstraints:NO];
    _postDate.textColor = [UIColor grayColor];
    _postDate.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    [_postDate setTextAlignment:NSTextAlignmentRight];
    return _postDate;
}


#pragma mark - Layout Constraints

-(NSArray *)layoutConstraints{
    
    NSMutableArray * result = [NSMutableArray array];
    
    NSDictionary * views = @{ @"image": self.userImage,
                              @"name": self.userName,
                              @"text": self.postText,
                              @"date" : self.postDate };
    
    NSDictionary *metrics = @{@"imgSize":@50.0,
                              @"margin" :@12.0};
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[image(imgSize)]-[name]"
                                                                        options:NSLayoutFormatAlignAllTop
                                                                        metrics:metrics
                                                                          views:views]];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[name]-[date]-20-|"
                                                                        options:NSLayoutFormatAlignAllBaseline
                                                                        metrics:metrics
                                                                          views:views]];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(margin)-[image(imgSize)]"
                                                                        options:0
                                                                        metrics:metrics
                                                                          views:views]];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[name]-[text]-20-|"
                                                                        options:NSLayoutFormatAlignAllLeft
                                                                        metrics:metrics
                                                                          views:views]];
    
    [result addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[text]-20-|"
                                                                        options:NSLayoutFormatAlignAllBaseline
                                                                        metrics:metrics
                                                                          views:views]];
    return result;
}

@end


@implementation PostTextLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.preferredMaxLayoutWidth = self.bounds.size.width;
}

@end
