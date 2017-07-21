//
//  CEACurrexAPI.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

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

- (void)fetchExchangeRatesWithCallback:(void (^)(CEACurrexRates * _Nullable, NSError * _Nullable))callback {
    NSURL *url = [NSURL URLWithString:@"http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"];
    [self.network fetchFileWithURL:url callback:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (data) {
            CEACurrexRatesParserDelegate *parserDelegate = [[CEACurrexRatesParserDelegate alloc] init];

            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
            parser.delegate = parserDelegate;
            parser.shouldProcessNamespaces = NO;
            parser.shouldReportNamespacePrefixes = NO;
            parser.shouldResolveExternalEntities = NO;

            if ([parser parse]) {
                callback(parserDelegate.rates, nil);
            } else {
                callback(nil, parser.parserError);
            }
        } else {
            callback(nil, error);
        }
    }];
}

@end
