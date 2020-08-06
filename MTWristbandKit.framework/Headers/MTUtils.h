//
//  MTUtils.h
//  MTWristbandKit
//
//  Created by Minewtech on 2020/5/21.
//  Copyright © 2020 Minewtech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MTUtils : NSObject

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
Read device history.

 @param begain Start number of historical records which you want.
 @param end End number of historical records which you want.
*/
+ (NSData *)readWarningHistoryWithBegain:(int)begain End:(int)end;
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
