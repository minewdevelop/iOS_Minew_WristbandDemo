//
//  MTUtils.h
//  MTWristbandKit
//
//  Created by Minewtech on 2020/5/21.
//  Copyright © 2020 Minewtech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^distanceHistoryBlock)(NSString *mac,NSString *rssi,NSTimeInterval time);

typedef void(^tempHistoryBlock)(double temp,NSTimeInterval time);


@interface MTUtils : NSObject

+ (void)dealWithWarningHistory:(NSData *)da andHandler:(distanceHistoryBlock)handler;

+ (void)dealWithTempHistory:(NSData *)da andHandler:(tempHistoryBlock)handler;

/**
Device password verification.

 @param password the device password.
*/
+ (NSData *)verficationPassword:(NSString *)password;

/**
Device setting poweroff.
*/
+ (NSData *)setPowerOff;

/**
Read device distance history.

 @param begain Start number of historical records which you want.It's start 0.
 @param end End number of historical records which you want.It's end number of the historyNumber-1.
*/
+ (NSData *)readWarningHistoryWithBegain:(int)begain End:(int)end;
/**
Read device temperature history.

 @param begain Start number of historical records which you want.It's start 0.
 @param end End number of historical records which you want.It's end number of the historyNumber-1.
*/
+ (NSData *)readTempHistoryWithBegain:(int)begain End:(int)end;
/**
Read device alarm distance gear.
*/
+ (NSData *)readAlarmDistance;
/**
Set device alarm distance gear.

 @param distance the number of alarm dstance gear which you want.(0-4)gear
*/
+ (NSData *)setAlarmDistance:(int)distance;
/**
Read device alarm temperature.
*/
+ (NSData *)readAlarmTemperature;
/**
Set device alarm temperature.

 @param temp the number of alarm temperature which you want.(30.0-42.0)℃
*/
+ (NSData *)setAlarmTemperature:(double)temp;
/**
Read the temperature measurement interval.
 
*/
+ (NSData *)readTemperatureInterval;
/**
Set the temperature measurement interval.
 
 @param time the number of temperature measurement interval which you want.(0-7200)s
*/
+ (NSData *)setReadTemperatureInterval:(int)time;
/**
Reset device.
Only clean flash card information.
*/
+ (NSData *)resetDevice;

/**
Device OTA.

 @param data OTA data which you want to update, return data array that is write to device, but write next data after you need to receive notify success.
*/
+ (NSArray<NSData *> *)ota:(NSData *)data;
/**
Set whether the device stores data.

 @param isStorage the isStorage is YES, store data.
*/
+ (NSData *)setIsStorageData:(BOOL)isStorage;

@end

NS_ASSUME_NONNULL_END
