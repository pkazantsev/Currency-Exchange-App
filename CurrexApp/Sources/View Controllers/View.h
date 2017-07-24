//
//  View.h
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/23/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

@import UIKit;

@interface View : UIView

@property (weak, nonatomic) IBOutlet UILabel *exchangeRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstCurrencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondCurrencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstCurrencyAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondCurrencyAmountLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstCurrencyAmountTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondCurrencyAmountTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeExchangeDirectionButton;

@property (weak, nonatomic) IBOutlet UIButton *prevCurrencyPairButton;
@property (weak, nonatomic) IBOutlet UIButton *nextCurrencyPairButton;

@end
