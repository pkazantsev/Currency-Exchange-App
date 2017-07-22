//
//  CEACurrexAPI_Tests.m
//  CurrexAppTests
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import XCTest;
@import ReactiveObjC;

#import "CEANetwork.h"
#import "CEACurrexAPI.h"
#import "CEACurrexRates.h"

#import "CEATestHelper.h"

@interface CEACurrexAPI_Tests : XCTestCase

@property (strong, nonatomic, nullable) id <CEANetwork> network;
@property (strong, nonatomic, nullable) CEACurrexAPI *api;

@end

@implementation CEACurrexAPI_Tests

- (void)setUp {
    [super setUp];

    self.network = [[NetworkStub alloc] initWithTestFileName:@"exchange_rates_1"];
    self.api = [[CEACurrexAPI alloc] initWithNetwork:self.network];

    self.continueAfterFailure = NO;
}

- (void)tearDown {
    self.api = nil;
    self.network = nil;

    [super tearDown];
}

- (void)testFetchExchangeRates {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fetch should call the callback"];

    [[self.api fetchExchangeRates] subscribeNext:^(CEACurrexRates *_Nullable rates) {
        [expectation fulfill];

        XCTAssertNotNil(rates);
        XCTAssertNotNil(rates.rates);
        XCTAssertEqual(rates.rates.count, 31);

        NSDecimalNumber *usdRate = rates.rates[@"USD"];
        XCTAssertNotNil(usdRate);
        XCTAssertEqualObjects(usdRate, [NSDecimalNumber decimalNumberWithString:@"1.1485"]);

        NSDecimalNumber *gbpRate = rates.rates[@"GBP"];
        XCTAssertNotNil(gbpRate);
        XCTAssertEqualObjects(gbpRate, [NSDecimalNumber decimalNumberWithString:@"0.88718"]);
    } error:^(NSError * _Nullable error) {
        XCTFail(@"Rates fetching error: %@", error);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

@end

