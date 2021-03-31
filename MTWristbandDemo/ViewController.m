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

- (void)writePassword:(MTWristbandPeripheral *)per {
    [MTCommand writePassword:per password:@"minew123" handler:^(bool status) {
        if (status) {
            NSLog(@"password is right");
        }
        else{
            NSLog(@"password is error");
        }
    }];
}
#pragma mark *******************************readWarningHistory

- (void)readWarningHistory:(MTWristbandPeripheral *)per {
    [MTCommand readWarningHistory:per begin:0 end:per.broadcast.totalNum-1 handler:^(NSArray * _Nonnull valueAry) {
        
    }];
}
#pragma mark *******************************readTempHistory

- (void)readTempHistory:(MTWristbandPeripheral *)per {
    [MTCommand readTempHistory:per begin:0 end:per.broadcast.tempTotalNum-1 handler:^(NSArray * _Nonnull valueAry) {
        
    }];
}
#pragma mark *******************************reset

- (void)reset:(MTWristbandPeripheral *)per {
    [MTCommand reset:per handler:^(bool status) {
        if (status) {
            NSLog(@"reset successfully");
        }
        else {
            NSLog(@"reset failed");
        }
    }];
}
#pragma mark *******************************setPowerOff

- (void)setPowerOff:(MTWristbandPeripheral *)per {
    [MTCommand setPowerOff:per handler:^(bool status) {
        if (status) {
            NSLog(@"setPowerOff successfully");
        }
        else {
            NSLog(@"setPowerOff failed");
        }
    }];
}

#pragma mark *******************************setIsStorageData

- (void)setIsStorageData:(MTWristbandPeripheral *)per isStorage:(BOOL)isStorage {
    [MTCommand setIsStorageData:per isStorage:isStorage handler:^(bool status) {
        if (status) {
            NSLog(@"setIsStorageData successfully");
        }
        else {
            NSLog(@"setIsStorageData failed");
        }
    }];
}
#pragma mark *******************************readAlarmDistance

- (void)readAlarmDistance:(MTWristbandPeripheral *)per {
    [MTCommand readAlarmDistance:per handler:^(int value) {
        if (value != -1) {
            NSLog(@"read success,the level is %d",value);
        }
        else {
            NSLog(@"read failed");
        }
    }];
}
#pragma mark *******************************setAlarmDistance

- (void)setAlarmDistance:(MTWristbandPeripheral *)per level:(int)level {
    [MTCommand setAlarmDistance:per level:level handler:^(bool status) {
        if (status) {
            NSLog(@"setAlarmDistance successfully");
        } else {
            NSLog(@"setAlarmDistance failed");
        }
    }];
}
#pragma mark *******************************readAlarmTemperature

- (void)readAlarmTemperature:(MTWristbandPeripheral *)per {
    [MTCommand readAlarmTemperature:per handler:^(int value) {
        if (value != -1) {
            NSLog(@"read success,the temperature is %d",value);
        }
        else {
            NSLog(@"read failed");
        }
    }];
}
#pragma mark *******************************setAlarmTemperature

- (void)setAlarmTemperature:(MTWristbandPeripheral *)per temp:(double)temp {
    [MTCommand setAlarmTemperature:per temp:temp handler:^(bool status) {
        if (status) {
            NSLog(@"setAlarmTemperature successfully");
        } else {
            NSLog(@"setAlarmTemperature failed");
        }
    }];
}
#pragma mark *******************************readTemperatureInterval

- (void)readTemperatureInterval:(MTWristbandPeripheral *)per {
    [MTCommand readTemperatureInterval:per handler:^(int value) {
        if (value != -1) {
            NSLog(@"read success,the temperatureInterval is %d",value);
        }
        else {
            NSLog(@"read failed");
        }
    }];
}
#pragma mark *******************************setReadTemperatureInterval

- (void)setReadTemperatureInterval:(MTWristbandPeripheral *)per interval:(int)interval {
    [MTCommand setReadTemperatureInterval:per interval:interval handler:^(bool status) {
        if (status) {
            NSLog(@"setReadTemperatureInterval successfully");
        } else {
            NSLog(@"setReadTemperatureInterval failed");
        }
    }];
}
#pragma mark *******************************setDeviceDistanceVibration

- (void)setDeviceDistanceVibration:(MTWristbandPeripheral *)per isOn:(BOOL)isOn {
    [MTCommand setDeviceDistanceVibration:per isOn:isOn handler:^(bool status) {
        if (status) {
            NSLog(@"setDeviceDistanceVibration successfully");
        } else {
            NSLog(@"setDeviceDistanceVibration failed");
        }
    }];
}

#pragma mark *******************************readDeviceDistanceVibration

- (void)readDeviceDistanceVibration:(MTWristbandPeripheral *)per {
    [MTCommand readDeviceDistanceVibration:per handler:^(bool status) {
        if (status) {
            NSLog(@"the distanceVibration's switch is true");
        }
        else {
            NSLog(@"the distanceVibration's switch is false");
        }
    }];
}
#pragma mark *******************************setDeviceTempVibration

- (void)setDeviceTempVibration:(MTWristbandPeripheral *)per isOn:(BOOL)isOn {
    [MTCommand setDeviceTempVibration:per isOn:isOn handler:^(bool status) {
        if (status) {
            NSLog(@"setDeviceTempVibration successfully");
        }
        else {
            NSLog(@"setDeviceTempVibration failed");
        }
    }];
}

#pragma mark *******************************readDeviceTempVibration

- (void)readDeviceTempVibration:(MTWristbandPeripheral *)per {
    [MTCommand readDeviceTempVibration:per handler:^(bool status) {
        if (status) {
            NSLog(@"the tempVibration's switch is true");
        }
        else {
            NSLog(@"the tempVibration's switch is false");
        }
    }];
}

#pragma mark *******************************setDeviceTempVibrationThreshold

- (void)setDeviceTempVibrationThreshold:(MTWristbandPeripheral *)per temp:(double)temp {
    [MTCommand setDeviceTempVibrationThreshold:per temp:temp handler:^(bool status) {
        if (status) {
            NSLog(@"setDeviceTempVibrationThreshold successfully");
        } else {
            NSLog(@"setDeviceTempVibrationThreshold failed");
        }
    }];
}

#pragma mark *******************************readDeviceTempVibrationThreshold

- (void)readDeviceTempVibrationThreshold:(MTWristbandPeripheral *)per {
    [MTCommand readDeviceTempVibrationThreshold:per handler:^(int value) {
        if (value != -1) {
            NSLog(@"readDeviceTempVibrationThreshold successfully,the tempVibrationThreshold is %d",value);
        } else {
            NSLog(@"readDeviceTempVibrationThreshold failed");
        }
    }];
}
#pragma mark *******************************ota

- (void)ota:(MTWristbandPeripheral *)per {
    NSData *targetData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PS2009_NV900_20201029_debug_b8_ota_v3_2_3" ofType:@".bin"]];
    [MTCommand ota:per fileData:targetData handler:^(bool status, double progress) {
        if (status) {
            if (progress == 1) {
                NSLog(@"ota successfully");
            }
            else {
                NSLog(@"ota loading,progress:%f",progress);
            }
        }
        else {
            NSLog(@"ota  failed");
        }
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
