//
//  MTWristbandConnection.h
//  MTWristbandKit
//
//  Created by Minewtech on 2020/5/21.
//  Copyright © 2020 Minewtech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, Connection) {
    Disconnected = 0,
    Connected,
    Connecting,
    Validating,
    Validated,
    ValidateFailed,
    PasswordVaildateFailed,
};
@class MTWristbandPeripheral;

typedef void(^ConnectionChangeCompletion)(Connection connection);

@interface MTWristbandConnection : NSObject

// macString of device
@property (nonatomic, strong) NSString *macString;

/**
 current connection status.
 */
@property (nonatomic, readonly, assign) Connection connection;

/**
 listen the changes of connection.
 !!! this is a callback method, please listen to the block, it will execute when the device changes connection.
 @param completionHandler the connection changing block.
 */
- (void)didChangeConnection:(ConnectionChangeCompletion)completionHandler;

@end

NS_ASSUME_NONNULL_END
