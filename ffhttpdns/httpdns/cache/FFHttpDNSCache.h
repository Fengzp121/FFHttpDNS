#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFHttpDNSCache : NSObject
+(void)save;
+(void)fetch;
@end

NS_ASSUME_NONNULL_END
