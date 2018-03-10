//
//  SIPFiltersHistoryCell.m
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import "SIPFiltersHistoryCell.h"

typedef enum {
	ProcessedImageCellStateReady,
	ProcessedImageCellStateLoading
} ProcessedImageCellState;

@interface SIPFiltersHistoryCell ()

@property (weak, nonatomic) IBOutlet UIImageView *processedImageView;
@property (assign, nonatomic) ProcessedImageCellState state;

@end

@implementation SIPFiltersHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
	_processedImageView.image = nil;
	_state = ProcessedImageCellStateLoading;
}

- (void)fillWithProcessedObject:(SIPProcessedObject *)object {
	if (object.image != nil) {
		_processedImageView.image = object.image;
		_state = ProcessedImageCellStateReady;
	} else {
		_processedImageView.image = nil;
		_progressBar.progress = object.processingProgress;
		_state = ProcessedImageCellStateLoading;
	}
	// Don't know why setter for enum property is not working. Let's call it manually
	[self setState:_state];
}

- (void)setState:(ProcessedImageCellState)state {
	switch (state) {
		case ProcessedImageCellStateReady:
			[_processedImageView setHidden: NO];
			[_progressBar setHidden: YES];
			break;
		case ProcessedImageCellStateLoading:
			[_processedImageView setHidden: YES];
			[_progressBar setHidden: NO];
			break;
	}
}

@end
