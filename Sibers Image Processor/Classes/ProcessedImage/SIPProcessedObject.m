//
//  SIPProcessedImage.m
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import "SIPProcessedObject.h"

@implementation SIPProcessedObject

- (void) setImage:(UIImage *)image {
	
	// Do not let rewrite processed image
	if (_image == nil) {
		_image = image;
	}
}

@end
