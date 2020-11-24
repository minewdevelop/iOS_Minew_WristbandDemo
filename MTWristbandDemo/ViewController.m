//
//  ViewController.m
//  MTWristbandDemo
//
//  Created by Minewtech on 2020/7/24.
//  Copyright © 2020 Minewtech. All rights reserved.
//

#import "ViewController.h"
#import <MTWristbandKit/MTWristbandKit.h>
#import "MyTableViewCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    MTWristbandCentralManager *central;
    MTWristbandPeripheral *p;
    NSArray<MTWristbandPeripheral*> *deviceAry;
    UITableView *deviceTable;
    UITextField *textF;
    NSTimer *timer;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"refresh" style:UIBarButtonItemStylePlain target:self action:@selector(realodData)];
    deviceTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    deviceTable.backgroundColor = [UIColor clearColor];
    deviceTable.rowHeight = 70;
    deviceTable.delegate = self;
    deviceTable.dataSource = self;
    [self.view addSubview:deviceTable];
    
    central = [MTWristbandCentralManager sharedInstance];
    [central startScan:^(NSArray<MTWristbandPeripheral *> * _Nonnull peripherals) {
        self->deviceAry = peripherals;
    }];

    [central didChangesBluetoothStatus:^(PowerState statues) {
        if (statues == PowerStatePoweredOff) {
            NSLog(@"first you need open the bluetooth");
        }
        else if (statues == PowerStatePoweredOn) {
            NSLog(@"everything is ok");
        }
        else {
            NSLog(@"unknow error");
        }
    }];
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self->deviceTable reloadData];
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MyTableViewCell *cell = [[MyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cells"];
    cell.macLabel.text = deviceAry[indexPath.row].broadcast.mac;
    cell.rssiLabel.text = [NSString stringWithFormat:@"%ld",(long)deviceAry[indexPath.row].broadcast.rssi];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return deviceAry.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MTWristbandPeripheral *per = deviceAry[indexPath.row];

    if (!deviceAry[indexPath.row].broadcast.isConnect) {
        NSLog(@"the device need to wakeup");
        [self->central startAdvertising:per.broadcast.mac];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!per.broadcast.isConnect) {
                NSLog(@"wake up failed!");
            }
            else {
                [self connectToDevice:per];
            }
        });
    }
    else {
        [central stopAdvertising];
        [self connectToDevice:per];
        NSLog(@"the device has wakended");
    }
}

- (void)connectToDevice:(MTWristbandPeripheral *)per {
    [central stopScan];
    [central connectToPeriperal:per];
    [per.connector didChangeConnection:^(Connection connection) {
        if (connection == Disconnected) {
            NSLog(@"the device has disconnected.");
        }
        else if (connection == Connecting) {
            NSLog(@"the device has connecting");
        }
        else if (connection == Connected) {
            NSLog(@"the device has connected");
        }
        else if (connection == Validating) {
            NSLog(@"the device has validating");
            self->p = per;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self writePassword:self->p];
            });
//            [self pushAlert:self->deviceAry[indexPath.row]];
        }
        else if (connection == Validated) {
            NSLog(@"the device has validated");
        }
        else {
            NSLog(@"the device has validatedfailed");
        }
    }];
}
#pragma mark *******************************writePassword

- (void)writePassword:(MTWristbandPeripheral *)device {
    NSData *da = [MTUtils verficationPassword:@"minew123"];
    [device.connector writeData:da completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"write password success!");
        }else {
            NSLog(@"write password failed!");
        }
    }];
    [device.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data && value == 0) {
            NSLog(@"password is right");
            //then do what you want to.for example:
            [self readWarningHistory:device];
        }
        else {
            NSLog(@"password is error");
        }
    }];
}
#pragma mark *******************************readWarningHistory

- (void)readWarningHistory:(MTWristbandPeripheral *)per {
    NSData *da = [MTUtils readWarningHistoryWithBegain:0 End:per.broadcast.totalNum-1];
    [per.connector writeData:da completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"write readWarningHistory success!");
        }else {
            NSLog(@"write readWarningHistory failed!");
        }
    }];
    [per.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data.length == 1 && value == 0) {
            NSLog(@"Command sent successfully");
            return;
        }
        //Each piece of data is 16, When the total number of data is equal to the totalNum of broadcasted data, the data reception is complete.
        if (data.length % 16 != 0) {
            for (NSInteger k = 0; k<(data.length-14)/16; k++) {
                [self dealHistoryData:[data subdataWithRange:NSMakeRange(k*16+14, 16)]];
            }
        }
        else {
            for (NSInteger k = 0; k<(data.length)/16; k++) {
                [self dealHistoryData:[data subdataWithRange:NSMakeRange(k*16, 16)]];
            }
        }
    }];
}
#pragma mark *******************************readTempHistory

- (void)readTempHistory:(MTWristbandPeripheral *)per {
    NSData *da = [MTUtils readTempHistoryWithBegain:0 End:per.broadcast.tempTotalNum-1];
    [per.connector writeData:da completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"write readTempHistory success!");
        }else {
            NSLog(@"write readTempHistory failed!");
        }
    }];
    [per.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data.length == 1 && value == 0) {
            NSLog(@"Command sent successfully");
            return;
        }
        //Each piece of data is 8, When the total number of data is equal to the tempTotalNum of broadcasted data, the data reception is complete.
        if (data.length % 8 != 0) {
            for (NSInteger k = 0; k<(data.length-14)/8; k++) {
                [self dealHistoryData:[data subdataWithRange:NSMakeRange(k*8+14, 8)]];
            }
        }
        else {
            for (NSInteger k = 0; k<(data.length)/8; k++) {
                [self dealHistoryData:[data subdataWithRange:NSMakeRange(k*8, 8)]];
            }
        }
    }];
}
#pragma mark *******************************reset

- (void)reset:(MTWristbandPeripheral *)per {
    NSData *da = [MTUtils resetDevice];
    [per.connector writeData:da completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"write reset success!");
        }else {
            NSLog(@"write reset failed!");
        }
    }];
    [per.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data && value == 0) {
            NSLog(@"reset successfully");
        }
        else {
            NSLog(@"reset failed,error:%hhu",value);
        }
    }];
}
#pragma mark *******************************setPowerOff

- (void)setPowerOff:(MTWristbandPeripheral *)per {
    NSData *da = [MTUtils setPowerOff];
    [per.connector writeData:da completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"write setPowerOff success!");
        }else {
            NSLog(@"write setPowerOff failed!");
        }
    }];
    [per.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data && value == 0) {
            NSLog(@"setPowerOff successfully");
        }
        else {
            NSLog(@"setPowerOff failed,error:%hhu",value);
        }
    }];
}

#pragma mark *******************************setIsStorageData

- (void)setIsStorageData:(MTWristbandPeripheral *)per isStorage:(BOOL)isStorage {
    NSData *da = [MTUtils setIsStorageData:isStorage];
    [per.connector writeData:da completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"write setIsStorageData success!");
        }else {
            NSLog(@"write setIsStorageData failed!");
        }
    }];
    [per.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data && value == 0) {
            NSLog(@"setIsStorageData successfully");
        }
        else {
            NSLog(@"setIsStorageData failed,error:%hhu",value);
        }
    }];
}
#pragma mark *******************************readAlarmDistance

- (void)readAlarmDistance:(MTWristbandPeripheral *)per {
    NSData *da = [MTUtils readAlarmDistance];
    [per.connector writeData:da completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"write readAlarmDistance success!");
        }else {
            NSLog(@"write readAlarmDistance failed!");
        }
    }];
    [per.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data && value == 0) {
            NSLog(@"readAlarmDistance successfully");
        }
        else {
            NSLog(@"readAlarmDistance failed,error:%hhu",value);
        }
    }];
}
#pragma mark *******************************setAlarmDistance

- (void)setAlarmDistance:(MTWristbandPeripheral *)per level:(int)level {
    NSData *da = [MTUtils setAlarmDistance:level];
    [per.connector writeData:da completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"write setAlarmDistance success!");
        }else {
            NSLog(@"write setAlarmDistance failed!");
        }
    }];
    [per.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data && value == 0) {
            NSLog(@"setAlarmDistance successfully");
        }
        else {
            NSLog(@"setAlarmDistance failed,error:%hhu",value);
        }
    }];
}
#pragma mark *******************************readAlarmTemperature

- (void)readAlarmTemperature:(MTWristbandPeripheral *)per {
    NSData *da = [MTUtils readAlarmTemperature];
    [per.connector writeData:da completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"write readAlarmTemperature success!");
        }else {
            NSLog(@"write readAlarmTemperature failed!");
        }
    }];
    [per.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data && value == 0) {
            NSLog(@"readAlarmTemperature successfully");
        }
        else {
            NSLog(@"readAlarmTemperature failed,error:%hhu",value);
        }
    }];
}
#pragma mark *******************************setAlarmTemperature

- (void)setAlarmTemperature:(MTWristbandPeripheral *)per temp:(double)temp {
    NSData *da = [MTUtils setAlarmTemperature:temp];
    [per.connector writeData:da completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"write setAlarmTemperature success!");
        }else {
            NSLog(@"write setAlarmTemperature failed!");
        }
    }];
    [per.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data && value == 0) {
            NSLog(@"setAlarmTemperature successfully");
        }
        else {
            NSLog(@"setAlarmTemperature failed,error:%hhu",value);
        }
    }];
}
#pragma mark *******************************readTemperatureInterval

- (void)readTemperatureInterval:(MTWristbandPeripheral *)per {
    NSData *da = [MTUtils readTemperatureInterval];
    [per.connector writeData:da completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"write readTemperatureInterval success!");
        }else {
            NSLog(@"write readTemperatureInterval failed!");
        }
    }];
    [per.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data && value == 0) {
            NSLog(@"readTemperatureInterval successfully");
        }
        else {
            NSLog(@"readTemperatureInterval failed,error:%hhu",value);
        }
    }];
}
#pragma mark *******************************setReadTemperatureInterval

- (void)setReadTemperatureInterval:(MTWristbandPeripheral *)per interval:(int)interval {
    NSData *da = [MTUtils setReadTemperatureInterval:interval];
    [per.connector writeData:da completion:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            NSLog(@"write setReadTemperatureInterval success!");
        }else {
            NSLog(@"write setReadTemperatureInterval failed!");
        }
    }];
    [per.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data && value == 0) {
            NSLog(@"setReadTemperatureInterval successfully");
        }
        else {
            NSLog(@"setReadTemperatureInterval failed,error:%hhu",value);
        }
    }];
}
#pragma mark *******************************ota

- (void)ota:(MTWristbandPeripheral *)per {
    NSData *targetData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PS2009_NV900_20201029_debug_b8_ota_v3_2_3" ofType:@".bin"]];
    NSArray *otaDaAry = [MTUtils ota:targetData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSInteger k = 0; k<otaDaAry.count; k++) {
            [per.connector writeData:otaDaAry[k] completion:^(BOOL success, NSError * _Nonnull error) {
                if (success) {
                    NSLog(@"write ota success!");
                }else {
                    NSLog(@"write ota failed!");
                }
            }];
            [NSThread sleepForTimeInterval:0.02];
        }
    });
    
    [per.connector didReceiveData:^(NSData * _Nonnull data) {
        uint8_t value = 0;
        [data getBytes:&value length:1];
        if (data && value == 0) {
            NSLog(@"ota successfully");
        }
        else {
            NSLog(@"ota  failed,error:%hhu",value);
        }
    }];
}


- (void)dealHistoryData:(NSData *)d {
    [MTUtils dealWithWarningHistory:d andHandler:^(NSString * _Nonnull mac, NSString * _Nonnull rssi, NSTimeInterval time) {
        NSLog(@"every data------->%@ || %@ || %f",mac,rssi,time);
    }];
}

- (void)pushAlert:(MTWristbandPeripheral *)dev {
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"input password" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self writePassword:dev];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:defaultAction];
    [alertC addAction:cancelAction];
    [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        self->textF = textField;
        self->textF.text = @"minew123";
    }];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (void)realodData {
    deviceAry = @[];
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    [central stopScan];
    [central startScan:^(NSArray<MTWristbandPeripheral *> * _Nonnull peripherals) {
        self->deviceAry = peripherals;
    }];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self->deviceTable reloadData];
    }];
}

@end
