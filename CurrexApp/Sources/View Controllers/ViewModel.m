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
@property (strong, nonatomic, nonnull) NSArray<NSString *> *currencyCodes;
///
@property (strong, nonatomic, nonnull) NSMutableDictionary<NSString *, NSDecimalNumber *> *amounts;
///
@property (strong, nonatomic, nonnull) CEACurrexAPI *api;
///
@property (strong, nonatomic, nullable) RACDisposable *disposable;
///
@property (strong, nonatomic, nullable) CEACurrexRates *currentRates;
/// For current amount
@property (strong, nonatomic, nonnull) NSNumberFormatter *firstCurrencyFormatter;
@property (strong, nonatomic, nonnull) NSNumberFormatter *secondCurrencyFormatter;
/// For exchange rate and text fields
@property (strong, nonatomic, nonnull, readwrite) NSNumberFormatter *decimalFormatter;
///
@property (strong, nonatomic, nonnull) NSDecimalNumber *currentExchangeRate;
/// Amount in the bank (self.amounts)
@property (strong, nonatomic, nonnull) NSDecimalNumber *firstAmount;
/// Amount in the bank (self.amounts)
@property (strong, nonatomic, nonnull) NSDecimalNumber *secondAmount;
/// Amount set by user in the left text field
@property (strong, nonatomic, nonnull) NSDecimalNumber *firstUserSetAmount;
/// Amount set by user in the right text field
@property (strong, nonatomic, nonnull) NSDecimalNumber *secondUserSetAmount;

/// Indicates if amount user entered is not enough for exchange
@property (strong, nonatomic, nonnull, readwrite) RACSignal<NSNumber *> *firstAmountEnoughSignal;
@property (strong, nonatomic, nonnull, readwrite) RACSignal<NSNumber *> *secondAmountEnoughSignal;

@property (nonatomic) NSInteger sourceCurrencyIndex;
@property (nonatomic) NSInteger targetCurrencyIndex;

#pragma mark - Output properties
///
@property (strong, nonatomic, nonnull, readwrite) NSString *firstCurrency;
@property (strong, nonatomic, nonnull, readwrite) NSString *secondCurrency;

@property (strong, nonatomic, nonnull, readwrite) NSString *exchangeRate;

@property (strong, nonatomic, nonnull, readwrite) NSString *firstCurrencyAmount;
@property (strong, nonatomic, nonnull, readwrite) NSString *secondCurrencyAmount;

@property (strong, nonatomic, nonnull, readwrite) NSString *firstCurrencyUserSetAmount;
@property (strong, nonatomic, nonnull, readwrite) NSString *secondCurrencyUserSetAmount;

@property (strong, nonatomic, nonnull, readwrite) NSString *prevExchangeButtonText;
@property (strong, nonatomic, nonnull, readwrite) NSString *nextExchangeButtonText;

@property (strong, nonatomic, nonnull, readwrite) NSString *exchangeDirectionButtonText;
///
@property (nonatomic, readwrite) BOOL forwardExchange;

@end

@implementation ViewModel

- (instancetype)initWithApi:(CEACurrexAPI *)api {
    self = [super init];

    self.api = api;
    self.currencyCodes = @[@"EUR", @"USD", @"GBP"];
    self.amounts = [@{@"EUR": [NSDecimalNumber decimalNumberWithString:@"100"],
                      @"USD": [NSDecimalNumber decimalNumberWithString:@"100"],
                      @"GBP": [NSDecimalNumber decimalNumberWithString:@"100"]} mutableCopy];

    [self configureNumberFormatters];
    [self registerObservers];

    return self;
}

- (void)populateWithData {

    self.forwardExchange = YES;
    self.currentExchangeRate = NSDecimalNumber.one;

    self.sourceCurrencyIndex = 0;
    self.targetCurrencyIndex = 1;

    self.firstCurrency = self.currencyCodes[self.sourceCurrencyIndex];
    self.secondCurrency = self.currencyCodes[self.targetCurrencyIndex];

    self.firstCurrencyFormatter.currencyCode = self.firstCurrency;
    self.secondCurrencyFormatter.currencyCode = self.secondCurrency;

    self.firstAmount = self.amounts[self.firstCurrency];
    self.secondAmount = self.amounts[self.secondCurrency];

    self.firstUserSetAmount = self.amounts[self.firstCurrency];

}

- (void)exchange {
    BOOL didExchange = NO;
    if (self.forwardExchange) {
        if (self.firstUserSetAmount && [self.firstAmount compare:self.firstUserSetAmount] != NSOrderedAscending) {
            self.firstAmount = [self.firstAmount decimalNumberBySubtracting:self.firstUserSetAmount];
            self.secondAmount = [self.secondAmount decimalNumberByAdding:self.secondUserSetAmount];
            didExchange = YES;
        }
    } else if (self.secondUserSetAmount && [self.secondAmount compare:self.secondUserSetAmount] != NSOrderedAscending) {
        self.firstAmount = [self.firstAmount decimalNumberByAdding:self.firstUserSetAmount];
        self.secondAmount = [self.secondAmount decimalNumberBySubtracting:self.secondUserSetAmount];
        didExchange = YES;
    }
    if (didExchange) {
        self.amounts[self.firstCurrency] = self.firstAmount;
        self.amounts[self.secondCurrency] = self.secondAmount;
    }
}

- (void)registerObservers {

    @weakify(self)

    RACSignal *ratesUpdatedSignal = [[RACObserve(self, currentRates) distinctUntilChanged] ignore:nil];

    NSNumberFormatter *decimal = self.decimalFormatter;
    NSNumberFormatter *firstFormatter = self.firstCurrencyFormatter;
    NSNumberFormatter *secondFormatter = self.secondCurrencyFormatter;

    RACSignal *directionChanged = RACObserve(self, forwardExchange);

    RACSignal<NSString *> *firstCurrencyChanged = [RACObserve(self, firstCurrency) doNext:^(NSString *_Nullable firstCurrency) {
        firstFormatter.currencyCode = firstCurrency;
    }];
    RACSignal<NSString *> *secondCurrencyChanged = [RACObserve(self, secondCurrency) doNext:^(NSString *_Nullable secondCurrency) {
        secondFormatter.currencyCode = secondCurrency;
    }];
    RAC(self, prevExchangeButtonText) = [firstCurrencyChanged map:^NSString *_Nullable(NSString *_Nullable firstCurrency) {
        @strongify(self)
        return [NSString stringWithFormat:@"◀︎ %@ to %@", self.prevCurrencyCode, firstCurrency];
    }];
    RAC(self, nextExchangeButtonText) = [secondCurrencyChanged map:^NSString *_Nullable(NSString *_Nullable secondCurrency) {
        @strongify(self)
        return [NSString stringWithFormat:@"%@ to %@ ▶︎", secondCurrency, self.nextCurrencyCode];
    }];
    RAC(self, firstAmount) = [firstCurrencyChanged map:^NSDecimalNumber *_Nullable(NSString * _Nullable firstCurrency) {
        @strongify(self)
        return self.amounts[firstCurrency];
    }];
    RAC(self, secondAmount) = [secondCurrencyChanged map:^NSDecimalNumber *_Nullable(NSString * _Nullable secondCurrency) {
        @strongify(self)
        return self.amounts[secondCurrency];
    }];

    RAC(self, exchangeDirectionButtonText) = [directionChanged map:^NSString *_Nonnull(NSNumber *_Nullable isForward) {
        return isForward.boolValue ? @"→" : @"←";
    }];

    [[RACSignal combineLatest:@[ratesUpdatedSignal, firstCurrencyChanged, secondCurrencyChanged]] subscribeNext:^(RACTuple *_Nullable tuple) {
        @strongify(self)
        self.currentExchangeRate = [ViewModel mapBetweenCurrency:self.firstCurrency
                                                     andCurrency:self.secondCurrency
                                                       fromRates:tuple.first];
    }];

    RACSignal *exchangeRateUpdated = [RACObserve(self, currentExchangeRate) ignore:nil];
    RAC(self, exchangeRate) = [[RACSignal combineLatest:@[directionChanged, exchangeRateUpdated]] map:^NSString *_Nullable(RACTuple *_Nullable tuple) {
        NSString *rateStr;
        NSString *oneStr;
        if (((NSNumber *)tuple.first).boolValue) {
            oneStr = [firstFormatter stringFromNumber:NSDecimalNumber.one];
            rateStr = [secondFormatter stringFromNumber:tuple.second];
        } else {
            NSDecimalNumber *rate = [NSDecimalNumber.one decimalNumberByDividingBy:tuple.second];
            oneStr = [secondFormatter stringFromNumber:NSDecimalNumber.one];
            rateStr = [firstFormatter stringFromNumber:rate];
        }
        return [NSString stringWithFormat:@"%@ = %@", oneStr, rateStr];
    }];

    RACSignal *firstUserSetAmountSignal = RACObserve(self, firstUserSetAmount);
    RAC(self, firstCurrencyUserSetAmount) = [firstUserSetAmountSignal map:^NSString *_Nullable(NSDecimalNumber *_Nullable first) {
        return [decimal stringFromNumber:first];
    }];
    RACSignal *secondUserSetAmountSignal = RACObserve(self, secondUserSetAmount);
    RAC(self, secondCurrencyUserSetAmount) = [secondUserSetAmountSignal map:^NSString *_Nullable(NSDecimalNumber *_Nullable second) {
        return [decimal stringFromNumber:second];
    }];

    RACSignal *updateSecondUserSetAmountSignal = [RACSignal combineLatest:@[firstUserSetAmountSignal, exchangeRateUpdated, directionChanged]];
    [updateSecondUserSetAmountSignal subscribeNext:^(RACTwoTuple *_Nullable tuple) {
        @strongify(self)
        if (self.forwardExchange) {
            // Update only when second text field is not the user-edited side
            self.secondUserSetAmount = [tuple.first decimalNumberByMultiplyingBy:tuple.second];
        }
    }];

    RACSignal *updateFirstUserSetAmountSignal = [RACSignal combineLatest:@[secondUserSetAmountSignal, exchangeRateUpdated, directionChanged]];
    [updateFirstUserSetAmountSignal subscribeNext:^(RACTwoTuple *_Nullable tuple) {
        @strongify(self)
        if (!self.forwardExchange) {
            // Update amount only when first text field is not the user-edited side
            NSDecimalNumber *exchangeRate = [NSDecimalNumber.one decimalNumberByDividingBy:tuple.second];
            self.firstUserSetAmount = [tuple.first decimalNumberByMultiplyingBy:exchangeRate];
        }
    }];

    RACSignal<NSDecimalNumber *> *firstAmountSignal = RACObserve(self, firstAmount);
    RAC(self, firstCurrencyAmount) = [firstAmountSignal map:^NSString *_Nullable(NSDecimalNumber *_Nullable first) {
        return [firstFormatter stringFromNumber:first];
    }];
    RACSignal<NSDecimalNumber *> *secondAmountSignal = RACObserve(self, secondAmount);
    RAC(self, secondCurrencyAmount) = [secondAmountSignal map:^NSString *_Nullable(NSDecimalNumber *_Nullable second) {
        return [secondFormatter stringFromNumber:second];
    }];

    self.firstAmountEnoughSignal = [[RACSignal combineLatest:@[RACObserve(self, firstAmount), RACObserve(self, firstUserSetAmount), directionChanged]] map:^NSNumber *_Nullable(RACTuple *_Nullable tuple) {
        @strongify(self)
        if (self.forwardExchange) {
            // Check only when first text field is the user-edited side
            return @([(NSDecimalNumber *)tuple.first compare:(NSDecimalNumber *)tuple.second] != NSOrderedAscending);
        }
        return @(YES);
    }];
    self.secondAmountEnoughSignal = [[RACSignal combineLatest:@[RACObserve(self, secondAmount), RACObserve(self, secondUserSetAmount), directionChanged]] map:^NSNumber *_Nullable(RACTuple *_Nullable tuple) {
        @strongify(self)
        if (!self.forwardExchange) {
            // Check only when second text field is the user-edited side
            return @([(NSDecimalNumber *)tuple.first compare:(NSDecimalNumber *)tuple.second] != NSOrderedAscending);
        }
        return @(YES);
    }];
}

/// Second currency code index (from `self.currencyCodes`) for next page.
/// The first will be current page's second currency code.
- (NSInteger)nextCurrencyCodeIndex {
    if (self.targetCurrencyIndex + 1 >= self.currencyCodes.count) {
        return 0;
    } else {
        return self.targetCurrencyIndex + 1;
    }
}
/// First currency code index (from `self.currencyCodes`) for previous page.
/// The second will be current page's first currency code.
- (NSInteger)prevCurrencyCodeIndex {
    if (self.sourceCurrencyIndex - 1 >= 0) {
        return self.sourceCurrencyIndex - 1;
    } else {
        return self.currencyCodes.count - 1;
    }
}
/// First currency code for previous page.
- (NSString *)prevCurrencyCode {
    return self.currencyCodes[self.prevCurrencyCodeIndex];
}
/// Second currency code index for next page.
- (NSString *)nextCurrencyCode {
    return self.currencyCodes[self.nextCurrencyCodeIndex];
}

- (void)goToPrevCurrenciesPair {
    self.secondCurrency = self.firstCurrency;
    NSString *firstCurrency = [self prevCurrencyCode];
    self.sourceCurrencyIndex = [self prevCurrencyCodeIndex];
    self.targetCurrencyIndex = self.sourceCurrencyIndex + 1;
    if (self.targetCurrencyIndex >= self.currencyCodes.count) {
        self.targetCurrencyIndex = 0;
    }
    self.firstCurrency = firstCurrency;
}
- (void)goToNextCurrenciesPair {
    self.firstCurrency = self.secondCurrency;
    NSString *secondCurrency = [self nextCurrencyCode];
    self.targetCurrencyIndex = [self nextCurrencyCodeIndex];
    self.sourceCurrencyIndex = self.targetCurrencyIndex - 1;
    if (self.sourceCurrencyIndex < 0) {
        self.sourceCurrencyIndex = self.currencyCodes.count - 1;
    }
    self.secondCurrency = secondCurrency;
}

- (void)switchDirection {
    self.forwardExchange = !self.forwardExchange;
}

- (void)updateSecondAmountWithFirstAmountString:(NSString *_Nonnull)firstAmountStr {
    NSString *filteredStr = [self filterOnlyNumbers:firstAmountStr];
    if (![filteredStr isEqualToString:firstAmountStr]) {
        self.firstCurrencyUserSetAmount = filteredStr;
    }
    NSDecimalNumber *firstAmount = (NSDecimalNumber *)[self.decimalFormatter numberFromString:filteredStr];
    if (![self.firstUserSetAmount isEqualToNumber:firstAmount]) {
        self.firstUserSetAmount = firstAmount;
    }
}
- (void)updateFirstAmountWithSecondAmountString:(NSString *_Nonnull)secondAmountStr {
    NSString *filteredStr = [self filterOnlyNumbers:secondAmountStr];
    if (![filteredStr isEqualToString:secondAmountStr]) {
        self.secondCurrencyUserSetAmount = filteredStr;
    }
    NSDecimalNumber *secondAmount = (NSDecimalNumber *)[self.decimalFormatter numberFromString:filteredStr];
    if (![self.secondUserSetAmount isEqualToNumber:secondAmount]) {
        self.secondUserSetAmount = secondAmount;
    }
}
/// Modifies a string by removing all characters that are not meant to be in a number
- (NSString *_Nonnull)filterOnlyNumbers:(NSString *_Nonnull)source {
    NSMutableCharacterSet *set = [[NSCharacterSet decimalDigitCharacterSet] mutableCopy];
    [set addCharactersInString:[self.decimalFormatter decimalSeparator]];
    NSRange nonNumberRange = [source rangeOfCharacterFromSet:[set invertedSet]];
    if (nonNumberRange.location == NSNotFound) {
        return source;
    }
    return [source stringByReplacingOccurrencesOfString:[source substringWithRange:nonNumberRange] withString:@""];
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
    // First goes right now, then every 30 seconds.
    RACSignal<NSDate *> *signal = [RACSignal merge:
        @[[RACSignal return:[NSDate date]],
          [RACSignal interval:30.0 onScheduler:[RACScheduler mainThreadScheduler]]]];
    self.disposable = [[[signal flattenMap:^RACSignal<CEACurrexRates *> *_Nullable(NSDate *_Nullable dateValue) {
        @strongify(self)
        return [self.api fetchExchangeRates];
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(CEACurrexRates *_Nullable rates) {
        @strongify(self)
        self.currentRates = rates;
    }];
}
- (void)stopFetchingRates {
    [self.disposable dispose];
    self.disposable = nil;
}

#pragma mark - Initial configuration
- (void)configureNumberFormatters {
    self.firstCurrencyFormatter = [[NSNumberFormatter alloc] init];
    self.firstCurrencyFormatter.generatesDecimalNumbers = YES;
    self.firstCurrencyFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    self.firstCurrencyFormatter.minimumFractionDigits = 0;
    self.firstCurrencyFormatter.maximumFractionDigits = 4;

    self.secondCurrencyFormatter = [self.firstCurrencyFormatter copy];

    self.decimalFormatter = [[NSNumberFormatter alloc] init];
    self.decimalFormatter.generatesDecimalNumbers = YES;
    self.decimalFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.decimalFormatter.usesGroupingSeparator = NO;
    self.decimalFormatter.minimumFractionDigits = 0;
    self.decimalFormatter.maximumFractionDigits = 4;
}

@end
