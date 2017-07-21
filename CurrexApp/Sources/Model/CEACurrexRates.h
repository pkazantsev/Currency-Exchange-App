//
//  CEACurrexRates.h
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import Foundation;

@interface CEACurrexRates : NSObject

@property (strong, nonatomic, nonnull, readonly) NSDate *ratesDate;
@property (strong, nonatomic, nonnull, readonly) NSDictionary <NSString *, NSDecimalNumber *> *rates;

- (nonnull instancetype)initWithRates:(NSDictionary <NSString *, NSDecimalNumber *> *_Nonnull)rates
                               onDate:(NSDate *_Nonnull)ratesDate;

@end
