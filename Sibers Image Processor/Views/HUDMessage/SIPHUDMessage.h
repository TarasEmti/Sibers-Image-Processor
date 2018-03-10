//
//  SIPHUDMessage.h
//  Sibers Image Processor
//
//  Created by Тарас on 10.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SIPHUDMessage : UILabel

- (void)showErrorWithMessage:(NSString *)string;
- (void)showSuccess;
- (void)showSuccessWithMessage:(NSString *)string;
- (void)showInfoMessage:(NSString *)string;

@end
