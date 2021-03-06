//
//  SIPProcessedImage.h
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SIPProcessedObject: NSObject

@property (strong, nonatomic) UIImage *image;
@property (assign) float processingProgress;

@end
