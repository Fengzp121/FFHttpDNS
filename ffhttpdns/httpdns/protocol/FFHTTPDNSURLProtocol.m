#import "FFHTTPDNSURLProtocol.h"
#import "FFHttpDNSAdaptor.h"
#import "FFCFNetwork.h"
#import "FFHttpDNSTool.h"
static NSString *protocol_key = @"FFHTTPDNSURLProtocol";
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
    [net startLoadingWithRequest:mutableRequest complete:^(NSData * data, NSURLResponse * resp, NSError * error) {
        if(error) {
            [self.client URLProtocol:self didFailWithError:error];
        } else {
            if(data) {
                [self.client URLProtocol:self didLoadData:data];
            }
            if(resp) {
                [self.client URLProtocol:self didReceiveResponse:resp cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];
            }
        }
        [self.client URLProtocolDidFinishLoading:self];
    }];
}

-(void)stopLoading {
    [[FFHttpDNSAdaptor sharedInstance] endRequest];
}

@end
