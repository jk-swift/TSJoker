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

/**
 注册域名(建议在 didFinishLaunching 时执行,当且仅当第一次设置时有效)
 @params host     - 域名
*/
+ (void)registerWithHost:(NSString *)host;

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
