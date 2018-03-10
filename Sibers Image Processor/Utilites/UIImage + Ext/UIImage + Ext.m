//
//  UIImage + Ext.m
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import "UIImage + Ext.h"

@implementation UIImage (rotation)

- (UIImage *)fixImageOrientation {
	
	UIImage *image = self;
	UIImageOrientation orient = image.imageOrientation;
	
	int rotateDegrees;
	
	switch(orient) {
			
		case UIImageOrientationUp:
			rotateDegrees = 0;
			break;
			
		case UIImageOrientationDown:
			rotateDegrees = 180;
			break;
			
		case UIImageOrientationLeft:
			rotateDegrees = -90;
			break;
			
		case UIImageOrientationRight:
			rotateDegrees = 90;
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
	}
	UIImage *output = [image rotateImageByDegrees:rotateDegrees];
	
	return output;
}

- (UIImage *)rotateImageByDegrees:(int)degrees {
	
	float rotationAngle = - degrees * M_PI/180;
	CIImage *ciimg = [CIImage imageWithCGImage: self.CGImage];
	
	CIFilter *rotate = [CIFilter filterWithName:@"CIAffineTransform"];
	[rotate setValue:ciimg forKey:kCIInputImageKey];
	
	CGAffineTransform t = CGAffineTransformMakeRotation(rotationAngle);
	[rotate setValue:[NSValue valueWithBytes:&t
									objCType:@encode(CGAffineTransform)]
			  forKey:@"inputTransform"];
	
	CIImage *result = [rotate outputImage];
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgimg = [context createCGImage:result fromRect:[result extent]];
	
	UIImage *output = [UIImage imageWithCGImage:cgimg];
	
	return output;
}

@end
