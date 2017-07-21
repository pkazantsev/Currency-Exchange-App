//
//  CEACurrexAPI_Tests.m
//  CurrexAppTests
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import XCTest;

#import "CEANetwork.h"
#import "CEACurrexAPI.h"
#import "CEACurrexRates.h"

@interface NetworkStub: NSObject <CEANetwork>

@property (strong, nonatomic, nonnull) NSString *testFileName;

- (instancetype)initWithTestFileName:(NSString *)testFileName;

@end

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

    [self.api fetchExchangeRatesWithCallback:^(CEACurrexRates * _Nullable rates, NSError * _Nullable error) {
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
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:nil];
}

@end


@implementation NetworkStub

- (instancetype)initWithTestFileName:(NSString *)testFileName {
    self = [super init];
    self.testFileName = testFileName;
    return self;
}

- (void)fetchFileWithURL:(NSURL *)url callback:(void (^)(NSData * _Nullable, NSError * _Nullable))callback {
    NSURL *testDataFileUrl = [[NSBundle bundleForClass:[NetworkStub class]] URLForResource:self.testFileName withExtension:@"xml"];
    NSData *data = [NSData dataWithContentsOfURL:testDataFileUrl];
    callback(data, nil);
}

@end
