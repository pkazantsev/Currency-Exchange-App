//
//  CEANetwork.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import ReactiveObjC;

#import "CEANetwork.h"

@implementation CEANetworkImpl

- (RACSignal<NSData *> *)fetchFileWithURL:(NSURL *_Nonnull)url {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *_Nullable(id<RACSubscriber> _Nonnull subscriber) {
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            if (error) {
                [subscriber sendError:error];
            } else if (!data) {
                [subscriber sendError:nil];
            } else {
                [subscriber sendNext:data];
            }
        }];
        [task resume];

        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
    return signal;
}

@end
