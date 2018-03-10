//
//  SIPFiltersHistoryVC.m
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import "UIAlertViewController + Ext.h"
#import "SIPFiltersHistoryVC.h"
#import "SIPFilterButton.h"
#import "SIPFiltersHistoryCell.h"
#import "SIPPhotoPickerViewController.h"
#import "SIPImageProcessor.h"
#import "SIPProcessedObject.h"
#import "SIPHUDMessage.h"
#import "SIPPermissionsChecker.h"

@interface SIPFiltersHistoryVC () <UITableViewDelegate, UITableViewDataSource, PhotoPickerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *chosenImageView;
@property (weak, nonatomic) IBOutlet UITableView *filtersHistoryTableView;

@property (weak, nonatomic) IBOutlet SIPFilterButton *monochromeFilterButton;
@property (weak, nonatomic) IBOutlet SIPFilterButton *rotateFilterButton;
@property (weak, nonatomic) IBOutlet SIPFilterButton *inverseFlterButton;
@property (weak, nonatomic) IBOutlet SIPFilterButton *hMirrorFilterButton;
@property (weak, nonatomic) IBOutlet SIPFilterButton *leftHalfMirrorFilterButton;
@property (weak, nonatomic) IBOutlet SIPFilterButton *pickImageButton;
@property (weak, nonatomic) IBOutlet UILabel *filtersHistoryLabel;

@property (strong, nonatomic) NSMutableArray<SIPProcessedObject *> *processedObjects;
@property (strong, nonatomic) SIPImageProcessor *imageProcessor;
@property (strong, nonatomic) SIPHUDMessage *hud;

@property (assign, readonly) int newObjectIndex;

@end

@implementation SIPFiltersHistoryVC

// Cells height
#define kCellLoadingHeight 30.f
#define kCellReadyHeight 150.f

// MARK: - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationController.navigationBarHidden = YES;
	self.view.backgroundColor = [UIColor whiteColor];
	
	// Set titles
	[_monochromeFilterButton setTitle: [SIPImageProcessor processorFilterString:ProcessorFilterMonochrome]
							 forState: UIControlStateNormal];
	[_hMirrorFilterButton setTitle: [SIPImageProcessor processorFilterString:ProcessorFilterHMirror]
						  forState: UIControlStateNormal];
	[_rotateFilterButton setTitle: [SIPImageProcessor processorFilterString:ProcessorFilterRotate90Clockwise]
						 forState: UIControlStateNormal];
	[_inverseFlterButton setTitle: [SIPImageProcessor processorFilterString:ProcessorFilterColorInverse]
						 forState: UIControlStateNormal];
	[_leftHalfMirrorFilterButton setTitle: [SIPImageProcessor processorFilterString:ProcessorFilterHLeftHalfMirror]
								 forState: UIControlStateNormal];
	[_filtersHistoryLabel setText:NSLocalizedString(@"Filters History:", @"filters history table view title")];
	
	// HUD setup
	_hud = [[SIPHUDMessage alloc] init];
	[self.view addSubview:_hud];
	
	// Implement choosing image button
	[_pickImageButton setTitle:NSLocalizedString(@"Choose image", @"choose image button title") forState: UIControlStateNormal];
	_pickImageButton.backgroundColor = [UIColor clearColor];
	
	// History preload (from CoreData maybe)
	_processedObjects = [[NSMutableArray alloc] init];
	
	self.filtersHistoryTableView.layer.borderColor = [UIColor blackColor].CGColor;
	self.filtersHistoryTableView.layer.borderWidth = 1.0;
	self.filtersHistoryTableView.tableFooterView = [[UIView alloc] init];
	
	// Register our cell
	NSString *filterCellName = NSStringFromClass(SIPFiltersHistoryCell.self);
	NSBundle *bundle = [NSBundle bundleForClass:SIPFiltersHistoryCell.self];
	UINib *filterCellNib = [UINib nibWithNibName:filterCellName bundle:bundle];
	[self.filtersHistoryTableView registerNib:filterCellNib forCellReuseIdentifier: filterCellName];
	
	self.filtersHistoryTableView.delegate = self;
	self.filtersHistoryTableView.dataSource = self;
}

- (int)newObjectIndex {
	// Here we can decide whether new cells will appear from top or from the bottom
	// index = 0 - from top
	// index = (_processedObjects.count - 1) - from bottom
	return 0;
}

// MARK: - Actions
- (IBAction)filterButtonTouchUp:(UIButton *)sender {
	
	if (_chosenImageView.image == nil) {
		[_hud showErrorWithMessage:NSLocalizedString(@"No Image", @"error text when there is no image to process")];
		return;
	}
	_imageProcessor = [[SIPImageProcessor alloc] initWithImage:_chosenImageView.image];
	// Unlike in Swift we can't do switch String or even make an enum with strings associated properties so we just need to be patient
	ProcessorFilter filter;
	if (sender.currentTitle == [SIPImageProcessor processorFilterString:ProcessorFilterMonochrome]) {
		filter = ProcessorFilterMonochrome;
	} else if (sender.currentTitle == [SIPImageProcessor processorFilterString:ProcessorFilterRotate90Clockwise]) {
		filter = ProcessorFilterRotate90Clockwise;
	} else if (sender.currentTitle == [SIPImageProcessor processorFilterString:ProcessorFilterHLeftHalfMirror]) {
		filter = ProcessorFilterHLeftHalfMirror;
	} else if (sender.currentTitle == [SIPImageProcessor processorFilterString:ProcessorFilterHMirror]) {
		filter = ProcessorFilterHMirror;
	} else if (sender.currentTitle == [SIPImageProcessor processorFilterString:ProcessorFilterColorInverse]) {
		filter = ProcessorFilterColorInverse;
	} else {
		return;
	}
	
	SIPProcessedObject *newObject = [[SIPProcessedObject alloc] init];
	newObject.image = nil;
	newObject.processingProgress = 0.0;
	
	[_processedObjects insertObject:newObject atIndex: self.newObjectIndex];
	
	[_filtersHistoryTableView beginUpdates];
	NSIndexPath *newObjectIndexPath = [NSIndexPath indexPathForRow: self.newObjectIndex
														 inSection: 0];
	[_filtersHistoryTableView insertRowsAtIndexPaths: @[newObjectIndexPath]
									withRowAnimation: UITableViewRowAnimationRight];
	[_filtersHistoryTableView endUpdates];
	
	// Start a new thread to process image
	// Again, Objective-C cannot pass an filter enum value as an object to a thred, so I've made an NSNumber
	NSThread *newThread = [[NSThread alloc] initWithTarget: self
												  selector: @selector(applyFilter:)
													object: [NSNumber numberWithInt: filter]];
	[newThread start];
}

- (void)applyFilter:(NSNumber *)filterInt {
	
	int filter = [filterInt intValue];
	SIPProcessedObject *newObject = _processedObjects[self.newObjectIndex];
	
	[_imageProcessor applyFilter:filter
				   progressBlock:^(float progressFloat) {
					   newObject.processingProgress = progressFloat;
					   [self updateCellWithObject:newObject];
				   }
				 completionBlock:^(UIImage *outputImage) {
					newObject.image = [[UIImage alloc] initWithCGImage:outputImage.CGImage];;
					[self updateCellWithObject:newObject];
				 }
	 ];
}

- (void)updateCellWithObject:(SIPProcessedObject *)object {
	dispatch_async(dispatch_get_main_queue(), ^{
		
		NSUInteger row = [_processedObjects indexOfObject:object];
		NSIndexPath *objectIndexPath = [NSIndexPath indexPathForRow: row
														  inSection: 0];
		_processedObjects[row] = object;
		// Check if we can see that cell at indexPath
		if ([[_filtersHistoryTableView indexPathsForVisibleRows] indexOfObject:objectIndexPath] == NSNotFound) {
			return;
		} else {
			[_filtersHistoryTableView reloadRowsAtIndexPaths:@[objectIndexPath] withRowAnimation:UITableViewRowAnimationNone];
		}
	});
}

- (IBAction)pickImageButtonTouchUp:(id)sender {
	
	UIAlertController *imageSourceAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose image source", @"choose image source alert title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction *actionCameraSource = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", @"camera source type") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		if ([SIPPermissionsChecker isCameraAvailable]) {
			[self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
		} else {
			UIAlertController *alert = [UIAlertController alertWithTitle:NSLocalizedString(@"Warning", @"alert warning title")
																 message:NSLocalizedString(@"Permission to camera is denied. Please, turn it on from your phone Settings.", @"how to enable camera permission info")];
			[self presentViewController:alert animated:YES completion:nil];
		}
	}];
	
	UIAlertAction *actionGallerySource = [UIAlertAction actionWithTitle:NSLocalizedString(@"Gallery", @"gallery source type") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		if ([SIPPermissionsChecker isPhotosAlbumUsageAvailable]) {
			[self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
		} else {
			UIAlertController *alert = [UIAlertController alertWithTitle:NSLocalizedString(@"Warning", @"alert warning title")
																 message:NSLocalizedString(@"Permission to Photos is denied. Please, turn it on from your phone Settings.", @"how to enable photos album permission info")];
			[self presentViewController:alert animated:YES completion:nil];
		}
	}];
	
	UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel button") style:UIAlertActionStyleCancel handler:nil];
	
	[imageSourceAlert addAction:actionCameraSource];
	[imageSourceAlert addAction:actionGallerySource];
	[imageSourceAlert addAction:actionCancel];
	
	[self presentViewController:imageSourceAlert animated:YES completion:nil];
}

// MARK: - Segue
- (void)showImagePickerWithSourceType: (UIImagePickerControllerSourceType) sourceType {
	
	if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
		SIPPhotoPickerViewController *photoPicker = [[SIPPhotoPickerViewController alloc] initWithSourceType:sourceType];
		photoPicker.photoPickerDelegate = self;
		[self.navigationController presentViewController:photoPicker animated:YES completion:nil];
	} else {
		[_hud showErrorWithMessage:NSLocalizedString(@"Source type unavailable", @"error message when camera/galley unavailable")];
	}
}

// MARK: - PhotoPickerDelegate
- (void)photoPickerGotImage:(UIImage *)image {
	_chosenImageView.image = image;
	
	// Hide button title
	if (_pickImageButton.titleLabel.text.length > 0) {
		[_pickImageButton setTitle:@"" forState:UIControlStateNormal];
	}
}

- (void)photoPickerGotError:(NSString *)error {
	[_hud showErrorWithMessage:error];
}

// MARK: - UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	
	SIPFiltersHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass(SIPFiltersHistoryCell.self)
																  forIndexPath: indexPath];
	SIPProcessedObject *object = _processedObjects[indexPath.row];
	[cell fillWithProcessedObject: object];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (_processedObjects[indexPath.row].image == nil) {
		return kCellLoadingHeight;
	} else {
		return kCellReadyHeight;
	}
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.processedObjects.count;
}

// MARK: - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Check if cell is in loading process - do nothing
	if (_processedObjects[indexPath.row].image == nil) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}
	
	UIAlertController *optionsAlert = [UIAlertController alertControllerWithTitle:nil
																	 message:nil
															  preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *chooseAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Pick this image", @"action to choose image as main image to apply filters") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		UIImage *objectImage = _processedObjects[indexPath.row].image;
		_chosenImageView.image = objectImage;
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}];
	
	UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save image", @"action to save image to photo album") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		UIImage *objectImage = _processedObjects[indexPath.row].image;
		UIImageWriteToSavedPhotosAlbum(objectImage,
									   self,
									   @selector(image:didFinishSavingWithError:contextInfo:),
									   nil);
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}];
	
	UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"action to delete cell") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		
		[_filtersHistoryTableView beginUpdates];
		[_processedObjects removeObjectAtIndex:indexPath.row];
		[_filtersHistoryTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[_filtersHistoryTableView endUpdates];
	}];
	
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel button") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}];
	
	[optionsAlert addAction:chooseAction];
	[optionsAlert addAction:saveAction];
	[optionsAlert addAction:deleteAction];
	[optionsAlert addAction:cancelAction];
	
	[self presentViewController:optionsAlert animated:YES completion:nil];
}

// MARK: - Callbacks
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	[_hud showSuccess];
}
@end
