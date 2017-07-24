//
//  View.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/23/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

#import "View.h"

@interface View ()

@end

@implementation View

- (void)awakeFromNib {
    [super awakeFromNib];

    [self resetView];
}

- (void)resetView {
    self.exchangeRateLabel.text = @"--";

    self.firstCurrencyLabel.text = @"---";
    self.secondCurrencyLabel.text = @"---";

    self.firstCurrencyAmountLabel.text = @"0.00";
    self.secondCurrencyAmountLabel.text = @"0.00";

    self.firstCurrencyAmountTextField.text = nil;
    self.secondCurrencyAmountTextField.text = nil;

    [self.nextCurrencyPairButton setTitle:@"--- to ---" forState:UIControlStateNormal];
    [self.prevCurrencyPairButton setTitle:@"--- to ---" forState:UIControlStateNormal];
}

@end
