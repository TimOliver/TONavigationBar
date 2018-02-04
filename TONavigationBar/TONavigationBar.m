//
//  TONavigationBar.m
//  TONavigationBarExample
//
//  Created by Tim Oliver on 1/31/18.
//  Copyright © 2018 Tim Oliver. All rights reserved.
//

#import "TONavigationBar.h"

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
//@property (nonatomic, strong) UIView *titleView;

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
    
    // If we've got a custom title view, configure the text color
    if (self.topItem.titleView && [self.topItem.titleView isKindOfClass:[UILabel class]]) {
        UILabel *titleLabel = (UILabel *)self.topItem.titleView;
        titleLabel.textColor = (!darkMode ? [UIColor blackColor] : [UIColor whiteColor]);
    }
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
    if (hidden == _backgroundHidden) {
        return;
    }
    
    void (^animationBlock)(BOOL) = ^(BOOL _hidden) {
        self.backgroundView.alpha = _hidden ? 0.0f : 1.0f;
        self.separatorView.alpha = _hidden ? 0.0f : 1.0f;
        self.tintColor = _hidden ? [UIColor whiteColor] : nil;
        self.barStyle = _hidden ? UIBarStyleBlack : self.preferredBarStyle;
    };
    
    _backgroundHidden = hidden;
    
    // Configure a custom title view that we can explicitly control
    [self configureNavigationItem:viewController.navigationItem];
    
    // If no transition coordinator was supplied, defer back to a pre-canned animation.
    // For some annoying reason, the initial transition coordinator in iOS 11 fails to play the animation properly. (Possibly a UIKit bug)
    // As a result, if there is a coordinator, but the animation is NOT interactive, default back to the pre-canned animation
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = viewController.transitionCoordinator;
    if (transitionCoordinator == nil || (transitionCoordinator && !transitionCoordinator.initiallyInteractive)) {
        CGFloat duration = 0.35f;
        if (transitionCoordinator) { duration = transitionCoordinator.transitionDuration; }
        
        if (animated) {
            [UIView animateWithDuration:duration animations:^{
                animationBlock(hidden);
            }];
        }
        else {
            animationBlock(hidden);
        }
        return;
    }
    
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

- (void)configureNavigationItem:(UINavigationItem *)navigationItem
{
    // Either we've configured one already, or the view controller already has its own
    if (navigationItem.titleView) { return; }
    
    // Create a custom title view that we can control
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    titleLabel.textColor = self.barStyle != UIBarStyleDefault ? [UIColor whiteColor] : [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = "TOOMyGodAReallyLongViewControllerName";
    [titleLabel sizeToFit];
    
    navigationItem.titleView = titleLabel;
}

#pragma mark - Accessors -

- (void)setBarStyle:(UIBarStyle)barStyle
{
    [super setBarStyle:barStyle];
    [self updateContentViewsForBarStyle];
}

@end
