#import "FFHTTPDNSURLProtocol.h"
#import "FFHttpDNSAdaptor.h"
#import "FFCFNetwork.h"
@implementation FFHTTPDNSURLProtocol

+(BOOL)canInitWithRequest:(NSURLRequest *)request {
    [[FFHttpDNSAdaptor sharedInstance] beforeRequest];
    return YES;
}

+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    [[FFHttpDNSAdaptor sharedInstance] readyRequest];
    return request;
}


-(void)startLoading {
    [[FFHttpDNSAdaptor sharedInstance] startRequest];
    FFCFNetwork *net = [FFCFNetwork new];
    [net startLoadingWithRequest:self.request complete:^(id  _Nonnull data, NSError * _Nonnull error) {
        
    }];
}

-(void)stopLoading {
    [[FFHttpDNSAdaptor sharedInstance] endRequest];
}

@end
