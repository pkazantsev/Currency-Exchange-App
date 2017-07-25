//
//  ViewModel_Tests.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/22/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import XCTest;
@import ReactiveObjC;

#import "CEANetwork.h"
#import "CEACurrexAPI.h"
#import "CEACurrexRates.h"
#import "ViewModel.h"

#import "CEATestHelper.h"

@interface ViewModel_Tests : XCTestCase

@property (strong, nonatomic, nullable) id <CEANetwork> network;
@property (strong, nonatomic, nullable) CEACurrexAPI *api;
@property (strong, nonatomic, nullable) ViewModel *viewModel;

@end

@interface ViewModel (Private)

@property (strong, nonatomic, nullable, readwrite) CEACurrexRates *currentRates;

@end

@implementation ViewModel_Tests

- (void)setUp {
    [super setUp];

    self.network = [[NetworkStub alloc] initWithTestFileName:@"exchange_rates_1"];
    self.api = [[CEACurrexAPI alloc] initWithNetwork:self.network];

    self.viewModel = [[ViewModel alloc] initWithApi:self.api];

    [self.viewModel populateWithData];
    [self.viewModel startFetchingRates];
}

- (void)tearDown {
    [self.viewModel stopFetchingRates];
    self.viewModel = nil;
    self.api = nil;
    self.network = nil;

    [super tearDown];
}

- (void)testStartFetchingRates {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Rates should update after 'startFetchingRates' method is called"];
    XCTAssertEqualObjects(self.viewModel.firstCurrency, @"EUR");
    XCTAssertEqualObjects(self.viewModel.secondCurrency, @"USD");
    [[RACObserve(self.viewModel, exchangeRate) ignore:nil] subscribeNext:^(NSString *_Nullable exchangeRate) {
        [expectation fulfill];
        XCTAssertEqualObjects(exchangeRate, @"€1 = $1.1485");
    }];
    [self.viewModel startFetchingRates];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testConversionRateNoReturnValueNotSet {
    [[RACObserve(self.viewModel, exchangeRate) ignore:nil] subscribeNext:^(NSString *_Nullable exchangeRate) {
        XCTFail(@"Should not return value before first value comes");
    }];
}
- (void)testConversionRateFromUsdToEur {
    CEACurrexRates *rates = [[CEACurrexRates alloc] initWithRates:@{@"USD": [NSDecimalNumber decimalNumberWithString:@"1.23"]} onDate:[NSDate date]];
    NSDecimalNumber *rate = [ViewModel mapBetweenCurrency:@"USD" andCurrency:@"EUR" fromRates:rates];

    NSDecimalNumber *expected = [NSDecimalNumber decimalNumberWithString:@"0.813"];
    XCTAssertEqualObjects(expected, [rate decimalNumberByRoundingAccordingToBehavior:[CEATestHelper decimalNumberBehaviors]]);
}
- (void)testConversionRateFromEurToUsd {
    CEACurrexRates *rates = [[CEACurrexRates alloc] initWithRates:@{@"USD": [NSDecimalNumber decimalNumberWithString:@"1.23"]} onDate:[NSDate date]];
    NSDecimalNumber *rate = [ViewModel mapBetweenCurrency:@"EUR" andCurrency:@"USD" fromRates:rates];

    NSDecimalNumber *expected = [NSDecimalNumber decimalNumberWithString:@"1.23"];
    XCTAssertEqualObjects(expected, [rate decimalNumberByRoundingAccordingToBehavior:[CEATestHelper decimalNumberBehaviors]]);
}
- (void)testConversionRateFromEurToEur {
    CEACurrexRates *rates = [[CEACurrexRates alloc] initWithRates:@{} onDate:[NSDate date]];
    NSDecimalNumber *rate = [ViewModel mapBetweenCurrency:@"EUR" andCurrency:@"EUR" fromRates:rates];

    XCTAssertEqualObjects(nil, rate);
}
- (void)testConversionRateFromUsdToGbp {
    CEACurrexRates *rates = [[CEACurrexRates alloc] initWithRates:@{@"USD": [NSDecimalNumber decimalNumberWithString:@"1.1642"],
                                                                    @"GBP": [NSDecimalNumber decimalNumberWithString:@"0.8961"]}
                                                           onDate:[NSDate date]];
    NSDecimalNumber *rate = [ViewModel mapBetweenCurrency:@"USD" andCurrency:@"GBP" fromRates:rates];

    NSDecimalNumber *expected = [NSDecimalNumber decimalNumberWithString:@"0.77"];
    XCTAssertEqualObjects(expected, [rate decimalNumberByRoundingAccordingToBehavior:[CEATestHelper decimalNumberBehaviors]]);
}

@end
