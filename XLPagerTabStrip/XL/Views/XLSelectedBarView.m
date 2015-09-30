//
//  XLSelectedBarView.m
//  XLPagerTabStrip
//
//  Created by Anthony Miller on 9/30/15.
//  Copyright © 2015 Xmartlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XLSelectedBarView.h"

@implementation XLSelectedBarView

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    [self initializeImageView];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self initializeImageView];
  }
  return self;
}

-(void)initializeImageView
{
  self.imageView = [[UIImageView alloc] initWithImage:nil];
  self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
  self.imageView.contentMode = UIViewContentModeScaleAspectFit;
  
  [self addSubview:self.imageView];
  [self bringSubviewToFront:self.imageView];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageView
                                                   attribute:NSLayoutAttributeCenterX
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self attribute:NSLayoutAttributeCenterX
                                                  multiplier:1.0
                                                    constant:0]];
  NSDictionary *viewDictionary = @{@"barImageView": self.imageView};
  [self addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:@"V:|-0-[barImageView]-0-|"
                        options:NSLayoutFormatDirectionLeadingToTrailing
                        metrics:nil
                        views:viewDictionary]];
}

@end
