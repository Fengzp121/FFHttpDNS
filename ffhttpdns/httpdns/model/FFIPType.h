#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FFIPTypeENUM) {
    IPType_ipv4 = 0,
    IPType_ipv6,
    IPType_all,
};

@interface FFIPType : NSObject
+ (NSString *)getValueWithType:(FFIPTypeENUM)type;
@end

NS_ASSUME_NONNULL_END
