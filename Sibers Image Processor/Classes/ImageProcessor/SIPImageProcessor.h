//
//  SIPImageProcessor.h
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SIPImageProcessorDelegate.h"

typedef enum {
	ProcessorFilterRotate90Clockwise,
	ProcessorFilterMonochrome,
	ProcessorFilterColorInverse,
	ProcessorFilterHMirror,
	ProcessorFilterHLeftHalfMirror
} ProcessorFilter;

@interface SIPImageProcessor: NSObject

+ (NSString *_Nonnull)processorFilterString:(ProcessorFilter)filter;

- (instancetype _Nonnull)initWithImage: (UIImage *_Nullable)image;
- (void)applyFilter:(ProcessorFilter)filter progressBlock:(void (^_Nonnull)(float))progress completionBlock:(void (^_Nullable)(UIImage *_Nonnull))completion;

@end
