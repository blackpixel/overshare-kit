//
//  OSKActivityIconButton.h
//  Overshare
//
//  Created by Jared Sinclair on 10/13/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import UIKit;

@class OSKActivity;

@interface OSKActivityIcon : UIButton

- (void)setBackgroundImage:(UIImage *)image forActivityType:(NSString *)type displayString:(NSString *)displayString;
- (void)osk_setTintColor:(UIColor *)color forState:(UIControlState)state;
- (UIColor *)osk_tintColorForState:(UIControlState)state;

@end
