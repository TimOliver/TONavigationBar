//
//  TOHeaderImageView.h
//  TONavigationBarExample
//
//  Created by Tim Oliver on 2/10/18.
//  Copyright © 2018 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOHeaderImageView : UIView

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) CGFloat scrollOffset;

@property (nonatomic, assign) BOOL shadowHidden;
@property (nonatomic, assign) CGFloat shadowAlpha;
@property (nonatomic, assign) CGFloat shadowHeight;

- (instancetype)initWithImage:(UIImage *)image height:(CGFloat)height;

@end
