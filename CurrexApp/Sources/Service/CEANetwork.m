//
//  CEANetwork.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

#import "CEANetwork.h"

@implementation CEANetworkImpl

- (void)fetchFileWithURL:(NSURL *_Nonnull)url callback:(void(^_Nonnull)(NSData *_Nullable data, NSError *_Nullable error))callback {
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        callback(data, error);
    }];
    [task resume];
}

@end
