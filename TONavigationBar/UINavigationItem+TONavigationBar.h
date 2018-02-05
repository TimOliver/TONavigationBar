//
//  UINavigationItem+TONavigationBar.h
//  TONavigationBarExample
//
//  Created by Tim Oliver on 4/2/18.
//  Copyright © 2018 Tim Oliver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (TONavigationBar)

/* Used to show/hide either the title label, or custom title view of this item. */
@property (nonatomic, assign) BOOL to_titleHidden;

/* A completely transparent view which is used to suppress this navigation item's label
from appearing in the navigation bar when desired by setting it as `titleView`. */
@property (nonatomic, readonly) UIView *to_placeholderTitleView;

/* If `titleView` was already set as a custom view before this navigation item used the placeholder
 view, the custom view will be saved here so it can be restored later. */
@property (nonatomic, strong) UIView *to_originalTitleView;

@end
