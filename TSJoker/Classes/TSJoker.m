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
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *postStr = [self parseParams:params];
    [request setHTTPBody:[postStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failed(error);
        } else {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            success(dic);
        }
    }];
    [dataTask resume];
}

- (NSString *)parseParams:(NSDictionary *)params
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:params];
    [parameters setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] forKey:@"bundle_id"];
    [parameters setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] forKey:@"build_no"];
    NSLog(@"请求参数:%@", parameters);

    NSString *keyValueFormat;
    NSMutableString *result = [NSMutableString new];
    NSEnumerator *keyEnum = [parameters keyEnumerator];
    id key;
    while (key = [keyEnum nextObject]) {
        keyValueFormat = [NSString stringWithFormat:@"%@=%@&", key, [params valueForKey:key]];
        [result appendString:keyValueFormat];
    }
    return result;
}

@end
