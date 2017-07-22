//
//  CEACurrexAPI.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import ReactiveObjC;

#import "CEANetwork.h"
#import "CEACurrexAPI.h"
#import "CEACurrexRates.h"
#import "CEACurrexRatesParserDelegate.h"

@interface CEACurrexAPI ()

@property (strong, nonatomic, nonnull) id <CEANetwork> network;

@end

@implementation CEACurrexAPI

- (instancetype)initWithNetwork:(id <CEANetwork>)network {
    self = [super init];

    self.network = network;

    return self;
}

- (RACSignal<CEACurrexRates *> *)fetchExchangeRates {
    NSURL *url = [NSURL URLWithString:@"http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"];
    RACSignal<NSData *> *dataSignal = [self.network fetchFileWithURL:url];
    return [dataSignal tryMap:^CEACurrexRates *_Nullable(NSData *_Nullable data, NSError * _Nullable __autoreleasing * _Nullable errorPtr) {
        CEACurrexRatesParserDelegate *parserDelegate = [[CEACurrexRatesParserDelegate alloc] init];

        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        parser.delegate = parserDelegate;
        parser.shouldProcessNamespaces = NO;
        parser.shouldReportNamespacePrefixes = NO;
        parser.shouldResolveExternalEntities = NO;

        if ([parser parse]) {
            return parserDelegate.rates;
        } else {
            *errorPtr = parser.parserError;
            return nil;
        }
    }];
}

@end
