//
//  SIPPermissionsChecker.m
//  Sibers Image Processor
//
//  Created by Тарас on 10.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import "SIPPermissionsChecker.h"
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation SIPPermissionsChecker

+ (BOOL)isCameraAvailable {
	AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType: AVMediaTypeVideo];
	if ((status == AVAuthorizationStatusAuthorized) ||
		(status == AVAuthorizationStatusNotDetermined)) {
		return YES;
	} else {
		return NO;
	}
}

+ (BOOL)isPhotosAlbumUsageAvailable {
	
	PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
	if ((status == PHAuthorizationStatusAuthorized) ||
	 (status == PHAuthorizationStatusNotDetermined)) {
		return YES;
	} else {
		return NO;
	}
}

@end
