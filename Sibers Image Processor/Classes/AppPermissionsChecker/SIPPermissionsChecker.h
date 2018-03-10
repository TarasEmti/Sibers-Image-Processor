//
//  SIPPermissionsChecker.h
//  Sibers Image Processor
//
//  Created by Тарас on 10.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIPPermissionsChecker : NSObject

+ (BOOL)isCameraAvailable;
+ (BOOL)isPhotosAlbumUsageAvailable;

@end
