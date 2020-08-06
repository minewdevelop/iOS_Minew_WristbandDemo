//
//  MyTableViewCell.h
//  MTWristbandDemo
//
//  Created by Minewtech on 2020/8/6.
//  Copyright © 2020 Minewtech. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyTableViewCell : UITableViewCell
// mac
@property (nonatomic, strong) UILabel *macLabel;
// rssi
@property (nonatomic, strong) UILabel *rssiLabel;

@end

NS_ASSUME_NONNULL_END
