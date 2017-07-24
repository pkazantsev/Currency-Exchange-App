//
//  ViewModel.h
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/22/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import Foundation;
@import ReactiveObjC;

@class CEACurrexAPI;
@class CEACurrexRates;
@class RACSignal<__covariant ValueType>;

@interface ViewModel : NSObject

@property (strong, nonatomic, nonnull, readonly) NSString *firstCurrency;
@property (strong, nonatomic, nonnull, readonly) NSString *secondCurrency;
@property (strong, nonatomic, nonnull, readonly) NSString *exchangeRate;

@property (strong, nonatomic, nonnull, readonly) NSString *firstCurrencyAmount;
@property (strong, nonatomic, nonnull, readonly) NSString *secondCurrencyAmount;

@property (strong, nonatomic, nonnull, readonly) NSString *prevExchangeButtonText;
@property (strong, nonatomic, nonnull, readonly) NSString *nextExchangeButtonText;

@property (strong, nonatomic, nonnull, readonly) NSString *firstCurrencyUserSetAmount;
@property (strong, nonatomic, nonnull, readonly) NSString *secondCurrencyUserSetAmount;

@property (strong, nonatomic, nonnull, readonly) NSString *exchangeDirectionButtonText;
/// Indicates if amount user entered is enough for exchange
@property (strong, nonatomic, nonnull, readonly) RACSignal<NSNumber *> *firstAmountEnoughSignal;
@property (strong, nonatomic, nonnull, readonly) RACSignal<NSNumber *> *secondAmountEnoughSignal;

/// If exchange is from the first currency to the second, or reverse if NO;
@property (nonatomic, readonly) BOOL forwardExchange;

- (nonnull instancetype)initWithApi:(CEACurrexAPI *_Nonnull)api;

- (void)startFetchingRates;
- (void)stopFetchingRates;

- (void)populateWithData;

- (void)updateSecondAmountWithFirstAmountString:(NSString *_Nonnull)firstAmount;
- (void)updateFirstAmountWithSecondAmountString:(NSString *_Nonnull)secondAmount;

- (void)switchDirection;

- (void)exchange;

- (void)goToPrevCurrenciesPair;
- (void)goToNextCurrenciesPair;

+ (NSDecimalNumber *_Nullable)mapBetweenCurrency:(NSString *_Nonnull)src
                                     andCurrency:(NSString *_Nonnull)dst
                                       fromRates:(CEACurrexRates *_Nonnull)rates;

@end
