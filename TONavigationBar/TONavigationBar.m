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
    
    CGFloat greyColor = darkMode ? 0.8f : 0.3f;
    self.separatorView.backgroundColor = [UIColor colorWithWhite:greyColor alpha:1.0f];
}

#pragma mark - Transition Handling -
- (void)setBackgroundHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self setBackgroundHidden:hidden animated:animated transitionCoordinator:nil];
}

- (void)setBackgroundHidden:(BOOL)hidden animated:(BOOL)animated transitionCoordinator:(id<UIViewControllerTransitionCoordinator>)transitionCoordinator
{
    void (^animationBlock)(void) = ^{
        self.backgroundView.alpha = hidden ? 0.0f : 1.0f;
        self.separatorView.alpha = hidden ? 0.0f : 1.0f;
        self.tintColor = hidden ? [UIColor whiteColor] : nil;
        self.barStyle = hidden ? UIBarStyleBlack : UIBarStyleDefault; 
    };
    
    // If no transition coordinator was supplied, defer back to a pre-canned animation.
    // For some annoying reason, the initial transition coordinator in iOS 11 fails to play the animation properly. (Possibly a UIKit bug)
    // As a result, if there is a coordinator, but the animation is NOT interactive, default back to the pre-canned animation
    if (transitionCoordinator == nil || (transitionCoordinator && !transitionCoordinator.initiallyInteractive)) {
        CGFloat duration = 0.35f;
        if (transitionCoordinator) { duration = transitionCoordinator.transitionDuration; }
        
        if (animated) {
            [UIView animateWithDuration:duration animations:animationBlock];
        }
        else {
            animationBlock();
        }
        return;
    }
    
    // If we are in an interactive animation (eg, swipe-to-go-back in UINavigationController), attach the animations to the coordinator
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        animationBlock();
    } completion:nil];
}

#pragma mark - Accessors -

- (void)setBarStyle:(UIBarStyle)barStyle
{
    [super setBarStyle:barStyle];
    [self updateContentViewsForBarStyle];
}

@end
