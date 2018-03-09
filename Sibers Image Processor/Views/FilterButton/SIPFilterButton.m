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
	self.titleLabel.textColor = [UIColor blackColor];
	self.titleEdgeInsets = UIEdgeInsetsMake(5.0, 10.0, 5.0, 10.0);
}

@end
