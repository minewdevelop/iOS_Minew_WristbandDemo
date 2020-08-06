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
    [per.connector didChangeConnection:^(MTWristbandPeripheral * _Nonnull device, Connection connection) {
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
            MTWristbandPeripheral *p = per;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self writePassword:p];
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
            //then do what you want to.
        }
        else {
            NSLog(@"password is error");
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