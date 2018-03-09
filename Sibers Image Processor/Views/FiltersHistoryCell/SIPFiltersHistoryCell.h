//
//  SIPFiltersHistoryCell.h
//  Sibers Image Processor
//
//  Created by Тарас on 07.03.2018.
//  Copyright © 2018 Taras Minin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	ProcessedImageCellStateReady,
	ProcessedImageCellStateLoading
} ProcessedImageCellState;

@interface SIPFiltersHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (assign, nonatomic) ProcessedImageCellState state;
@property (weak, nonatomic) UIImage *filteredImage;

@end
