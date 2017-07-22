//
//  CEATestHelper.h
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/22/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import Foundation;
@import ReactiveObjC;

@protocol CEANetwork;

@interface CEATestHelper : NSObject

+ (nonnull id <NSDecimalNumberBehaviors>)decimalNumberBehaviors;

@end

@interface NetworkStub: NSObject <CEANetwork>

@property (strong, nonatomic, nonnull) NSString *testFileName;

- (nonnull instancetype)initWithTestFileName:(NSString *_Nonnull)testFileName;

@end
