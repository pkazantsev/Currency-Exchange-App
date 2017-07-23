//
//  CEANetwork.h
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import Foundation;

@class RACSignal<__covariant ValueType>;

@protocol CEANetwork <NSObject>

/// Fetches data from a given URL
- (RACSignal<NSData *> *_Nonnull)fetchFileWithURL:(NSURL *_Nonnull)url;

@end

@interface CEANetworkImpl: NSObject <CEANetwork>

@end
