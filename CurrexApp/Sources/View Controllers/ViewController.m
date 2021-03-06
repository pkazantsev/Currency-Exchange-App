//
//  ViewController.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/20/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

#import "ViewController.h"

#import "View.h"
#import "ViewModel.h"

#import "UIButtton_CurrexApp.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet View *mainView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    ViewModel *viewModel = self.viewModel;

    [self.viewModel startFetchingRates];
    [[NSNotificationCenter.defaultCenter rac_addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        [viewModel stopFetchingRates];
    }];
    [[NSNotificationCenter.defaultCenter rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        [viewModel startFetchingRates];
    }];

    RAC(self.mainView.firstCurrencyLabel, text) = RACObserve(self.viewModel, firstCurrency);
    RAC(self.mainView.secondCurrencyLabel, text) = RACObserve(self.viewModel, secondCurrency);
    RAC(self.mainView.firstCurrencyAmountLabel, text) = RACObserve(self.viewModel, firstCurrencyAmount);
    RAC(self.mainView.secondCurrencyAmountLabel, text) = RACObserve(self.viewModel, secondCurrencyAmount);
    RAC(self.mainView.exchangeRateLabel, text) = RACObserve(self.viewModel, exchangeRate);

    RAC(self.mainView.prevCurrencyPairButton, title) = RACObserve(self.viewModel, prevExchangeButtonText);
    RAC(self.mainView.nextCurrencyPairButton, title) = RACObserve(self.viewModel, nextExchangeButtonText);
    RAC(self.mainView.changeExchangeDirectionButton, title) = RACObserve(self.viewModel, exchangeDirectionButtonText);

    RAC(self.mainView.firstCurrencyAmountTextField, backgroundColor) = [self.viewModel.firstAmountEnoughSignal map:^UIColor *_Nullable(NSNumber * _Nullable isEnough) {
        return (isEnough.boolValue ? nil : [[UIColor orangeColor] colorWithAlphaComponent:0.56]);
    }];
    RAC(self.mainView.secondCurrencyAmountTextField, backgroundColor) = [self.viewModel.secondAmountEnoughSignal map:^UIColor *_Nullable(NSNumber * _Nullable isEnough) {
        return (isEnough.boolValue ? nil : [[UIColor orangeColor] colorWithAlphaComponent:0.56]);
    }];
    RAC(self.mainView.exchangeCurrencyButton, enabled) = [[RACSignal combineLatest:@[self.viewModel.firstAmountEnoughSignal, self.viewModel.secondAmountEnoughSignal]] map:^NSNumber *_Nullable(RACTuple * _Nullable tuple) {
        return @(((NSNumber *)tuple.first).boolValue && ((NSNumber *)tuple.second).boolValue);
    }];

    [[self.mainView.prevCurrencyPairButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [viewModel goToPrevCurrenciesPair];
    }];
    [[self.mainView.nextCurrencyPairButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [viewModel goToNextCurrenciesPair];
    }];
    [[self.mainView.changeExchangeDirectionButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [viewModel switchDirection];
    }];
    [[self.mainView.exchangeCurrencyButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [viewModel exchange];
    }];

    RAC(self.mainView.firstCurrencyAmountTextField, text) = RACObserve(self.viewModel, firstCurrencyUserSetAmount);
    RAC(self.mainView.secondCurrencyAmountTextField, text) = RACObserve(self.viewModel, secondCurrencyUserSetAmount);

    [[[[self.mainView.firstCurrencyAmountTextField rac_textSignal] ignore:nil] ignore:@""] subscribeNext:^(NSString * _Nullable value) {
        [viewModel updateSecondAmountWithFirstAmountString:value];
    }];
    [[[[self.mainView.secondCurrencyAmountTextField rac_textSignal] ignore:nil] ignore:@""] subscribeNext:^(NSString * _Nullable value) {
        [viewModel updateFirstAmountWithSecondAmountString:value];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.viewModel populateWithData];
}

@end
