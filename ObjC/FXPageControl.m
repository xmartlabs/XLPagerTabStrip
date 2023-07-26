//
//  FXPageControl.m
//
//  Version 1.6
//
//  Created by Nick Lockwood on 07/01/2010.
//  Copyright 2010 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version of FXPageControl from here:
//
//  https://github.com/nicklockwood/FXPageControl
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "FXPageControl.h"


#pragma clang diagnostic ignored "-Wgnu"
#pragma clang diagnostic ignored "-Wfloat-equal"
#pragma clang diagnostic ignored "-Wfloat-conversion"
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
#pragma clang diagnostic ignored "-Wdirect-ivar-access"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


const CGPathRef FXPageControlDotShapeCircle = (const CGPathRef)1;
const CGPathRef FXPageControlDotShapeSquare = (const CGPathRef)2;
const CGPathRef FXPageControlDotShapeTriangle = (const CGPathRef)3;
#define LAST_SHAPE FXPageControlDotShapeTriangle


@implementation FXPageControl

- (void)setUp
{
    //needs redrawing if bounds change
    self.contentMode = UIViewContentModeRedraw;

    //set defaults
    _dotSpacing = 10.0;
    _dotSize = 6.0;
    _dotShadowOffset = CGSizeMake(0, 1);
    _selectedDotShadowOffset = CGSizeMake(0, 1);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)dealloc
{
    if (_dotShape > LAST_SHAPE) CGPathRelease(_dotShape);
    if (_selectedDotShape > LAST_SHAPE) CGPathRelease(_selectedDotShape);
}

- (CGSize)sizeForNumberOfPages:(__unused NSInteger)pageCount
{
    CGFloat width = _dotSize + (_dotSize + _dotSpacing) * (_numberOfPages - 1);
    return _vertical? CGSizeMake(_dotSize, width): CGSizeMake(width, _dotSize);
}

- (void)updateCurrentPageDisplay
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (_numberOfPages > 1 || !_hidesForSinglePage)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, rect);
        CGSize size = [self sizeForNumberOfPages:_numberOfPages];
        if (_vertical)
        {
            CGContextTranslateCTM(context, self.frame.size.width / 2, (self.frame.size.height - size.height) / 2);
        }
        else
        {
            CGContextTranslateCTM(context, (self.frame.size.width - size.width) / 2, self.frame.size.height / 2);
        }

        for (int i = 0; i < _numberOfPages; i++)
        {
            UIImage *dotImage = nil;
            UIColor *dotColor = nil;
            CGPathRef dotShape = NULL;
            CGFloat dotSize = 0;
            UIColor *dotShadowColor = nil;
            CGSize dotShadowOffset = CGSizeZero;
            CGFloat dotShadowBlur = 0;
            CGFloat dotBorderWidth = 0;
            UIColor *dotBorderColor = nil;

            if (i == _currentPage)
            {
                if ([_delegate respondsToSelector:@selector(pageControl:selectedImageForDotAtIndex:)])
                {
                    dotImage = [_delegate pageControl:self selectedImageForDotAtIndex:i];
                }
                else
                {
                    dotImage = _selectedDotImage;
                }
                if ([_delegate respondsToSelector:@selector(pageControl:selectedShapeForDotAtIndex:)])
                {
                    dotShape = [_delegate pageControl:self selectedShapeForDotAtIndex:i];
                }
                else
                {
                    dotShape = _selectedDotShape ?: _dotShape;
                }
                if ([_delegate respondsToSelector:@selector(pageControl:selectedColorForDotAtIndex:)])
                {
                    dotColor = [_delegate pageControl:self selectedColorForDotAtIndex:i];
                }
                else
                {
                    dotColor = _selectedDotColor ?: [UIColor blackColor];
                }
                dotShadowBlur = _selectedDotShadowBlur;
                dotShadowColor = _selectedDotShadowColor;
                dotShadowOffset = _selectedDotShadowOffset;
                dotBorderWidth = _selectedDotBorderWidth;
                dotBorderColor = _selectedDotBorderColor;
                dotSize = _selectedDotSize ?: _dotSize;
            }
            else
            {
                if ([_delegate respondsToSelector:@selector(pageControl:imageForDotAtIndex:)])
                {
                    dotImage = [_delegate pageControl:self imageForDotAtIndex:i];
                }
                else
                {
                    dotImage = _dotImage;
                }
                if ([_delegate respondsToSelector:@selector(pageControl:shapeForDotAtIndex:)])
                {
                    dotShape = [_delegate pageControl:self shapeForDotAtIndex:i];
                }
                else
                {
                    dotShape = _dotShape;
                }
                if ([_delegate respondsToSelector:@selector(pageControl:colorForDotAtIndex:)])
                {
                    dotColor = [_delegate pageControl:self colorForDotAtIndex:i];
                }
                else
                {
                    dotColor = _dotColor;
                }
                if (!dotColor)
                {
                    //fall back to selected dot color with reduced alpha
                    if ([_delegate respondsToSelector:@selector(pageControl:selectedColorForDotAtIndex:)])
                    {
                        dotColor = [_delegate pageControl:self selectedColorForDotAtIndex:i];
                    }
                    else
                    {
                        dotColor = _selectedDotColor ?: [UIColor blackColor];
                    }
                    dotColor = [dotColor colorWithAlphaComponent:0.25];
                }
                dotShadowBlur = _dotShadowBlur;
                dotShadowColor = _dotShadowColor;
                dotShadowOffset = _dotShadowOffset;
                dotBorderWidth = _dotBorderWidth;
                dotBorderColor = _dotBorderColor;
                dotSize = _dotSize;
            }

            [dotColor setFill];

            CGContextSaveGState(context);
            CGFloat offset = (_dotSize + _dotSpacing) * i + _dotSize / 2;
            CGContextTranslateCTM(context, _vertical? 0: offset, _vertical? offset: 0);

            if (dotShadowColor && ![dotShadowColor isEqual:[UIColor clearColor]])
            {
                CGContextSetShadowWithColor(context, dotShadowOffset, dotShadowBlur, dotShadowColor.CGColor);
            }
            if (dotImage)
            {
                [dotImage drawInRect:CGRectMake(-dotImage.size.width / 2, -dotImage.size.height / 2, dotImage.size.width, dotImage.size.height)];
            }
            else
            {
                [dotBorderColor setStroke];
                CGContextSetLineWidth(context, dotBorderWidth);
                if (!dotShape || dotShape == FXPageControlDotShapeCircle)
                {
                    CGContextAddEllipseInRect(context, CGRectMake(-dotSize / 2, -dotSize / 2, dotSize, dotSize));
                }
                else if (dotShape == FXPageControlDotShapeSquare)
                {
                    CGContextAddRect(context, CGRectMake(-dotSize / 2, -dotSize / 2, dotSize, dotSize));
                }
                else if (dotShape == FXPageControlDotShapeTriangle)
                {
                    CGContextMoveToPoint(context, 0, -dotSize / 2);
                    CGContextAddLineToPoint(context, dotSize / 2, dotSize / 2);
                    CGContextAddLineToPoint(context, -dotSize / 2, dotSize / 2);
                    CGContextAddLineToPoint(context, 0, -dotSize / 2);
                }
                else
                {
                    CGContextAddPath(context, dotShape);
                }

                if (dotBorderWidth == 0)
                CGContextDrawPath(context, kCGPathFill);
                else
                CGContextDrawPath(context, kCGPathFillStroke);
            }
            CGContextRestoreGState(context);
        }
    }
}

- (NSInteger)clampedPageValue:(NSInteger)page
{
    if (_wrapEnabled)
    {
        return _numberOfPages? (page + _numberOfPages) % _numberOfPages: 0;
    }
    else
    {
        return MIN(MAX(0, page), _numberOfPages - 1);
    }
}

- (void)setDotImage:(UIImage *)dotImage
{
    if (_dotImage != dotImage)
    {
        _dotImage = dotImage;
        [self setNeedsDisplay];
    }
}

- (void)setDotShape:(CGPathRef)dotShape
{
    if (_dotShape != dotShape)
    {
        if (_dotShape > LAST_SHAPE) CGPathRelease(_dotShape);
        _dotShape = dotShape;
        if (_dotShape > LAST_SHAPE) CGPathRetain(_dotShape);
        [self setNeedsDisplay];
    }
}

- (void)setDotSize:(CGFloat)dotSize
{
    if (ABS(_dotSize - dotSize) > 0.001)
    {
        _dotSize = dotSize;
        [self setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setDotColor:(UIColor *)dotColor
{
    if (_dotColor != dotColor)
    {
        _dotColor = dotColor;
        [self setNeedsDisplay];
    }
}

- (void)setDotShadowColor:(UIColor *)dotColor
{
    if (_dotShadowColor != dotColor)
    {
        _dotShadowColor = dotColor;
        [self setNeedsDisplay];
    }
}

- (void)setDotShadowBlur:(CGFloat)dotShadowBlur
{
    if (ABS(_dotShadowBlur - dotShadowBlur) > 0.001)
    {
        _dotShadowBlur = dotShadowBlur;
        [self setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setDotShadowOffset:(CGSize)dotShadowOffset
{
    if (!CGSizeEqualToSize(_dotShadowOffset, dotShadowOffset))
    {
        _dotShadowOffset = dotShadowOffset;
        [self setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setDotBorderWidth:(CGFloat)dotBorderWidth
{
    if (ABS(_dotBorderWidth - dotBorderWidth) > 0.001)
    {
        _dotBorderWidth = dotBorderWidth;
        [self setNeedsDisplay];
    }
}

- (void)setDotBorderColor:(UIColor *)dotBorderColor
{
    if (_dotBorderColor != dotBorderColor)
    {
        _dotBorderColor = dotBorderColor;
        [self setNeedsDisplay];
    }
}

- (void)setSelectedDotImage:(UIImage *)dotImage
{
    if (_selectedDotImage != dotImage)
    {
        _selectedDotImage = dotImage;
        [self setNeedsDisplay];
    }
}

- (void)setSelectedDotColor:(UIColor *)dotColor
{
    if (_selectedDotColor != dotColor)
    {
        _selectedDotColor = dotColor;
        [self setNeedsDisplay];
    }
}

- (void)setSelectedDotShape:(CGPathRef)dotShape
{
    if (_selectedDotShape != dotShape)
    {
        if (_selectedDotShape > LAST_SHAPE) CGPathRelease(_selectedDotShape);
        _selectedDotShape = dotShape;
        if (_selectedDotShape > LAST_SHAPE) CGPathRetain(_selectedDotShape);
        [self setNeedsDisplay];
    }
}

- (void)setSelectedDotSize:(CGFloat)dotSize
{
    if (ABS(_selectedDotSize - dotSize) > 0.001)
    {
        _selectedDotSize = dotSize;
        [self setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setSelectedDotShadowColor:(UIColor *)dotColor
{
    if (_selectedDotShadowColor != dotColor)
    {
        _selectedDotShadowColor = dotColor;
        [self setNeedsDisplay];
    }
}

- (void)setSelectedDotShadowBlur:(CGFloat)dotShadowBlur
{
    if (ABS(_selectedDotShadowBlur - dotShadowBlur) > 0.001)
    {
        _selectedDotShadowBlur = dotShadowBlur;
        [self setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setSelectedDotShadowOffset:(CGSize)dotShadowOffset
{
    if (!CGSizeEqualToSize(_selectedDotShadowOffset, dotShadowOffset))
    {
        _selectedDotShadowOffset = dotShadowOffset;
        [self setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setSelectedDotBorderWidth:(CGFloat)selectedDotBorderWidth
{
    if (ABS(_selectedDotBorderWidth - selectedDotBorderWidth) > 0.001)
    {
        _selectedDotBorderWidth = selectedDotBorderWidth;
        [self setNeedsDisplay];
    }
}

- (void)setSelectedDotBorderColor:(UIColor *)dotColor
{
    if (_selectedDotBorderColor != dotColor)
    {
        _selectedDotBorderColor = dotColor;
        [self setNeedsDisplay];
    }
}

- (void)setDotSpacing:(CGFloat)dotSpacing
{
    if (ABS(_dotSpacing - dotSpacing) > 0.001)
    {
        _dotSpacing = dotSpacing;
        [self setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)setDelegate:(id<FXPageControlDelegate>)delegate
{
    if (_delegate != delegate)
    {
        _delegate = delegate;
        [self setNeedsDisplay];
    }
}

- (void)setCurrentPage:(NSInteger)page
{
    _currentPage = [self clampedPageValue:page];
    [self setNeedsDisplay];
}

- (void)setNumberOfPages:(NSInteger)pages
{
    if (_numberOfPages != pages)
    {
        _numberOfPages = pages;
        if (_currentPage >= pages)
        {
            _currentPage = pages - 1;
        }
        [self setNeedsDisplay];
        [self invalidateIntrinsicContentSize];
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:self];
    BOOL forward = _vertical? (point.y > self.frame.size.height / 2): (point.x > self.frame.size.width / 2);
    _currentPage = [self clampedPageValue:_currentPage + (forward? 1: -1)];
    if (!_defersCurrentPageDisplay)
    {
        [self setNeedsDisplay];
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [super endTrackingWithTouch:touch withEvent:event];
}

- (CGSize)sizeThatFits:(__unused CGSize)size
{
    CGSize dotSize = [self sizeForNumberOfPages:_numberOfPages];
    if (_selectedDotSize)
    {
        CGFloat width = (_selectedDotSize - _dotSize);
        CGFloat height = MAX(36, MAX(_dotSize, _selectedDotSize));
        dotSize.width = _vertical? height: dotSize.width + width;
        dotSize.height = _vertical? dotSize.height + width: height;

    }
    if ((_dotShadowColor && ![_dotShadowColor isEqual:[UIColor clearColor]]) ||
        (_selectedDotShadowColor && ![_selectedDotShadowColor isEqual:[UIColor clearColor]]))
    {
        dotSize.width += MAX(_dotShadowOffset.width, _selectedDotShadowOffset.width) * 2;
        dotSize.height += MAX(_dotShadowOffset.height, _selectedDotShadowOffset.height) * 2;
        dotSize.width += MAX(_dotShadowBlur, _selectedDotShadowBlur) * 2;
        dotSize.height += MAX(_dotShadowBlur, _selectedDotShadowBlur) * 2;
    }
    return dotSize;
}

- (CGSize)intrinsicContentSize
{
    return [self sizeThatFits:self.bounds.size];
}

#pragma mark - Accessibility

- (UIAccessibilityTraits)accessibilityTraits
{
    return UIAccessibilityTraitAdjustable;
}

- (void)accessibilityIncrement
{
    self.currentPage = self.currentPage + 1;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)accessibilityDecrement
{
    self.currentPage = self.currentPage - 1;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
