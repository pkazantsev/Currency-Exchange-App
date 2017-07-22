//
//  CEATestHelper.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/22/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

#import "CEATestHelper.h"

#import "CEANetwork.h"
#import "CEACurrexAPI.h"
#import "CEACurrexRates.h"

@implementation CEATestHelper

+ (id<NSDecimalNumberBehaviors>)decimalNumberBehaviors {
    return [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                  scale:3
                                                       raiseOnExactness:NO
                                                        raiseOnOverflow:NO
                                                       raiseOnUnderflow:NO
                                                    raiseOnDivideByZero:NO];
}

@end

@implementation NetworkStub

- (instancetype)initWithTestFileName:(NSString *)testFileName {
    self = [super init];
    self.testFileName = testFileName;
    return self;
}

- (RACSignal *)fetchFileWithURL:(NSURL *)url {
    NSURL *testDataFileUrl = [[NSBundle bundleForClass:[NetworkStub class]] URLForResource:self.testFileName withExtension:@"xml"];
    NSData *data = [NSData dataWithContentsOfURL:testDataFileUrl];

    return [RACSignal return:data];
}

@end
