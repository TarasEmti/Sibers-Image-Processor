//
//  SIPImageProcessorDelegate.h
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

@protocol SIPImageProcessorDelegate <NSObject>

- (void)imageProcessorDoneProcessingImage: (UIImage *)image;
- (void)imageProcessorProcessingImage: (CGFloat)progress;

@end
