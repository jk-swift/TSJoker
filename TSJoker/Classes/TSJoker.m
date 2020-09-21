//
//  TSJoker.m
//  Pods-TSJoker_Example
//
//  Created by Think on 2020/9/21.
//

#import "TSJoker.h"

#define SHARED_JOKER    [TSJoker shared]

@interface TSJoker ()

@property (nonatomic, copy) NSString    *host;

@end

@implementation TSJoker

+ (TSJoker *)shared
{
    static TSJoker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TSJoker alloc] init];
    });
    return instance;
}

+ (void)registerWithHost:(NSString *)host
{
    NSCAssert([host length] > 0, @"Error: host is empty...");
    NSCAssert(SHARED_JOKER.host == nil, @"Error: host has been registered...");
    
    SHARED_JOKER.host = host;
}

+ (void)syncFetchWithParams:(nullable NSDictionary *)params
                    success:(TSSuccess)success
                     failed:(TSFailed)failed
{
    [SHARED_JOKER requestWithParams:params success:^(NSDictionary * dict) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (success) {
                success(dict);
            }
        });
    } failed:^(NSError * error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (failed) {
                failed(error);
            }
        });
    }];
}

+ (void)asyncFetchWithParams:(nullable NSDictionary *)params
                     success:(TSSuccess)success
                      failed:(TSFailed)failed
{
    [SHARED_JOKER requestWithParams:params success:^(NSDictionary * dict) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                success(dict);
            }
        });
    } failed:^(NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failed) {
                failed(error);
            }
        });
    }];
}

- (void)requestWithParams:(NSDictionary *)params success:(TSSuccess)success failed:(TSFailed)failed
{
    NSURL *url = [NSURL URLWithString:_host];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:10];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *postStr = [self parseParams:params];
    [request setHTTPBody:[postStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failed(error);
            return;
        }
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSInteger code = [dic[@"code"] integerValue];
        
        if (code != 200) {
            NSString *msg = [dic[@"msg"] description];
            NSError *err = [NSError errorWithDomain:@"com.tsjoker.www" code:code userInfo:@{NSLocalizedFailureReasonErrorKey: msg}];
            failed(err);
            return;
        }
        
        success(dic);
    }];
    [dataTask resume];
}

- (NSString *)parseParams:(NSDictionary *)params
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:params];
    
    [parameters setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] forKey:@"bundle_id"];
    [parameters setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] forKey:@"build_no"];
    
    for (NSString *key in params) {
        NSLog(@"%@ : %@", key, [params objectForKey:key]);
        [parameters setValue:[params objectForKey:key] forKey:key];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:[parameters copy] options:NSJSONWritingPrettyPrinted error:nil];

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
