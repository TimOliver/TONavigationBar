//
//  ViewController.m
//  TONavigationBarExample
//
//  Created by Tim Oliver on 1/31/18.
//  Copyright © 2018 Tim Oliver. All rights reserved.
//

#import "ViewController.h"
#import "SubViewController.h"
#import "TONavigationBar.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"TONavigationBar";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    cell.textLabel.text = @"Tap here for more!";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SubViewController *viewController = [[SubViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [(TONavigationBar *)self.navigationController.navigationBar setBackgroundHidden:NO animated:animated transitionCoordinator:self.transitionCoordinator];
}

@end
