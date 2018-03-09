//
//  SIPFiltersHistoryVC.m
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import "SIPFiltersHistoryVC.h"
#import "SIPFilterButton.h"
#import "SIPFiltersHistoryCell.h"
#import "SIPPhotoPickerViewController.h"
#import "SIPImageProcessor.h"
#import "SIPProcessedObject.h"

@interface SIPFiltersHistoryVC () <UITableViewDelegate, UITableViewDataSource, PhotoPickerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *chosenImageView;
@property (weak, nonatomic) IBOutlet UITableView *filtersHistoryTableView;

@property (weak, nonatomic) IBOutlet SIPFilterButton *monochromeFilterButton;
@property (weak, nonatomic) IBOutlet SIPFilterButton *rotateFilterButton;
@property (weak, nonatomic) IBOutlet SIPFilterButton *inverseFlterButton;
@property (weak, nonatomic) IBOutlet SIPFilterButton *hMirrorFilterButton;
@property (weak, nonatomic) IBOutlet SIPFilterButton *leftHalfMirrorFilterButton;

@property (weak, nonatomic) IBOutlet SIPFilterButton *pickImageButton;

@property (strong, nonatomic) NSArray<SIPProcessedObject *> *processedObjects;
@property (strong, nonatomic) SIPImageProcessor *imageProcessor;

@end

@implementation SIPFiltersHistoryVC

// Cells height
#define kCellLoadingHeight 30.f
#define kCellReadyHeight 100.f

// MARK: - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationController.navigationBarHidden = YES;
	self.view.backgroundColor = [UIColor whiteColor];
	
	// Set filter titles
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
	
	self.filtersHistoryTableView.layer.borderColor = [UIColor blackColor].CGColor;
	self.filtersHistoryTableView.layer.borderWidth = 1.0;
	self.filtersHistoryTableView.tableFooterView = [[UIView alloc] init];
	
	// Implement choosing image button
	[_pickImageButton setTitle:NSLocalizedString(@"Choose image", @"choose image button title") forState: UIControlStateNormal];
	_pickImageButton.backgroundColor = [UIColor clearColor];
	
	// History preload (from CoreData maybe)
	_processedObjects = [[NSArray alloc] init];
	
	// Register our cell
	NSString *filterCellName = NSStringFromClass(SIPFiltersHistoryCell.self);
	NSBundle *bundle = [NSBundle bundleForClass:SIPFiltersHistoryCell.self];
	UINib *filterCellNib = [UINib nibWithNibName:filterCellName bundle:bundle];
	[self.filtersHistoryTableView registerNib:filterCellNib forCellReuseIdentifier: filterCellName];
	
	self.filtersHistoryTableView.delegate = self;
	self.filtersHistoryTableView.dataSource = self;
}

- (void)viewDidLayoutSubviews {
	// Place button below image view
	_pickImageButton.frame = _chosenImageView.frame;
}

// MARK: - Actions
- (IBAction)filterButtonTouchUp:(UIButton *)sender {
	
	if (_chosenImageView.image == nil) {
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
	
	// First - add a new row with nil Image
	[_filtersHistoryTableView beginUpdates];
	NSMutableArray *tempArray = [NSMutableArray arrayWithArray:_processedObjects];
	SIPProcessedObject *newObject = [[SIPProcessedObject alloc] init];
	newObject.image = nil;
	newObject.processingProgress = 0.0;
	[tempArray addObject:newObject];
	_processedObjects = [NSArray arrayWithArray:tempArray];
	[_filtersHistoryTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
									withRowAnimation:UITableViewRowAnimationTop];
	[_filtersHistoryTableView reloadData];
	[_filtersHistoryTableView endUpdates];
	
	// Start a new thread to process image
	NSThread *newThread = [[NSThread alloc] initWithTarget:self selector:@selector(applyFilter:) object:[NSNumber numberWithInt:filter]];
	[newThread start];
}

- (void)applyFilter:(NSNumber *)filterInt {
	
	int filter = [filterInt intValue];
	SIPProcessedObject *newObject = [_processedObjects lastObject];
	// Second - apply filter and wait for a callback
	[_imageProcessor applyFilter:filter
				   progressBlock:^(CGFloat progressFloat) {
					   newObject.processingProgress = progressFloat;
					   [self updateCellWithObject:newObject];
				   }
				 completionBlock:^(UIImage *outputImage) {
					 newObject.image = outputImage;
					 [self updateCellWithObject:newObject];
				 }
	 ];
}

- (void)updateCellWithObject:(SIPProcessedObject *)object {
	dispatch_async(dispatch_get_main_queue(), ^{
		NSUInteger index = [_processedObjects indexOfObject:object];
		NSUInteger row = [self rowForObjectAtIndex:index];
		[_filtersHistoryTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	});
}

- (NSUInteger)rowForObjectAtIndex:(NSUInteger)index {
	return (_processedObjects.count - index - 1);
}

- (IBAction)pickImageButtonTouchUp:(id)sender {
	
	UIAlertController *imageSourceAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose image source", @"choose image source alert title") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction *actionCameraSource = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", @"camera source type") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
	}];
	
	UIAlertAction *actionGallerySource = [UIAlertAction actionWithTitle:NSLocalizedString(@"Gallery", @"gallery source type") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}];
	
	UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"cancel button") style:UIAlertActionStyleCancel handler:nil];
	
	[imageSourceAlert addAction:actionCameraSource];
	[imageSourceAlert addAction:actionGallerySource];
	[imageSourceAlert addAction:actionCancel];
	
	[self presentViewController:imageSourceAlert animated:YES completion:nil];
}

// MARK: - Segue
- (void)showImagePickerWithSourceType: (UIImagePickerControllerSourceType) sourceType {
	SIPPhotoPickerViewController *photoPicker = [[SIPPhotoPickerViewController alloc] initWithSourceType:sourceType];
	photoPicker.photoPickerDelegate = self;
	[self.navigationController presentViewController:photoPicker animated:YES completion:nil];
}

// MARK: - PhotoPickerDelegate
- (void)photoPickerGotImage:(UIImage *)image {
	_chosenImageView.image = image;
	_imageProcessor = [[SIPImageProcessor alloc] initWithImage:image];
	[_pickImageButton setTitle:@"" forState:UIControlStateNormal];
}

- (void)photoPickerGotError:(NSString *)error {
	
}

// MARK: - UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	
	SIPFiltersHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass(SIPFiltersHistoryCell.self)
																  forIndexPath: indexPath];
	SIPProcessedObject *object = _processedObjects[[self rowForObjectAtIndex:indexPath.row]];
	if (object.image != nil) {
		cell.filteredImage = object.image;
	} else {
		cell.progressBar.progress = object.processingProgress;
	}
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

@end
