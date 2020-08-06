//
//  MTWristbandCentralManager.h
//  MTWristbandKit
//
//  Created by Minewtech on 2020/5/21.
//  Copyright © 2020 Minewtech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTWristbandPeripheral,CBCentralManager;
NS_ASSUME_NONNULL_BEGIN

// iphone bluetooth state, this sdk works well only in poweron state
typedef NS_ENUM(NSUInteger, PowerState) {
    PowerStateUnknown = 0,
    PowerStatePoweredOff,
    PowerStatePoweredOn,
};

// get scanned devices in this block
typedef void(^MTScanBlock)(NSArray<MTWristbandPeripheral *> *peripherals);
// intput password in this block
typedef void(^MTPasswordRequireBlock)(NSString *password);
// get powerState in this block
typedef void(^BluetoothChangeCompletion)(PowerState statues);

@interface MTWristbandCentralManager : NSObject

// current iphone bluetooth state
@property (nonatomic, assign) PowerState state;

// current scanned devices
@property (nonatomic, strong, readonly) NSArray<MTWristbandPeripheral *> *scannedPeris;

/**
 get shared MTCentralManager instance
 
 @return MTC instance
 */
+ (instancetype)sharedInstance;


/**
 start scan devices,
 get scanned devices in handler block or "scannedPeris" property.
 
 @param handler listen scanned devices
 */
- (void)startScan:(MTScanBlock)handler;

/**
stop scan devices.

*/
- (void)stopScan;

/**
iphone startAdvertising.

@param mac the device's mac which you want to advertising.
*/
- (void)startAdvertising:(NSString *)mac;

/**
iphone stopAdvertising.
*/
- (void)stopAdvertising;

/**
 try connect to a mtperipheral instance.
 
 @param per MTPeripheral instance wanted to be connected
 */

- (void)connectToPeriperal:(MTWristbandPeripheral *)per;
/**
 disconnect from a mtperipheral instance.
 
 @param per MTPeripheral instance wanted to be disconnected.
 */
- (void)disconnectFromPeriperal:(MTWristbandPeripheral *)per;


/**
 a callback for iphone bluetooth changes.
 
 @param completionHandler the bluetooth status changes block.
 */
- (void)didChangesBluetoothStatus:(BluetoothChangeCompletion)completionHandler;

@end

NS_ASSUME_NONNULL_END
