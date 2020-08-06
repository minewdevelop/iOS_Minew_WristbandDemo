//
//  MyTableViewCell.m
//  MTWristbandDemo
//
//  Created by Minewtech on 2020/8/6.
//  Copyright © 2020 Minewtech. All rights reserved.
//

#import "MyTableViewCell.h"

@implementation MyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initViews];
    }
    
    return self;
}

- (void)initViews {
    _macLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
    [self.contentView addSubview:_macLabel];
    
    _rssiLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 10, 40, 30)];
    [self.contentView addSubview:_rssiLabel];
}


@end
