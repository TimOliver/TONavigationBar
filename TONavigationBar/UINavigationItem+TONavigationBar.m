//
//  UINavigationItem+TONavigationBar.m
//  TONavigationBarExample
//
//  Created by Tim Oliver on 4/2/18.
//  Copyright © 2018 Tim Oliver. All rights reserved.
//

#import "UINavigationItem+TONavigationBar.h"
#import "TONavigationBarPlaceholderTitleView.h"

#import <objc/runtime.h>

static void *TONavigationBarPlaceholderTitleViewKeyName;
static void *TONavigationBarOriginalTitleViewKeyName;

@implementation UINavigationItem (TONavigationBar)

- (void)setTo_titleHidden:(BOOL)to_titleHidden
{
    if (self.to_titleHidden == to_titleHidden) { return; }
    
    if (to_titleHidden == NO) {
        self.titleView = self.to_originalTitleView ?: nil;
        return;
    }
    
    if (self.titleView) {
        self.to_originalTitleView = self.titleView;
    }
    
    self.titleView = self.to_placeholderTitleView;
    
    if (self.to_originalTitleView == nil) {
        CGRect frame = CGRectZero;
        UIFont *titleFont = [UIFont systemFontOfSize:17.0f];
        frame.size = [self.title sizeWithAttributes:@{NSFontAttributeName : titleFont}];
        self.to_placeholderTitleView.frame = frame;
        [self.to_placeholderTitleView.superview setNeedsLayout];
    }
}

- (BOOL)to_titleHidden
{
    return [self.titleView isKindOfClass:[TONavigationBarPlaceholderTitleView class]];
}

- (void)setTo_originalTitleView:(UIView *)to_orignalTitleView
{
    objc_setAssociatedObject(self, &TONavigationBarOriginalTitleViewKeyName, to_orignalTitleView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)to_originalTitleView
{
    return objc_getAssociatedObject(self, &TONavigationBarOriginalTitleViewKeyName);
}

- (TONavigationBarPlaceholderTitleView *)to_placeholderTitleView
{
    TONavigationBarPlaceholderTitleView *view = (TONavigationBarPlaceholderTitleView *)objc_getAssociatedObject(self, &TONavigationBarPlaceholderTitleViewKeyName);
    if (view == nil) {
        view = [[TONavigationBarPlaceholderTitleView alloc] initWithFrame:CGRectZero];
        objc_setAssociatedObject(self, &TONavigationBarPlaceholderTitleViewKeyName, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}

@end
