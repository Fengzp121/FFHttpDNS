#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
// 用于在protocol中发起请求用的
@interface FFCFNetwork : NSObject
-(void)startLoadingWithRequest:(NSURLRequest *)request complete:(void(^)(NSData *data, NSURLResponse *resp, NSError *error))complete;
@end

NS_ASSUME_NONNULL_END
