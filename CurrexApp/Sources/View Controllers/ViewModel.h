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

@interface ViewModel : NSObject

- (nonnull instancetype)initWithApi:(CEACurrexAPI *_Nonnull)api;

- (void)startFetchingRates;
- (void)stopFetchingRates;

/// Returns a conversion rate every time it's updated
- (RACSignal<NSDecimalNumber *> *_Nonnull)conversionRateFrom:(NSString *_Nonnull)currCurrency
                                                          to:(NSString *_Nonnull)targetCurrency;

+ (NSDecimalNumber *_Nullable)mapBetweenCurrency:(NSString *_Nonnull)src
                                     andCurrency:(NSString *_Nonnull)dst
                                       fromRates:(CEACurrexRates *_Nonnull)rates;

@end
