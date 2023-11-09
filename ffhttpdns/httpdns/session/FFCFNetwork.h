#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FFCFNetworkDelegate <NSObject>
-(void)error:(NSError *)error;
-(BOOL)redirect:(NSURL *)redirectUrl response:(NSHTTPURLResponse *)resp;
-(void)successWithData:(NSData *)data;
-(void)successWithResponse:(NSURLResponse *)resp;
-(void)didfinishTask;
@end

// 用于在protocol中发起请求用的
@interface FFCFNetwork : NSObject
@property (nonatomic, weak)id<FFCFNetworkDelegate> delegate;
-(void)startLoadingWithRequest:(NSURLRequest *)request;
@end

NS_ASSUME_NONNULL_END
