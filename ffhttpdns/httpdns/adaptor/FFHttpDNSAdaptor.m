#import "FFHttpDNSAdaptor.h"
@interface FFHttpDNSAdaptor()
@property (nonatomic, weak) id<FFHttpDNSAdaptorDelegate> delegate;
@end

@implementation FFHttpDNSAdaptor
+(id)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FFHttpDNSAdaptor alloc] init];
    });
    return instance;
}

-(void)setUpDelegate:(id<FFHttpDNSAdaptorDelegate>)delegate{
    _delegate = delegate;
}

-(void)beforeRequest{
    if(_delegate && [_delegate respondsToSelector:@selector(beforeRequest)]) {
        [_delegate beforeRequest];
    }
}

-(void)readyRequest{
    if(_delegate && [_delegate respondsToSelector:@selector(readyRequest)]) {
        [_delegate readyRequest];
    }
}

-(void)startRequest{
    if(_delegate && [_delegate respondsToSelector:@selector(startRequest)]) {
        [_delegate startRequest];
    }
}

-(void)endRequest{
    if(_delegate && [_delegate respondsToSelector:@selector(endRequest)]) {
        [_delegate endRequest];
    }
}
@end
