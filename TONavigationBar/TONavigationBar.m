//
//  TONavigationBar.m
//  TONavigationBarExample
//
//  Created by Tim Oliver on 1/31/18.
//  Copyright © 2018 Tim Oliver. All rights reserved.
//

#import "TONavigationBar.h"

@interface TONavigationBar ()

// A visual effect view that serves as the background for this navigation bar
@property (nonatomic, strong) UIVisualEffectView *backgroundView;

// A single point view that serves as the separator line if required
@property (nonatomic, strong) UIView *separatorView;

// The height of the separator, calculated once for efficiency
@property (nonatomic, assign) CGFloat separatorHeight;

// Fetch a reference to the title label so we can control it
@property (nonatomic, readonly) UILabel *titleTextLabel;

// An internal reference to the content view that holds all of visible subviews of the navigation bar
@property (nonatomic, weak) UIView *contentView;

@end

@implementation TONavigationBar

#pragma mark - View Creation -

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:nil];
        _separatorView = [[UIView alloc] initWithFrame:CGRectZero];
        _separatorHeight = 1.0f / [UIScreen mainScreen].scale;
    }
    
    return self;
}

#pragma mark - Subview Handling -

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    // Remove the default system elements that we'll be taking over
    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:[UIImage new]];
    
    // Now the views will have been laid down, capture the internal view that holds the labels
    [self captureContentView];
    
    // Update the views to match the current bar style
    [self updateContentViewsForBarStyle];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Ensure the effect view is still at the back of the view hierarchy
    [self insertSubview:self.backgroundView atIndex:0];
    
    // Ensure the separator is placed above the background view
    [self insertSubview:self.separatorView atIndex:1];
    
    // Extend the background view from the top of the screen to the bottom
    CGRect frame = self.bounds;
    frame.origin.y = -(CGRectGetMinY(self.frame));
    frame.size.height = CGRectGetMaxY(self.frame);
    self.backgroundView.frame = frame;
    
    // Place the separator view at the bottom of the background view
    frame = self.bounds;
    frame.origin.y = frame.size.height - _separatorHeight;
    frame.size.height = _separatorHeight;
    self.separatorView.frame = frame;
    
    // This will be called at the start of each navigation item
    // transition, by which point we will know if it needs to be surpressed
    // for the next animation.
    if (self.backgroundHidden) {
        self.titleTextLabel.hidden = YES;
        
        // Update the visiblity of the content depending on scroll progress
        [self updateBackgroundVisibilityForScrollView];
    }
}

- (void)updateContentViewsForBarStyle
{
    // Work out if we're light mode or dark
    BOOL darkMode = (self.preferredBarStyle != UIBarStyleDefault);
    
    // Change the visual effect style to match
    self.backgroundView.effect = [UIBlurEffect effectWithStyle:darkMode ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
    
    // Update the hue of the visual effect view to match the original
    if (!darkMode) {
        UIView *visualEffectSubview = self.backgroundView.subviews.lastObject;
        visualEffectSubview.backgroundColor = [UIColor colorWithWhite:0.97f alpha:0.8f];
    }
    
    // Configure the separator color
    CGFloat greyColor = darkMode ? 0.4f : 0.75f;
    self.separatorView.backgroundColor = [UIColor colorWithWhite:greyColor alpha:1.0f];
}

- (void)updateBackgroundVisibilityForScrollView
{
    if (self.targetScrollView == nil) {
        return;
    }

    CGFloat totalHeight = CGRectGetMaxY(self.frame); // Includes status bar
    CGFloat barHeight = CGRectGetHeight(self.frame);

    CGFloat offsetHeight = (self.targetScrollView.contentOffset.y - self.scrollViewMinimumOffset) + totalHeight;
    offsetHeight = MAX(offsetHeight, 0.0f);
    offsetHeight = MIN(offsetHeight, totalHeight);

    BOOL barShouldBeVisible = offsetHeight > 0.0f + FLT_EPSILON;
    
    // Layout the background view to slide into view
    CGRect frame = self.backgroundView.frame;
    if (barShouldBeVisible) {
        frame.origin.y = barHeight - offsetHeight;
        frame.size.height = offsetHeight;
        self.backgroundView.alpha = 1.0f;
    }
    else { // If it's hidden, reset it back in preparation of transitions
        frame.origin.y = -(CGRectGetMinY(self.frame));
        frame.size.height = CGRectGetMaxY(self.frame);
        self.backgroundView.alpha = 0.0f;
    }
    self.backgroundView.frame = frame;
    
    // Change alpha of the separator
    self.separatorView.alpha = MAX(0.0f, offsetHeight / (barHeight * 0.5f));
    
    // Change the alpha of the title label
    self.titleTextLabel.hidden = !barShouldBeVisible;
    self.titleTextLabel.alpha = MAX(offsetHeight - (barHeight * 0.75f), 0.0f) / (barHeight * 0.25f);
    
    // Change the tint color once it has passed the middle of the bar
    self.tintColor = (offsetHeight > barHeight * 0.5f) ? self.preferredTintColor : [UIColor whiteColor];
    
    // Change the status bar colour once the offset has reached its midpoint
    CGFloat statusBarHeight = totalHeight - barHeight;
    self.barStyle = (offsetHeight > barHeight + (statusBarHeight * 0.5f)) ? self.preferredBarStyle : UIBarStyleBlack;
}

#pragma mark - KVO Handling -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [self updateBackgroundVisibilityForScrollView];
}

#pragma mark - Transition Handling -

- (void)setBackgroundHidden:(BOOL)backgroundHidden
{
    [self setBackgroundHidden:backgroundHidden animated:NO forViewController:nil];
}

- (void)setBackgroundHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self setBackgroundHidden:hidden animated:animated forViewController:nil];
}

- (void)setBackgroundHidden:(BOOL)hidden animated:(BOOL)animated forViewController:(UIViewController *)viewController
{
    // Regardless of the outcome, force a re-layout so we can ensure all of our controlled views are up-to-date
    [self setNeedsLayout];
    
    if (hidden == _backgroundHidden) {
        return;
    }
    
    // An animation block that will handle transitioning all of the views during a 'non-hidden-to-hidden' animation
    void (^animationBlock)(BOOL) = ^(BOOL _hidden) {
        self.backgroundView.alpha = _hidden ? 0.0f : 1.0f;
        self.separatorView.alpha = _hidden ? 0.0f : 1.0f;
        self.tintColor = _hidden ? [UIColor whiteColor] : nil;

        // iOS 11 is pretty broken. If this code isn't set, the title labels
        // may sometimes fail to switch to the correct colour
        UIColor *textColor = (self.preferredBarStyle > UIBarStyleDefault) ? [UIColor whiteColor] : [UIColor blackColor];
        self.titleTextAttributes = @{NSForegroundColorAttributeName : textColor};
        self.largeTitleTextAttributes = @{NSForegroundColorAttributeName : textColor};
    };

    // A block for switching the bar style, separate from the animation block since there
    // are times when it shouldn't be animated
    void (^toggleBarStyleBlock)(void) = ^{
        self.barStyle = hidden ? UIBarStyleBlack : self.preferredBarStyle;
    };
    
    // Set the new value
    _backgroundHidden = hidden;
    
    // Release the observed scroll view since toggling to non-hidden implies a change in scroll view
    if (!hidden) {
        self.targetScrollView = nil;
    }
    
    // If no transition coordinator was supplied, defer back to a pre-canned animation.
    // Also, for some annoying reason, the initial coordinator transition animation in iOS 11 fails to play the animation properly. (Possibly a UIKit bug)
    // As a result, if there is a coordinator, but the animation is NOT interactive, default back to the pre-canned animation
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = viewController.transitionCoordinator;
    if (transitionCoordinator == nil || (transitionCoordinator && !transitionCoordinator.initiallyInteractive)) {
        CGFloat duration = 0.35f;
        if (transitionCoordinator) { duration = transitionCoordinator.transitionDuration; }
        
        if (animated) {
            [UIView animateWithDuration:duration animations:^{
                toggleBarStyleBlock();
                animationBlock(hidden);
            }];
        }
        else {
            toggleBarStyleBlock();
            animationBlock(hidden);
        }
        return;
    }
    
    // Apparently parts of the status bar can fail to change color when captured in an interactive transition. So in thoses
    // cases, simply flip the bar style outside of the block.
    toggleBarStyleBlock();
    
    // If we are in an interactive animation (eg, swipe-to-go-back in UINavigationController), attach the animations to the coordinator
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        animationBlock(hidden);
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // If the transition cancelled (eg, the user swiped back, but let go too soon), restore to the previous state
        if (context.cancelled) {
            animationBlock(hidden);
        }
    }];
}

#pragma mark - Internal View Traversal -
- (BOOL)captureContentView
{
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass([subview class]) rangeOfString:@"Content"].location != NSNotFound) {
            self.contentView = subview;
            return YES;
        }
    }
    
    return NO;
}

- (UILabel *)titleTextLabel
{
    // This is somewhat fragile as it relies on the internal ordering of the UINavigationBar subviews
    // to catch the right one (unless Apple is performing manual layer ordering. In which case we're fine!)
    // The title label we want is always the first `UILabel` in the `UINavigationBar` stack, once an animation has started.
    for (UIView *subSubview in self.contentView.subviews) {
        if ([subSubview isKindOfClass:[UILabel class]]) {
            return (UILabel *)subSubview;
        }
    }
    
    return nil;
}

- (void)setPreferredBarStyle:(UIBarStyle)preferredBarStyle
{
    if (_preferredBarStyle == preferredBarStyle) { return; }
    _preferredBarStyle = preferredBarStyle;
    [self updateContentViewsForBarStyle];
}

- (void)setTargetScrollView:(UIScrollView *)scrollView minimumOffset:(CGFloat)minimumContentOffset
{
    self.targetScrollView = scrollView;
    self.scrollViewMinimumOffset = minimumContentOffset;
}

- (void)setTargetScrollView:(UIScrollView *)targetScrollView
{
    if (_targetScrollView == targetScrollView) { return; }
    
    // Remove observer from previous scroll view
    [_targetScrollView removeObserver:self forKeyPath:@"contentOffset"];
    
    _targetScrollView = targetScrollView;
    
    // Assign new scroll view to be observed
    if (_targetScrollView != nil) {
        [_targetScrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    }
}

@end

#pragma mark - UINavigationController Integration -

@implementation UINavigationController (TONavigationBar)

- (TONavigationBar *)to_navigationBar
{
    if ([self.navigationBar isKindOfClass:[TONavigationBar class]]) {
        return (TONavigationBar *)self.navigationBar;
    }
    
    return nil;
}

@end
