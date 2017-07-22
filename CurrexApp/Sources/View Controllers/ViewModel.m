//
//  ViewModel.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/22/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

#import "ViewModel.h"

#import "CEACurrexAPI.h"
#import "CEACurrexRates.h"

@interface ViewModel ()

///
@property (strong, nonatomic, nonnull) CEACurrexAPI *api;
///
@property (strong, nonatomic, nullable) RACDisposable *disposable;
///
@property (strong, nonatomic, nullable) CEACurrexRates *currentRates;

@end

@implementation ViewModel

- (instancetype)initWithApi:(CEACurrexAPI *)api {
    self = [super init];
    self.api = api;
    return self;
}

- (RACSignal<NSDecimalNumber *> *)conversionRateFrom:(NSString *)currCurrency to:(NSString *)targetCurrency {
    return [[[RACObserve(self, currentRates) distinctUntilChanged] map:^NSDecimalNumber *_Nullable(CEACurrexRates *_Nullable rates) {
        if (rates) {
            return [ViewModel mapBetweenCurrency:currCurrency
                                     andCurrency:targetCurrency
                                       fromRates:rates];
        }
        return nil;
    }] ignore:nil];
}
+ (NSDecimalNumber *_Nullable)mapBetweenCurrency:(NSString *_Nonnull)src
                                     andCurrency:(NSString *_Nonnull)dst
                                       fromRates:(CEACurrexRates *_Nonnull)rates {
    if ([src isEqualToString:@"EUR"]) {
        return rates.rates[dst];
    } else if ([dst isEqualToString:@"EUR"]) {
        NSDecimalNumber *currRate = rates.rates[src];
        if (currRate) {
            return [NSDecimalNumber.one decimalNumberByDividingBy:currRate];
        }
    } else {
        NSDecimalNumber *currRate = rates.rates[src];
        NSDecimalNumber *targetRate = rates.rates[dst];
        if (currRate && targetRate) {
            NSDecimalNumber *interimRate = [NSDecimalNumber.one decimalNumberByDividingBy:currRate];
            return [interimRate decimalNumberByMultiplyingBy:targetRate];
        }
    }
    return nil;
}

- (void)startFetchingRates {
    @weakify(self)
    RACSignal<NSDate *> *signal = [RACSignal merge:
        @[[RACSignal return:[NSDate date]],
          [RACSignal interval:30.0 onScheduler:[RACScheduler mainThreadScheduler]]]];
    self.disposable = [[signal flattenMap:^RACSignal<CEACurrexRates *> *_Nullable(NSDate *_Nullable value) {
        @strongify(self)
        return [self.api fetchExchangeRates];
    }] subscribeNext:^(CEACurrexRates *_Nullable rates) {
        @strongify(self)
        self.currentRates = rates;
    }];
}
- (void)stopFetchingRates {
    [self.disposable dispose];
    self.disposable = nil;
}

@end
