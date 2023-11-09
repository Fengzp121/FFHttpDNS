#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFHttpDNSIPSort : NSObject
/// 检测ip的延迟
/// - Parameter ips: ip列表
-(void)sortIP:(NSArray<NSString *> *)ips;
@end

NS_ASSUME_NONNULL_END
