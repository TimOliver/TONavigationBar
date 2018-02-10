//
//  TOHeaderImageView.m
//
//  Copyright 2018 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOHeaderImageView.h"

@interface TOHeaderImageView ()

/** The image view which displays the background image.
    This is kept as a private subview so its own height can change independently
    of the main view. (Necessary if it's a `UITableView` header view). */
@property (nonatomic, strong) UIImageView *imageView;

/** The view that displays the gradient view above the background image. */
@property (nonatomic, strong) UIImageView *gradientView;

/** Changing either `shadowAlpha` or `shadowHeight` will set this flag to YES,
    which will trigger a regeneration of the shadow image on the next layout. */
@property (nonatomic, assign) BOOL shadowIsDirty;

@end

@implementation TOHeaderImageView

#pragma mark - View Creation -

- (instancetype)initWithImage:(UIImage *)image height:(CGFloat)height
{
    CGRect frame = (CGRect){0.0f, 0.0f, 320.0f, height};
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.contentMode = UIViewContentModeScaleAspectFill;
        _image = image;
        _shadowHeight = 100.0f;
        _shadowHidden = YES;
        _shadowAlpha = 0.2f;
        _shadowIsDirty = YES;
        [self setUpViews];
    }
    
    return self;
}

- (void)setUpViews
{
    self.imageView = [[UIImageView alloc] initWithImage:_image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.imageView];
    
    self.gradientView = [[UIImageView alloc] initWithImage:nil];
    self.gradientView.layer.magnificationFilter = kCAFilterNearest;
    self.gradientView.hidden = YES;
    [self.imageView addSubview:self.gradientView];
}

#pragma mark - View Lifecycle -

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (self.shadowHeight < 0.0f + FLT_EPSILON) {
        self.shadowHeight = 110.0f;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.imageView.frame;
    frame.size = self.bounds.size;
    frame.origin = CGPointZero;
    
    // Lay out the image view, scaling up as the scroll view goes down
    if (self.scrollOffset < 0.0f) {
        CGFloat offset = fabs(self.scrollOffset);
        frame.origin.y = -offset;
        frame.size.height += offset;
    }
    self.imageView.frame = frame;
    
    // Skip the rest if the shadow is not being used
    if (self.shadowHidden) {
        return;
    }
    
    // If needed, generate a new shadow image
    if (self.shadowIsDirty) {
        self.gradientView.image = [TOHeaderImageView shadowImageForHeight:_shadowHeight alpha:_shadowAlpha];
        self.shadowIsDirty = NO;
    }
    
    // Lay out the shadow view
    frame = self.gradientView.frame;
    frame.size.height = self.shadowHeight;
    frame.size.width = self.bounds.size.width;
    frame.origin.y = (self.scrollOffset < 0.0f) ? 0.0f : fabs(self.scrollOffset);
    frame.origin.x = 0.0f;
    self.gradientView.frame = frame;
}

#pragma mark - View Layout -

- (void)setShadowHeight:(CGFloat)shadowHeight
{
    if (shadowHeight == _shadowHeight) { return; }
    _shadowHeight = shadowHeight;
    self.shadowIsDirty = YES;
}

- (void)setShadowAlpha:(CGFloat)shadowAlpha
{
    if (_shadowAlpha == shadowAlpha) { return; }
    _shadowAlpha = shadowAlpha;
    self.shadowIsDirty = YES;
}

- (void)setScrollOffset:(CGFloat)scrollOffset
{
    if (_scrollOffset == scrollOffset) { return; }
    _scrollOffset = scrollOffset;
    [self setNeedsLayout];
}

- (void)setShadowHidden:(BOOL)shadowHidden
{
    if (_shadowHidden == shadowHidden) { return; }
    _shadowHidden = shadowHidden;
    self.gradientView.hidden = shadowHidden;
    [self setNeedsLayout];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.imageView.backgroundColor = backgroundColor;
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    self.imageView.contentMode = contentMode;
}

- (void)setImage:(UIImage *)image
{
    if (image == _image) { return; }
    _image = image;
    self.imageView.image = image;
}

#pragma mark - Image Generation -

+ (UIImage *)shadowImageForHeight:(CGFloat)height alpha:(CGFloat)alpha
{
    UIImage *shadowImage = nil;
    CGRect frame = (CGRect){0.0f, 0.0f, 1.0f, height};
    
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0f);
    {
        //// General Declarations
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //// Color Declarations
        UIColor* bottomColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0];
        UIColor* topColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: alpha];
        
        //// Gradient Declarations
        CGFloat gradientLocations[] = {0, 1};
        CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)@[(id)topColor.CGColor, (id)bottomColor.CGColor], gradientLocations);
        
        //// Rectangle Drawing
        CGRect rectangleRect = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), frame.size.width, frame.size.height);
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: rectangleRect];
        CGContextSaveGState(context);
        [rectanglePath addClip];
        CGContextDrawLinearGradient(context, gradient,
                                    CGPointMake(CGRectGetMidX(rectangleRect), CGRectGetMinY(rectangleRect)),
                                    CGPointMake(CGRectGetMidX(rectangleRect), CGRectGetMaxY(rectangleRect)),
                                    kNilOptions);
        CGContextRestoreGState(context);
        
        
        //// Cleanup
        CGGradientRelease(gradient);
        
        shadowImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return shadowImage;
}

@end
