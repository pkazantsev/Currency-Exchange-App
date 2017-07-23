//
//  CEACurrexRatesParserDelegate.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

#import "CEACurrexRatesParserDelegate.h"

#import "CEACurrexRates.h"

@interface CEACurrexRatesParserDelegate()

@property (strong, nonatomic, nonnull) NSDateFormatter *dateParser;
@property (strong, nonatomic, nonnull) NSNumberFormatter *numParser;
@property (strong, nonatomic, nullable) NSDate *ratesDate;
@property (strong, nonatomic, nonnull) NSMutableDictionary <NSString *, NSDecimalNumber *> *ratesDict;

@end

@implementation CEACurrexRatesParserDelegate

- (instancetype)init {
    self = [super init];

    self.dateParser = [[NSDateFormatter alloc] init];
    self.dateParser.dateFormat = @"yyyy-MM-dd";

    self.numParser = [[NSNumberFormatter alloc] init];
    self.numParser.generatesDecimalNumbers = YES;

    self.ratesDict = [[NSMutableDictionary alloc] init];

    return self;
}

- (CEACurrexRates *)rates {
    if (!self.ratesDate || self.ratesDict.count == 0) {
        return nil;
    }
    return [[CEACurrexRates alloc] initWithRates:self.ratesDict onDate:self.ratesDate];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if (![elementName isEqualToString:@"Cube"]) {
        return;
    }
    if (attributeDict.count == 0) {
        return;
    }
    NSString *time = attributeDict[@"time"];
    if (time) {
        self.ratesDate = [self.dateParser dateFromString:time];
        return;
    }

    NSString *currency = attributeDict[@"currency"];
    NSString *rateStr = attributeDict[@"rate"];
    if (!(currency && rateStr)) {
        return;
    }
    NSDecimalNumber *rate = (NSDecimalNumber *)[self.numParser numberFromString:rateStr];
    if (rate) {
        self.ratesDict[currency] = rate;
    }
}


@end
