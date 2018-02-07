//
//  TONavigationBar.m
//  TONavigationBarExample
//
//  Created by Tim Oliver on 1/31/18.
//  Copyright © 2018 Tim Oliver. All rights reserved.
//

#import "TONavigationBar.h"
#import "UINavigationItem+TONavigationBar.h"

#define UIKitLocalizedString(key) [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:key value:@"" table:nil]

@interface TONavigationBar () <UINavigationControllerDelegate>

// The `UINavigationController` object that is governing this navigation bar
@property (nonatomic, weak) UINavigationController *navigationController;

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
    
    //
    if (self.backgroundHidden) {
        self.titleTextLabel.hidden = YES;
    }
}

- (void)updateContentViewsForBarStyle
{
    // Work out if we're light mode or dark
    BOOL darkMode = (self.barStyle != UIBarStyleDefault);
    
    // Change the visual effect style to match
    self.backgroundView.effect = [UIBlurEffect effectWithStyle:darkMode ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
    
    // Update the hue of the visual effect view to match the original
    if (!darkMode) {
        UIView *visualEffectSubview = self.backgroundView.subviews.lastObject;
        visualEffectSubview.backgroundColor = [UIColor colorWithWhite:0.97f alpha:0.8f];
    }
    
    // Configure the separator color
    CGFloat greyColor = darkMode ? 0.8f : 0.4f;
    self.separatorView.backgroundColor = [UIColor colorWithWhite:greyColor alpha:1.0f];
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
    
    // If no transition coordinator was supplied, defer back to a pre-canned animation.
    // For some annoying reason, the initial transition coordinator in iOS 11 fails to play the animation properly. (Possibly a UIKit bug)
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
        [viewController setNeedsStatusBarAppearanceUpdate];
        
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
    // The title label is always the first `UILabel` in the `UINavigationBar` stack, once an animation has started.
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

@end
