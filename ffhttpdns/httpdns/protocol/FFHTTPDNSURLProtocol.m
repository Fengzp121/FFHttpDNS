#import "FFHTTPDNSURLProtocol.h"
#import "FFHttpDNSAdaptor.h"
#import "FFCFNetwork.h"
#import "FFHttpDNSTool.h"


static NSString * const protocol_key = @"FFHTTPDNSURLProtocol";

@interface FFHTTPDNSURLProtocol()<FFCFNetworkDelegate>

@end

@implementation FFHTTPDNSURLProtocol


+(BOOL)canInitWithRequest:(NSURLRequest *)request {
    [[FFHttpDNSAdaptor sharedInstance] beforeRequest];
    if([NSURLProtocol propertyForKey:protocol_key inRequest:request] != NULL) {
        return NO;
    }
    if(![FFHttpDNSTool checkIfNeedProtect:request.URL.host]) {
        return NO;
    }
    return YES;
}

+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    [[FFHttpDNSAdaptor sharedInstance] readyRequest];
    return request;
}


-(void)startLoading {
    [[FFHttpDNSAdaptor sharedInstance] startRequest];
    NSMutableURLRequest *mutableRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@(YES) forKey:protocol_key inRequest:mutableRequest];
    FFCFNetwork *net = [FFCFNetwork new];
    net.delegate = self;
    [net startLoadingWithRequest:mutableRequest];
}

-(void)stopLoading {
    [[FFHttpDNSAdaptor sharedInstance] endRequest];
}


#pragma mark - FFCFNetworkDelegate
-(void)successWithData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

-(BOOL)redirect:(NSURL *)redirectUrl response:(NSHTTPURLResponse *)resp{
    // 检查上层是否实现了redirect协议，则回调到上层
    BOOL res = [self.client respondsToSelector:@selector(URLProtocol:wasRedirectedToRequest:redirectResponse:)];
    if(res) {
        [self.client URLProtocol:self
          wasRedirectedToRequest:[NSURLRequest requestWithURL:redirectUrl]
                redirectResponse:resp];
    }
    return res;
}

-(void)successWithResponse:(NSURLResponse *)resp {
    [self.client URLProtocol:self didReceiveResponse:resp cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];
}

-(void)error:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

-(void)didfinishTask {
    [self.client URLProtocolDidFinishLoading:self];
}
@end
