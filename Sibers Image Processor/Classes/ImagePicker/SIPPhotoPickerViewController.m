//
//  SIPPhotoPickerViewController.m
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import "SIPPhotoPickerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage + Ext.h"

@interface SIPPhotoPickerViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation SIPPhotoPickerViewController

- (instancetype) initWithSourceType:(UIImagePickerControllerSourceType) sourceType {
	self = [super init];
	self.sourceType = sourceType;
	self.allowsEditing = NO;
	self.delegate = self;
	
	switch (sourceType) {
		case UIImagePickerControllerSourceTypeCamera:
			self.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
			break;
			
		case UIImagePickerControllerSourceTypePhotoLibrary:
			self.mediaTypes = @[[NSString stringWithFormat:@"%@", kUTTypeImage]];
			break;
			
		default:
			break;
	}
	return self;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
	
	UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	UIImage *fixedChosenImage = [chosenImage fixImageOrientation];
	[_photoPickerDelegate photoPickerGotImage:fixedChosenImage];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
