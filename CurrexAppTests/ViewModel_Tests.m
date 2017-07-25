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

- (void)testConversionRateStrForwards {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Rates should update after 'startFetchingRates' method is called"];
    XCTAssertEqualObjects(self.viewModel.firstCurrency, @"EUR");
    XCTAssertEqualObjects(self.viewModel.secondCurrency, @"USD");
    [[RACObserve(self.viewModel, exchangeRate) ignore:nil] subscribeNext:^(NSString *_Nullable exchangeRate) {
        XCTAssertEqualObjects(exchangeRate, @"€1 = $1.1485");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}
- (void)testConversionRateStrBackwards {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Rates should update after 'startFetchingRates' method is called"];
    XCTAssertEqualObjects(self.viewModel.firstCurrency, @"EUR");
    XCTAssertEqualObjects(self.viewModel.secondCurrency, @"USD");
    [self.viewModel switchDirection];

    [[RACObserve(self.viewModel, exchangeRate) ignore:nil] subscribeNext:^(NSString *_Nullable exchangeRate) {
        XCTAssertEqualObjects(exchangeRate, @"$1 = €0.8707");
        [expectation fulfill];
    }];

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

- (void)testInitialUserSetAmount {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Rates should update after 'startFetchingRates' method is called"];

    XCTAssertEqualObjects(self.viewModel.firstCurrency, @"EUR");
    XCTAssertEqualObjects(self.viewModel.secondCurrency, @"USD");

    [[RACObserve(self.viewModel, exchangeRate) skip:1] subscribeNext:^(NSString *_Nullable exchangeRate) {
        XCTAssertEqualObjects(self.viewModel.firstCurrencyUserSetAmount, @"100");
        XCTAssertEqualObjects(self.viewModel.secondCurrencyUserSetAmount, @"114.85");

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testUserSetSecondAmountUpdatedAfterChangingFirstTextFieldForwards {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Rates should update after 'startFetchingRates' method is called"];

    XCTAssertEqualObjects(self.viewModel.firstCurrency, @"EUR");
    XCTAssertEqualObjects(self.viewModel.secondCurrency, @"USD");

    [[RACObserve(self.viewModel, exchangeRate) ignore:nil] subscribeNext:^(NSString *_Nullable exchangeRate) {
        XCTAssertEqualObjects(self.viewModel.firstCurrencyUserSetAmount, @"100");

        RACSignal<RACTuple *> *signal = [RACSignal combineLatest:@[[RACObserve(self.viewModel, firstCurrencyUserSetAmount) skip:1],
                                                                   [RACObserve(self.viewModel, secondCurrencyUserSetAmount) skip:1]]];
        [signal subscribeNext:^(RACTuple *_Nullable tuple) {
            XCTAssertEqualObjects(tuple.first, @"90");
            XCTAssertEqualObjects(tuple.second, @"103.365");

            [expectation fulfill];
        }];
        [self.viewModel updateSecondAmountWithFirstAmountString:@"90"];
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}
- (void)testUserSetSecondAmountUpdatedAfterChangingFirstTextFieldBackwards {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Rates should update after 'startFetchingRates' method is called"];

    XCTAssertEqualObjects(self.viewModel.firstCurrency, @"EUR");
    XCTAssertEqualObjects(self.viewModel.secondCurrency, @"USD");
    [self.viewModel switchDirection];

    [[RACObserve(self.viewModel, exchangeRate) ignore:nil] subscribeNext:^(NSString *_Nullable exchangeRate) {
        XCTAssertEqualObjects(self.viewModel.firstCurrencyUserSetAmount, @"100");

        RACSignal<RACTuple *> *signal = [RACSignal combineLatest:@[[RACObserve(self.viewModel, firstCurrencyUserSetAmount) skip:1],
                                                                   [RACObserve(self.viewModel, secondCurrencyUserSetAmount) skip:1]]];
        [signal subscribeNext:^(RACTuple *_Nullable tuple) {
            XCTAssertEqualObjects(tuple.first, @"90");
            XCTAssertEqualObjects(tuple.second, @"103.365");

            [expectation fulfill];
        }];
        [self.viewModel updateSecondAmountWithFirstAmountString:@"90"];
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}
- (void)testUserSetFirstAmountUpdatedAfterChangingSecondTextFieldForwards {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Rates should update after 'startFetchingRates' method is called"];

    XCTAssertEqualObjects(self.viewModel.firstCurrency, @"EUR");
    XCTAssertEqualObjects(self.viewModel.secondCurrency, @"USD");

    [[RACObserve(self.viewModel, exchangeRate) ignore:nil] subscribeNext:^(NSString *_Nullable exchangeRate) {
        XCTAssertEqualObjects(self.viewModel.firstCurrencyUserSetAmount, @"100");

        RACSignal<RACTuple *> *signal = [RACSignal combineLatest:@[[RACObserve(self.viewModel, firstCurrencyUserSetAmount) skip:1],
                                                                   [RACObserve(self.viewModel, secondCurrencyUserSetAmount) skip:1]]];
        [signal subscribeNext:^(RACTuple *_Nullable tuple) {
            XCTAssertEqualObjects(tuple.first, @"78.3631");
            XCTAssertEqualObjects(tuple.second, @"90");

            [expectation fulfill];
        }];
        [self.viewModel updateFirstAmountWithSecondAmountString:@"90"];
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}
- (void)testUserSetFirstAmountUpdatedAfterChangingSecondTextFieldBackwards {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Rates should update after 'startFetchingRates' method is called"];

    XCTAssertEqualObjects(self.viewModel.firstCurrency, @"EUR");
    XCTAssertEqualObjects(self.viewModel.secondCurrency, @"USD");
    [self.viewModel switchDirection];

    [[RACObserve(self.viewModel, exchangeRate) ignore:nil] subscribeNext:^(NSString *_Nullable exchangeRate) {
        XCTAssertEqualObjects(self.viewModel.firstCurrencyUserSetAmount, @"100");

        RACSignal<RACTuple *> *signal = [RACSignal combineLatest:@[[RACObserve(self.viewModel, firstCurrencyUserSetAmount) skip:1],
                                                                   [RACObserve(self.viewModel, secondCurrencyUserSetAmount) skip:1]]];
        [signal subscribeNext:^(RACTuple *_Nullable tuple) {
            XCTAssertEqualObjects(tuple.first, @"78.3631");
            XCTAssertEqualObjects(tuple.second, @"90");

            [expectation fulfill];
        }];
        [self.viewModel updateFirstAmountWithSecondAmountString:@"90"];
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

- (void)testExchangeForward {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Rates should update after 'startFetchingRates' method is called"];

    XCTAssertEqualObjects(self.viewModel.firstCurrency, @"EUR");
    XCTAssertEqualObjects(self.viewModel.secondCurrency, @"USD");

    [[RACObserve(self.viewModel, exchangeRate) ignore:nil] subscribeNext:^(NSString *_Nullable exchangeRate) {
        XCTAssertEqualObjects(self.viewModel.firstCurrencyAmount, @"€100");
        XCTAssertEqualObjects(self.viewModel.secondCurrencyAmount, @"$100");
        NSLog(@"Rate: %@", exchangeRate);
        RACSignal<RACTuple *> *signal = [RACSignal combineLatest:@[[RACObserve(self.viewModel, firstCurrencyAmount) ignore:@"€100"],
                                                                   [RACObserve(self.viewModel, secondCurrencyAmount) ignore:@"$100"]]];
        [signal subscribeNext:^(RACTuple *_Nullable tuple) {
            XCTAssertEqualObjects(tuple.first, @"€70");
            XCTAssertEqualObjects(tuple.second, @"$134.455");

            [expectation fulfill];
        }];

        [self.viewModel updateSecondAmountWithFirstAmountString:@"30"];
        [self.viewModel exchange];
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}
- (void)testExchangeBackwards {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Rates should update after 'startFetchingRates' method is called"];

    XCTAssertEqualObjects(self.viewModel.firstCurrency, @"EUR");
    XCTAssertEqualObjects(self.viewModel.secondCurrency, @"USD");
    [self.viewModel switchDirection];

    [[RACObserve(self.viewModel, exchangeRate) ignore:nil] subscribeNext:^(NSString *_Nullable exchangeRate) {
        XCTAssertEqualObjects(self.viewModel.firstCurrencyAmount, @"€100");
        XCTAssertEqualObjects(self.viewModel.secondCurrencyAmount, @"$100");

        NSLog(@"Rate: %@", exchangeRate);
        RACSignal<RACTuple *> *signal = [RACSignal combineLatest:@[[RACObserve(self.viewModel, firstCurrencyAmount) ignore:@"€100"],
                                                                   [RACObserve(self.viewModel, secondCurrencyAmount) ignore:@"$100"]]];
        [signal subscribeNext:^(RACTuple *_Nullable tuple) {
            XCTAssertEqualObjects(tuple.first, @"€130");
            XCTAssertEqualObjects(tuple.second, @"$65.545");

            [expectation fulfill];
        }];

        [self.viewModel updateSecondAmountWithFirstAmountString:@"30"];
        [self.viewModel exchange];
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

@end
