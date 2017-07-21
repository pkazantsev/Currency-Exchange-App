//
//  CEACurrexRates.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

#import "CEACurrexRates.h"

@interface CEACurrexRates ()

@property (strong, nonatomic, nonnull, readwrite) NSDate *ratesDate;
@property (strong, nonatomic, nonnull, readwrite) NSDictionary <NSString *, NSDecimalNumber *> *rates;

@end

@implementation CEACurrexRates

- (instancetype)initWithRates:(NSDictionary<NSString *,NSDecimalNumber *> *)rates onDate:(NSDate *)ratesDate {
    self = [super init];
    self.rates = [rates copy];
    self.ratesDate = [ratesDate copy];
    return self;
}

@end
