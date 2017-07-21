//
//  CEACurrexRatesParserDelegate.h
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/21/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import Foundation;

@class CEACurrexRates;

@interface CEACurrexRatesParserDelegate: NSObject <NSXMLParserDelegate>

/// Parsing result will be here if parsing is successful
@property (strong, nonatomic, nullable, readonly) CEACurrexRates *rates;

@end
