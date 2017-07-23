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
@class RACSignal<__covariant ValueType>;

@interface CEACurrexAPI : NSObject

- (nonnull instancetype)initWithNetwork:(nonnull id <CEANetwork>)network;

- (RACSignal<CEACurrexRates *> *_Nonnull)fetchExchangeRates;

@end
