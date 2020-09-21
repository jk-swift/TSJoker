//
//  TSJoker.h
//  Pods-TSJoker_Example
//
//  Created by Think on 2020/9/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TSSuccess)(NSDictionary *);
typedef void (^TSFailed)(NSError *);

@interface TSJoker : NSObject

+ (void)registerWithHost:(NSString *)host;

/**
 同步拉取在线参数
 @params params     - 拉取参数
 @params success    - 成功闭包
 @params failed     - 失败闭包
 */
+ (void)syncFetchWithParams:(nullable NSDictionary *)params
                    success:(TSSuccess)success
                     failed:(TSFailed)failed;

/**
 异步拉取在线参数
 @params params     - 拉取参数
 @params success    - 成功闭包
 @params failed     - 失败闭包
 */
+ (void)asyncFetchWithParams:(nullable NSDictionary *)params
                     success:(TSSuccess)success
                      failed:(TSFailed)failed;

@end

NS_ASSUME_NONNULL_END
