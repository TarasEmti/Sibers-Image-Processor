//
//  UIAlertViewController + Ext.m
//  Sibers Image Processor
//
//  Created by Тарас on 10.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import "UIAlertViewController + Ext.h"

@implementation UIAlertController (predefined)

+ (instancetype)alertWithTitle:(NSString *)title message:(NSString *)message {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
	[alert addAction:okAction];
	
	return alert;
}

@end
