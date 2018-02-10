# TONavigationBar

<p align="center">
<img src="https://github.com/TimOliver/TONavigationBar/raw/master/screenshot.jpg" width="500" style="margin:0 auto" />
</p>

[![CocoaPods](https://img.shields.io/cocoapods/dt/TONavigationBar.svg?maxAge=3600)](https://cocoapods.org/pods/TONavigationBar)
[![Version](https://img.shields.io/cocoapods/v/TONavigationBar.svg?style=flat)](http://cocoadocs.org/docsets/TOCropViewController)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/TimOliver/TONavigationBar/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/TONavigationBar.svg?style=flat)](http://cocoadocs.org/docsets/TONavigationBar)
[![Beerpay](https://beerpay.io/TimOliver/TONavigationBar/badge.svg?style=flat)](https://beerpay.io/TimOliver/TONavigationBar)
[![PayPal](https://img.shields.io/badge/paypal-donate-blue.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=M4RKULAVKV7K8)


`TONavigationBar` is an open-source subclass of `UINavigationBar` that adds the ability to set the background content of the navigation bar to transparent, and then gradually bring it back in as the user scrolls through the page.

Apple use this effect in their 'modern' style iOS apps (Music, TV, App Store) for any content deemed 'notable'. Unfortunately, while it seems like a trivial thing to be able to do, none of the APIs necessary to reconfigure a `UINavigationBar` to be transparent in that way exist. `TONavigationBar` internally re-implements a variety of the `UINavigationBar` functionality in order to make this possible.

## Features
* Fully integrates into `UINavigationController`.
* Participates in `UINavigationController`'s 'swipe-to-go-back' gesture.
* Supports light and dark themed apps.
* Features an animation to restore to the normal `UINavigationBar` appearance.
* A target `UIScrollView` may be specified in order to avoid having to manually pass information to the bar.
* Library also features `TOHeaderImageView`, a header view that may be used as the banner in scroll views.

## System Requirements
iOS 10.0 or above

## Installation

#### As a CocoaPods Dependency

##### Objective-C

Add the following to your Podfile:
``` ruby
pod 'TONavigationBar'
```


#### Manual Installation

All of the necessary source files are in the `TONavigationBar`, folder. Simply copy that folder to your Xcode project and import all of the files in it.

## Examples
`TONavigationBar` has been designed to be as hands-off as possible. It integrates with `UINavigationController` and only needs to be interacted with when changing the visibility of the background content.

### Basic Implementation

#### Integrating with `UINavigationController`

```objc
#import "TONavigationBar.h"

UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[TONavigationBar class] toolbarClass:nil];

```

#### Showing and Hiding the Background Content

```objc
#import "TONavigationBar.h"

@implementation MyViewController // A child of the `UINavigationController` stack

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.to_navigationBar setBackgroundHidden:YES animated:animated forViewController:self];
    [self.navigationController.to_navigationBar setTargetScrollView:self.tableView minimumOffset:200.0f]; // 200.0f is the height of the header view
}

@end
```

#### Creating and Configuring a Header View

```objc
#import "TOHeaderImageView.h"

@interface MyTableViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) TOHeaderImageView *headerView;

@end

@implementation MyTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	    self.headerView = [[TOHeaderImageView alloc] initWithImage:[UIImage imageNamed:@"MyPicture.jpg"] height:200.0f];
    self.headerView.shadowHidden = NO;
    self.tableView.tableHeaderView = self.headerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.headerView.scrollOffset = scrollView.contentOffset.y;
}

@end

```


## Architecture of `TONavigationBar`

// TODO XD

## Credits
`TOCropViewController` was originally created by [Tim Oliver](http://twitter.com/TimOliverAU) as a component for [iComics](http://icomics.co), a comic reader app for iOS.

[Firewatch Wallpaper](http://blog.camposanto.com/post/138965082204/firewatch-launch-wallpaper-when-we-redid-the) by Campo Santo and is used for illustrative purposes. [Firewatch](http://store.steampowered.com/app/383870/Firewatch/) is available on Steam.

iOS Device mockups used in the screenshot created by [Pixeden](http://www.pixeden.com).

## License
`TONavigationBar` is licensed under the MIT License, please see the [LICENSE](LICENSE) file. ![analytics](https://ga-beacon.appspot.com/UA-5643664-16/TONavigationBar/README.md?pixel)
