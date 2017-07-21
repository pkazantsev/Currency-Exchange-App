//
//  CEACurrexAPI.h
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import Foundation;

@protocol CEANetwork;
@class CEACurrexRates;

@interface CEACurrexAPI : NSObject

- (nonnull instancetype)initWithNetwork:(nonnull id <CEANetwork>)network;

- (void)fetchExchangeRatesWithCallback:(void(^_Nonnull)(CEACurrexRates *_Nullable data, NSError *_Nullable error))callback;

@end
