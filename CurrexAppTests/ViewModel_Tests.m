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
}

- (void)tearDown {
    self.viewModel = nil;
    self.api = nil;
    self.network = nil;

    [super tearDown];
}

- (void)testStartFetchingRates {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Rates should update after 'startFetchingRates' method is called"];
    [[self.viewModel conversionRateFrom:@"EUR" to:@"USD"] subscribeNext:^(NSDecimalNumber *_Nonnull rate) {
        [expectation fulfill];

        NSDecimalNumber *expected = [NSDecimalNumber decimalNumberWithString:@"1.1485"];
        XCTAssertEqualObjects(expected, rate);
    }];
    [self.viewModel startFetchingRates];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testConversionRateNoReturnValueNotSet {
    [[self.viewModel conversionRateFrom:@"USD" to:@"EUR"] subscribeNext:^(NSDecimalNumber *_Nullable rate) {
        XCTFail(@"Should not return value before first value comes");
    }];
}
- (void)testConversionRateFromUsdToEurSubscribeBeforeValueSet {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Conversion is done on rates update"];

    [[self.viewModel conversionRateFrom:@"USD" to:@"EUR"] subscribeNext:^(NSDecimalNumber *_Nonnull rate) {
        [expectation fulfill];

        NSDecimalNumber *expected = [NSDecimalNumber decimalNumberWithString:@"0.813"];
        XCTAssertEqualObjects(expected, [rate decimalNumberByRoundingAccordingToBehavior:[CEATestHelper decimalNumberBehaviors]]);
    }];
    self.viewModel.currentRates = [[CEACurrexRates alloc] initWithRates:@{@"USD": [NSDecimalNumber decimalNumberWithString:@"1.23"]} onDate:[NSDate date]];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}
- (void)testConversionRateFromUsdToEurSubscribeAfterValueSet {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Conversion is done on rates update"];

    self.viewModel.currentRates = [[CEACurrexRates alloc] initWithRates:@{@"USD": [NSDecimalNumber decimalNumberWithString:@"1.23"]} onDate:[NSDate date]];

    [[self.viewModel conversionRateFrom:@"USD" to:@"EUR"] subscribeNext:^(NSDecimalNumber *_Nonnull rate) {
        [expectation fulfill];

        NSDecimalNumber *expected = [NSDecimalNumber decimalNumberWithString:@"0.813"];
        XCTAssertEqualObjects(expected, [rate decimalNumberByRoundingAccordingToBehavior:[CEATestHelper decimalNumberBehaviors]]);
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}
- (void)testConversionRateFromEurToUsd {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Conversion is done on rates update"];

    self.viewModel.currentRates = [[CEACurrexRates alloc] initWithRates:@{@"USD": [NSDecimalNumber decimalNumberWithString:@"1.23"]} onDate:[NSDate date]];

    [[self.viewModel conversionRateFrom:@"EUR" to:@"USD"] subscribeNext:^(NSDecimalNumber *_Nonnull rate) {
        [expectation fulfill];

        NSDecimalNumber *expected = [NSDecimalNumber decimalNumberWithString:@"1.23"];
        XCTAssertEqualObjects(expected, rate);
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}
- (void)testConversionRateFromEurToEur {
    self.viewModel.currentRates = [[CEACurrexRates alloc] initWithRates:@{} onDate:[NSDate date]];

    [[self.viewModel conversionRateFrom:@"EUR" to:@"EUR"] subscribeNext:^(NSDecimalNumber *_Nonnull rate) {
        XCTFail(@"Should not return value for EUR-to-EUR conversion");
    }];
}
- (void)testConversionRateFromUsdToGbp {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Conversion is done on rates update"];

    [[self.viewModel conversionRateFrom:@"USD" to:@"GBP"] subscribeNext:^(NSDecimalNumber *_Nonnull rate) {
        [expectation fulfill];

        NSDecimalNumber *expected = [NSDecimalNumber decimalNumberWithString:@"0.77"];
        XCTAssertEqualObjects(expected, [rate decimalNumberByRoundingAccordingToBehavior:[CEATestHelper decimalNumberBehaviors]]);
    }];
    self.viewModel.currentRates = [[CEACurrexRates alloc] initWithRates:@{@"USD": [NSDecimalNumber decimalNumberWithString:@"1.1642"],
                                                                          @"GBP": [NSDecimalNumber decimalNumberWithString:@"0.8961"]}
                                                                 onDate:[NSDate date]];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

@end
