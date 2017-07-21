//
//  CEANetwork.h
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import Foundation;

@protocol CEANetwork <NSObject>

/// Fetches data from a given URL
- (void)fetchFileWithURL:(NSURL *_Nonnull)url callback:(void(^_Nonnull)(NSData *_Nullable data, NSError *_Nullable error))callback;

@end

@interface CEANetworkImpl: NSObject <CEANetwork>

@end
