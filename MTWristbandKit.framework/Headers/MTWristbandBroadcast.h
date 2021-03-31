//
//  MTWristbandBroadcast.h
//  MTWristbandKit
//
//  Created by Minewtech on 2020/5/21.
//  Copyright © 2020 Minewtech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTWristbandBroadcast : NSObject

// name of device, sometimes available
@property (nonatomic, strong, readonly) NSString *name;

// current rssi value
@property (nonatomic, assign, readonly) NSInteger rssi;

// battery left, sometimes available
@property (nonatomic, assign, readonly) NSInteger battery;

// firmwareVersion string, sometimes available
@property (nonatomic, strong, readonly) NSString *firmwareVersion;

// mac string, sometimes available
@property (nonatomic, strong, readonly) NSString *mac;

// identifier string, sometimes available
@property (nonatomic, strong, readonly) NSString *identifier;

// isConnect, Whether the device can be connected
@property (nonatomic, assign, readonly) BOOL isConnect;

//isStorage, Whether to store data
@property (nonatomic, assign, readonly) BOOL isStorage;

//history number
@property (nonatomic, assign, readonly) int totalNum;

//tempHistory number
@property (nonatomic, assign, readonly) int tempTotalNum;

//versionType 1:hardwareVersion V1;2:hardwareVersion V2
@property (nonatomic, assign, readonly) int versionType;

//usage 2:firmwareVersion V1;3:firmwareVersion V2
@property (nonatomic, assign, readonly) int usage;

//temp
@property (nonatomic, assign, readonly) double temp;

@end

NS_ASSUME_NONNULL_END
