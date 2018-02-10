//
//  TOHeaderImageView.h
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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** An expandable image view that can be placed at the top of a scroll view. */
@interface TOHeaderImageView : UIView

/** The image that will be displayed in this view. */
@property (nonatomic, strong) UIImage *image;

/** Pass the Y value of `scrollView.contentOffset` to this property for the image to resize
 itself if the scroll view is pulled out of bounds. */
@property (nonatomic, assign) CGFloat scrollOffset;

/** If necessary, a subtle black gradient will be placed at the top in order to add more contrast
    to any white elements above it.*/
@property (nonatomic, assign) BOOL shadowHidden;

/** At the very top of the shadow gradient, the alpha value of the black color (Default is 0.2f. 1.0f would be opaque.) */
@property (nonatomic, assign) CGFloat shadowAlpha;

/** The overall height of the shadow. (Default value is 100 points) */
@property (nonatomic, assign) CGFloat shadowHeight;

/**
 Creates a new instance of this header image view class.

 @param image The image to be used as the background of this view
 @param height The initial height of this view (This can later be changed by changing the `frame` of this view)
 @return A new instance of `TOHeaderImageView`
 */
- (instancetype)initWithImage:(UIImage *)image height:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
