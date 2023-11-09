#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FFHttpDNSAdaptorDelegate <NSObject>
-(void)beforeRequest;
-(void)readyRequest;
-(void)startRequest;
-(void)endRequest;
@end

@interface FFHttpDNSAdaptorDelegate : NSObject
+(void)setUpDelegate:(id<FFHttpDNSAdaptorDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
