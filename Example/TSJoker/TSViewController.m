//
//  TSViewController.m
//  TSJoker
//
//  Created by Think on 09/21/2020.
//  Copyright (c) 2020 Think. All rights reserved.
//

#import "TSViewController.h"
#import <TSJoker/TSJoker.h>

@interface TSViewController ()

@end

@implementation TSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [TSJoker registerWithHost:@"http://47.95.244.17/api/link/fetch"];
    NSDictionary *params = @{
        @"bundle_id": @"com.momingqihuo.insest",
        @"build_no": @"1.5.1"
    };
    [TSJoker asyncFetchWithParams:params success:^(NSDictionary * dict) {
        NSLog(@"RESULT: %@", dict);
    } failed:^(NSError * error) {
        NSLog(@"RESULT: %@", error);
    }];
    NSLog(@"Hello world!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
