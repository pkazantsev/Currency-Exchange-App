//
//  ViewController.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/20/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

#import "ViewController.h"

#import "ViewModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewModel startFetchingRates];
}


@end
