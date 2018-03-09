//
//  SIPFiltersHistoryCell.m
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import "SIPFiltersHistoryCell.h"

@interface SIPFiltersHistoryCell ()

@property (weak, nonatomic) IBOutlet UIImageView *processedImage;

@end

@implementation SIPFiltersHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
	_processedImage.image = nil;
	self.state = ProcessedImageCellStateLoading;
}

- (void)setFilteredImage:(UIImage *)filteredImage {
	[_processedImage setImage:filteredImage];
	self.state = ProcessedImageCellStateReady;
}

- (void)setState:(ProcessedImageCellState)state {
	switch (state) {
		case ProcessedImageCellStateReady:
			[_processedImage setHidden: NO];
			[_progressBar setHidden: YES];
			[_progressBar setProgress: 0];
			break;
		case ProcessedImageCellStateLoading:
			[_processedImage setHidden: YES];
			[_progressBar setHidden: NO];
			break;
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
