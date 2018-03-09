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

@property (weak, nonatomic) UIImage *image;
@property (assign) CGFloat processingProgress;

@end
