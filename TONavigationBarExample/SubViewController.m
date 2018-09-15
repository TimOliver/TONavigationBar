//
//  SubViewController.m
//  TONavigationBarExample
//
//  Created by Tim Oliver on 1/31/18.
//  Copyright © 2018 Tim Oliver. All rights reserved.
//

#import "SubViewController.h"
#import "ViewController.h"
#import "TONavigationBar.h"
#import "TOHeaderImageView.h"

@interface SubViewController ()

@property (nonatomic, strong) TOHeaderImageView *headerView;

@end

@implementation SubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Firewatch";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    // Set up the header view
    self.headerView = [[TOHeaderImageView alloc] initWithImage:[UIImage imageNamed:@"Firewatch.jpg"] height:200.0f];
    self.headerView.shadowHidden = NO;
    self.tableView.tableHeaderView = self.headerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.to_navigationBar setBackgroundHidden:YES animated:animated forViewController:self];
    [self.navigationController.to_navigationBar setTargetScrollView:self.tableView minimumOffset:200.0f];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.headerView.scrollOffset = scrollView.contentOffset.y;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = @"Tap here for normal bar";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewController *viewController = [[ViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
