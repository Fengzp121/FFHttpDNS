#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 用于给httpdns解析ip列表用的session
@interface FFURLSession : NSObject
+(id)sharedInstance;
@end

NS_ASSUME_NONNULL_END
