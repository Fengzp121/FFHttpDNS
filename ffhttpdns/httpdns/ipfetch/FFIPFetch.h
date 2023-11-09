#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FFIPFetch : NSObject
// 获取单ip
-(void)updateIPWithparam:(NSDictionary *)param Complete:(void(^)(id data))complete;

// 获取多ip
-(void)updateIPsWithparam:(NSDictionary *)param Complete:(void(^)(id data))complete;
@end

NS_ASSUME_NONNULL_END
