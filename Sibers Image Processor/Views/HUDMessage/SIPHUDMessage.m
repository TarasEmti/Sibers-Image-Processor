//
//  SIPHUDMessage.m
//  Sibers Image Processor
//
//  Created by Тарас on 10.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import "SIPHUDMessage.h"

@implementation SIPHUDMessage

#define defaultFontSize 17
#define increasedFontSize 25

- (instancetype)init {
	self = [super init];
	[self hudCustomization];
	
	return self;
}

- (void)hudCustomization {
	CGSize windowSize = [UIApplication sharedApplication].keyWindow.bounds.size;
	self.frame = CGRectMake(windowSize.width/2 - 50, windowSize.height/2 - 50, 100, 100);
	self.layer.cornerRadius = 10;
	self.layer.masksToBounds = YES;
	self.textAlignment = NSTextAlignmentCenter;
	self.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
	self.numberOfLines = 3;
	self.alpha = 0.0;
	self.adjustsFontSizeToFitWidth = YES;
}

- (void)drawTextInRect:(CGRect)rect {
	UIEdgeInsets insets = UIEdgeInsetsMake(5, 5, 5, 5);
	[super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (void)startAppearingAnimation {
	
	self.alpha = 1.0;
	[UIView animateWithDuration:1
						  delay:2
						options:UIViewAnimationOptionTransitionCrossDissolve
					 animations:^{
						 self.alpha = 0.0;
					 }
					 completion:nil];
}

- (void)showErrorWithMessage:(NSString *)string {
	self.text = [NSString stringWithFormat:@"✕\n%@", string];
	self.font = [UIFont systemFontOfSize:defaultFontSize];
	[self startAppearingAnimation];
}

- (void)showSuccess {
	self.text = [NSString stringWithFormat:@"✓"];
	self.font = [UIFont systemFontOfSize:increasedFontSize];
	[self startAppearingAnimation];
}
- (void)showSuccessWithMessage:(NSString *)string {
	self.text = [NSString stringWithFormat:@"✓\n%@", string];
	self.font = [UIFont systemFontOfSize:defaultFontSize];
	[self startAppearingAnimation];
}
- (void)showInfoMessage:(NSString *)string {
	self.text = [NSString stringWithFormat:@"%@", string];
	self.font = [UIFont systemFontOfSize:defaultFontSize];
	[self startAppearingAnimation];
}

@end
