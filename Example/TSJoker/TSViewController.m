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
    [TSJoker syncFetchWithParams:nil success:^(NSDictionary * dict) {
        NSLog(@"%@", dict);
    } failed:^(NSError * error) {
        NSLog(@"%@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
