//
//  SIPFilterButton.m
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import "SIPFilterButton.h"

@implementation SIPFilterButton

- (void)drawRect:(CGRect)rect {
	
	self.layer.borderWidth = 1.0;
	self.layer.borderColor = [UIColor blackColor].CGColor;
	
	// Title cutomization
	self.titleLabel.textColor = [UIColor blackColor];
	self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	self.titleLabel.adjustsFontSizeToFitWidth = YES;
	self.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
}

@end
