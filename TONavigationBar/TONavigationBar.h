//
//  TONavigationBar.h
//  TONavigationBarExample
//
//  Created by Tim Oliver on 1/31/18.
//  Copyright © 2018 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TONavigationBar : UINavigationBar

@property (nonatomic, assign) BOOL backgroundHidden;

@property (nonatomic, assign) UIBarStyle preferredBarStyle;

- (void)setBackgroundHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setBackgroundHidden:(BOOL)hidden animated:(BOOL)animated forViewController:(UIViewController *)viewController;

@end
