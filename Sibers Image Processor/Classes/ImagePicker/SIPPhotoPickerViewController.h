//
//  SIPPhotoPickerViewController.h
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoPickerDelegate <NSObject>

- (void)photoPickerGotImage: (UIImage *) image;
- (void)photoPickerGotError: (NSString *) error;

@end

@interface SIPPhotoPickerViewController : UIImagePickerController

@property (weak, nonatomic) id <PhotoPickerDelegate> photoPickerDelegate;
- (instancetype) initWithSourceType:(UIImagePickerControllerSourceType) sourceType;

@end
