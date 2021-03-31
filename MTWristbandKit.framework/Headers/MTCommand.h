//
//  MTCommand.h
//  MTWristbandKit
//
//  Created by Minewtech on 2021/3/29.
//  Copyright © 2021 Minewtech. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MTWristbandPeripheral;

NS_ASSUME_NONNULL_BEGIN
typedef void(^statusBlock)(bool status);

typedef void(^otaBlock)(bool status, double progress);

typedef void(^valueBlock)(int value);

typedef void(^historyBlock)(NSArray* valueAry);


@interface MTCommand : NSObject

//write
/**
Device password verification.
 @param per the device object;
 @param password the device password;
 @param status the status block.
*/
+ (void)writePassword:(MTWristbandPeripheral *)per password:(NSString *)password handler:(statusBlock)status;

/**
Reset device.
 @param per the device object;
 @param status the status block;
Only clean flash card information.
*/
+ (void)reset:(MTWristbandPeripheral *)per handler:(statusBlock)status;

/**
Device setting poweroff.
 @param per the device object;
 @param status the status block.
*/
+ (void)setPowerOff:(MTWristbandPeripheral *)per handler:(statusBlock)status;

/**
Set whether the device stores data.
 @param per the device object;
 @param isStorage the isStorage is YES, store data;
 @param status the status block.
*/
+ (void)setIsStorageData:(MTWristbandPeripheral *)per isStorage:(BOOL)isStorage handler:(statusBlock)status;

/**
Set device alarm distance gear.
 @param per the device object;
 @param level the number of alarm dstance gear which you want.(0-4)gear;
 @param status the status block.
*/
+ (void)setAlarmDistance:(MTWristbandPeripheral *)per level:(int)level handler:(statusBlock)status;

/**
Set device alarm temperature.
 @param per the device object;
 @param temp the number of alarm temperature which you want.(30.0-42.0)℃;
 @param status the status block.
*/
+ (void)setAlarmTemperature:(MTWristbandPeripheral *)per temp:(double)temp handler:(statusBlock)status;

/**
Set the temperature measurement interval.
 @param per the device object;
 @param interval the number of temperature measurement interval which you want.(0-7200)s;
 @param status the status block.
*/
+ (void)setReadTemperatureInterval:(MTWristbandPeripheral *)per interval:(int)interval handler:(statusBlock)status;

/**
Set the distance vibrating  of the device.
 @param per the device object;
 @param isOn the isOn is YES, device can  vibrating; the isOn is NO, device can't be vibrating;
 @param status the status block.
*/
+ (void)setDeviceDistanceVibration:(MTWristbandPeripheral *)per isOn:(BOOL)isOn handler:(statusBlock)status;

/**
Set the temp vibrating  of the device.
 @param per the device object;
 @param isOn the isOn is YES, device can  vibrating; the isOn is NO, device can't be vibrating;
 @param status the status block.
*/
+ (void)setDeviceTempVibration:(MTWristbandPeripheral *)per isOn:(BOOL)isOn handler:(statusBlock)status;

/**
Set vibration temperature threshold  of the device.
 @param per the device object;
 @param temp the number of vibration temperature which you want.(30.0-42.0)℃;
 @param status the status block.
*/
+ (void)setDeviceTempVibrationThreshold:(MTWristbandPeripheral *)per temp:(double)temp handler:(statusBlock)status;

//read
/**
Read vibration temperature threshold  of the device.
 @param per the device object;
 @param handler the value block.
*/
+ (void)readDeviceTempVibrationThreshold:(MTWristbandPeripheral *)per handler:(valueBlock)handler;

/**
Read vibration temperature threshold  of the device.
 @param per the device object;
 @param handler the value block.
*/
+ (void)readDeviceTempVibration:(MTWristbandPeripheral *)per handler:(statusBlock)handler;

/**
Read the distance vibrating  of the device.
 @param per the device object;
 @param handler the value block.
*/
+ (void)readDeviceDistanceVibration:(MTWristbandPeripheral *)per handler:(statusBlock)handler;

/**
Read the temperature measurement interval.
 @param per the device object;
 @param handler the value block.
*/
+ (void)readTemperatureInterval:(MTWristbandPeripheral *)per handler:(valueBlock)handler;

/**
Read device alarm temperature.
 @param per the device object;
 @param handler the value block.
*/
+ (void)readAlarmTemperature:(MTWristbandPeripheral *)per handler:(valueBlock)handler;

/**
Read device alarm distance gear.
 @param per the device object;
 @param handler the value block.
*/
+ (void)readAlarmDistance:(MTWristbandPeripheral *)per handler:(valueBlock)handler;

//history
/**
Read device distance history.
 @param per the device object;
 @param begin Start number of historical records which you want.It's start 0;
 @param end End number of historical records which you want.It's end number of the historyNumber-1;
 @param handler the history value block.
*/
+ (void)readWarningHistory:(MTWristbandPeripheral *)per begin:(int )begin end:(int )end handler:(historyBlock)handler;

/**
Read device temperature history.
 @param per the device object;
 @param begin Start number of historical records which you want.It's start 0;
 @param end End number of historical records which you want.It's end number of the historyNumber-1;
 @param handler the history value block.
*/
+ (void)readTempHistory:(MTWristbandPeripheral *)per  begin:(int )begin end:(int )end handler:(nonnull historyBlock)handler;

//ota
/**
Device OTA.
 @param per the device object;
 @param fileData OTA data which you want to update;
 @param handler the ota status block.
*/
+ (void)ota:(MTWristbandPeripheral *)per fileData:(NSData *)fileData handler:(otaBlock)handler;

@end

NS_ASSUME_NONNULL_END
