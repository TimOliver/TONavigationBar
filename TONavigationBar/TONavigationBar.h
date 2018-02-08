//
//  TONavigationBar.h
//  TONavigationBarExample
//
//  Created by Tim Oliver on 1/31/18.
//  Copyright © 2018 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TONavigationBar : UINavigationBar

@property (nonatomic, assign) BOOL backgroundHidden;

@property (nonatomic, strong, nullable) UIColor *preferredTintColor;

@property (nonatomic, assign) UIBarStyle preferredBarStyle;

@property (nonatomic, strong, nullable) UIScrollView *targetScrollView;

@property (nonatomic, strong, nullable) NSNumber *scrollViewMinimumOffset;
@property (nonatomic, assign, nullable) NSNumber *scrollViewMaximumOffset;

- (void)setBackgroundHidden:(BOOL)hidden animated:(BOOL)animated;

- (void)setBackgroundHidden:(BOOL)hidden
                   animated:(BOOL)animated
          forViewController:(nullable UIViewController *)viewController;

- (void)setTargetScrollView:(nullable UIScrollView *)scrollView
       minimumOffset:(nullable NSNumber *)minimumContentOffset
       maximumOffset:(nullable NSNumber *)maximumContentOffset;

@end

/*********************************************************/

@interface UINavigationController (TONavigationBar)

@property (nonatomic, readonly, nullable) TONavigationBar *to_navigationBar;

@end

NS_ASSUME_NONNULL_END
