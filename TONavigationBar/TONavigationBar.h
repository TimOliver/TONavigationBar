//
//  TONavigationBar.h
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

/** A `UINavigationBar` subclass that allows the bar to transition to a clear state with just the bar buttons visible. */
@interface TONavigationBar : UINavigationBar

/** Sets whether the bar background and title label are hidden, and the tint color is white. */
@property (nonatomic, assign) BOOL backgroundHidden;


/** Since this view internally controls `tintColor`, set this property if you wish to override
 the bar's tint color to something different than the system default when the bar is not hidden. */
@property (nonatomic, strong, nullable) UIColor *preferredTintColor;


/** By default, when the bar is not hidden, the bar style is default. Use this property
 to override the bar style when not hidden. */
@property (nonatomic, assign) UIBarStyle preferredBarStyle;


/** When this scroll view is attached and `scrollViewMinimumOffset` is set, this bar will
 automatically transition to non-hidden once the scroll view goes past the minimum threshold.
 
 Once the target scroll view is dismissed, it is best to also set `targetScrollView = nil` here to clear out
 the key-value observer.
 */
@property (nonatomic, strong, nullable) UIScrollView *targetScrollView;


/** Use this property to dictate the scrolling threshold for when the bar should transition to non-hidden.
 For example, for a `UITableView` header view that is 200 points tall, specify 200.0f
 */
@property (nonatomic, assign) CGFloat scrollViewMinimumOffset;


/**
 Shows/hides the bar background views, and the title label. Can be optionally animated

 @param hidden Whether the bar background is visible or not.
 @param animated Whether a crossfade animation plays or not.
 */
- (void)setBackgroundHidden:(BOOL)hidden animated:(BOOL)animated;


/**
 Shows/hides the bar background view and the title label. Additionally specifying a view controller
 will tie this bar's animations into the view controller's transition coordinator, enabling interactive
 progression of the animation when needed (eg, the 'swipe-to-go-back' gesture in `UINavigationController`)

 @param hidden Whether the background content is hidden
 @param animated Whether the transition is animated
 @param viewController The view controller that this bar is currently representing
 */
- (void)setBackgroundHidden:(BOOL)hidden
                   animated:(BOOL)animated
          forViewController:(nullable UIViewController *)viewController;


/**
 A convenience method for specifiying the target scroll view and the minimum scrolling threshold for this bar

 @param scrollView The `UIScrollView` to be observed by this
 @param minimumContentOffset The minimum Y content offset the scrollview needs to hit before the bar will animate its background in
 */
- (void)setTargetScrollView:(nullable UIScrollView *)scrollView minimumOffset:(CGFloat)minimumContentOffset;

@end

/*********************************************************/

/** A convenience category to more easily access the `TONavigationBar` instance managed by a `UINavigationController` */
@interface UINavigationController (TONavigationBar)

/* If the `UINavigationController` was instantiated with the `TONavigationBar` class, this will return that instance. Otherwise it will return `nil`. */
@property (nonatomic, readonly, nullable) TONavigationBar *to_navigationBar;

@end

NS_ASSUME_NONNULL_END
