//
//  AppDelegate.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/20/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

#import "AppDelegate.h"

#import "CEANetwork.h"
#import "CEACurrexAPI.h"
#import "ViewModel.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic, nonnull) CEACurrexAPI *api;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    id <CEANetwork> network = [[CEANetworkImpl alloc] init];
    self.api = [[CEACurrexAPI alloc] initWithNetwork:network];

    ViewModel *viewModel = [[ViewModel alloc] initWithApi:self.api];

    ViewController *vc = (ViewController *)self.window.rootViewController;
    vc.viewModel = viewModel;

    return YES;
}

@end
