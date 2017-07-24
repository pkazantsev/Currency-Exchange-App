//
//  UIButtton_CurrexApp.m
//  CurrexApp
//
//  Created by Pavel Kazantsev on 7/24/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

#import "UIButtton_CurrexApp.h"

@implementation UIButton (CurrexApp)

- (NSString *)title {
    return [self titleForState:UIControlStateNormal];
}
- (void)setTitle:(NSString *)title {
    [self setTitle:title forState:UIControlStateNormal];
}

@end
