#import <Foundation/Foundation.h>
#import "FFHttpDNSAdaptorDelegate.h"
NS_ASSUME_NONNULL_BEGIN

// 对外切面的
@interface FFHttpDNSAdaptor : NSObject

+(id)sharedInstance;

-(void)setUpDelegate:(id<FFHttpDNSAdaptorDelegate>)delegate;

-(void)beforeRequest;
-(void)readyRequest;
-(void)startRequest;
-(void)endRequest;
@end

NS_ASSUME_NONNULL_END
