//
//  SIPImageProcessor.m
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import "SIPImageProcessor.h"
#import "UIImage + Ext.h"

@interface SIPImageProcessor ()

@property (weak, nonatomic) UIImage *processedImage;

@end

@implementation SIPImageProcessor

#define updateInterval 0.25f

- (instancetype)initWithImage:(UIImage *)image {
	self = [super init];
	self.processedImage = image;
	
	return self;
}

- (void)applyFilter:(ProcessorFilter)filter progressBlock:(void (^_Nonnull)(CGFloat))progress completionBlock:(void (^_Nullable)(UIImage *))completion {
	
	dispatch_group_t filterProcessing = dispatch_group_create();
	
	// Simulated delay in between 5 and 30 seconds
	int delay = arc4random() % 10 + 5;
	__block UIImage *output;
	
	dispatch_group_enter(filterProcessing);
	[self filterProcessing:filter completionBlock:^(UIImage *filteredImage) {
		output = filteredImage;
		dispatch_group_leave(filterProcessing);
	}];
	
	dispatch_group_enter(filterProcessing);
	[self simulateProgress:delay progressBlock:^(CGFloat progressFloat) {
		progress(progressFloat);
	} completionBlock:^{
		dispatch_group_leave(filterProcessing);
	}];
	
	dispatch_group_notify(filterProcessing, dispatch_get_main_queue(), ^{
		completion(output);
	});
}

- (void)filterProcessing:(ProcessorFilter)filter completionBlock:(void (^_Nullable)(UIImage *))completion {
	UIImage *output;
	switch (filter) {
		case ProcessorFilterMonochrome:
			output = [self monochromeImage];
			break;
			
		case ProcessorFilterRotate90Clockwise:
			output = [_processedImage rotateImageByDegrees:90];
			break;
			
		case ProcessorFilterHMirror:
			output = [self horizontalMirrorImage];
			break;
			
		case ProcessorFilterHLeftHalfMirror:
			output = [self mirrorLeftHalfImage];
			break;
			
		case ProcessorFilterColorInverse:
			output = [self colorInverseImage];
			break;
	}
	completion(output);
}

- (void)simulateProgress:(int)delay progressBlock:(void (^_Nonnull)(CGFloat))progress completionBlock:(void (^_Nullable)(void))completion {
	
	CGFloat timePassed = 0.0;
	while (timePassed < delay) {
		[NSThread sleepForTimeInterval: updateInterval];
		CGFloat prog = timePassed / delay;
		dispatch_async(dispatch_get_main_queue(), ^{
			progress(prog);
		});
		timePassed += updateInterval;
	}
	completion();
}

+ (NSString *_Nonnull)processorFilterString:(ProcessorFilter)filter {
	NSString *filterName;
	switch (filter) {
		case ProcessorFilterHMirror:
			filterName = NSLocalizedString(@"Horizontal Mirror", @"horizontal mirror filter name");
			break;
			
		case ProcessorFilterMonochrome:
			filterName = NSLocalizedString(@"Monochrome", @"monochrome filter name");
			break;
			
		case ProcessorFilterColorInverse:
			filterName = NSLocalizedString(@"Color Inverse", @"color inverse filter name");
			break;
			
		case ProcessorFilterHLeftHalfMirror:
			filterName = NSLocalizedString(@"Left Half Mirror", @"left half mirror filter name");
			break;
			
		case ProcessorFilterRotate90Clockwise:
			filterName = NSLocalizedString(@"Rotate", @"Rotate 90 degrees filter name");
			break;
	}
	return filterName;
}

- (UIImage *)monochromeImage {
	
	CIImage *ciimg = [CIImage imageWithCGImage:_processedImage.CGImage];
	
	CIFilter *filter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
	[filter setValue:ciimg forKey:kCIInputImageKey];
	
	CIImage *result = [filter outputImage];
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgimg = [context createCGImage:result fromRect:[result extent]];
	
	UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
	
	return resultImg;
}

- (UIImage *)horizontalMirrorImage {
	
	CIImage *ciimg = [CIImage imageWithCGImage:_processedImage.CGImage];
	
	CIFilter *rotate = [CIFilter filterWithName:@"CIAffineTransform"];
	[rotate setValue:ciimg forKey:kCIInputImageKey];
	
	CGAffineTransform t = CGAffineTransformMakeScale(-1, 1);
	
	[rotate setValue:[NSValue valueWithBytes:&t
									objCType:@encode(CGAffineTransform)]
			  forKey:@"inputTransform"];
	
	CIImage *result = [rotate outputImage];
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgimg = [context createCGImage:result fromRect:[result extent]];
	
	UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
	
	return resultImg;
}

- (UIImage *)colorInverseImage {
	
	CIImage *ciimg = [CIImage imageWithCGImage:_processedImage.CGImage];
	
	CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
	[filter setValue:ciimg forKey:kCIInputImageKey];
	
	CIImage *result = [filter outputImage];
	CIContext *context = [CIContext contextWithOptions:nil];
	CGImageRef cgimg = [context createCGImage:result fromRect:[result extent]];
	
	UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
	
	return resultImg;
}

- (UIImage *)mirrorLeftHalfImage {
	
	CGImageRef ciimg = _processedImage.CGImage;
	
	CGContextRef ctx = CGBitmapContextCreate(NULL,
											 CGImageGetWidth(ciimg),
											 CGImageGetHeight(ciimg),
											 CGImageGetBitsPerComponent(ciimg),
											 CGImageGetBytesPerRow(ciimg),
											 CGImageGetColorSpace(ciimg),
											 CGImageGetBitmapInfo(ciimg));
	
	CGRect cropRect = CGRectMake(0,
								 0,
								 _processedImage.size.width/2,
								 _processedImage.size.height);
	
	CGImageRef otherHalf = CGImageCreateWithImageInRect(ciimg, cropRect);
	
	CGContextDrawImage(ctx, CGRectMake(0,
									   0,
									   CGImageGetWidth(ciimg),
									   CGImageGetHeight(ciimg)),
					   ciimg);
	
	CGAffineTransform t = CGAffineTransformMakeTranslation(_processedImage.size.width, 0.0);
	t = CGAffineTransformScale(t, -1.0, 1.0);
	CGContextConcatCTM(ctx, t);
	CGContextDrawImage(ctx, cropRect, otherHalf);
	
	CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	
	UIImage *resultImg = [UIImage imageWithCGImage:imageRef];
	
	return resultImg;
}

@end
