//
//  MTWristbandPeripheral.h
//  MTWristbandKit
//
//  Created by Minewtech on 2020/5/21.
//  Copyright © 2020 Minewtech. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MTWristbandBroadcast,MTWristbandConnection;

NS_ASSUME_NONNULL_BEGIN

@interface MTWristbandPeripheral : NSObject

// Uniquely identifier like "MAC address"
@property (nonatomic, strong) NSString *identifier;

// advertising stage handler
@property (nonatomic, strong) MTWristbandBroadcast *broadcast;

// connection stage handler
@property (nonatomic, strong) MTWristbandConnection *connector;

@end

NS_ASSUME_NONNULL_END
