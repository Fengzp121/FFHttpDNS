#import "FFCFNetwork.h"

@interface FFCFNetwork()
@property (nonatomic, copy) NSMutableURLRequest *mutableRequest;
@property(nonatomic, strong) NSInputStream *inputStream;

// block要保存起来，

@end

@implementation FFCFNetwork


-(void)startLoadingWithRequest:(NSURLRequest *)request complete:(void (^)(NSData *, NSURLResponse *, NSError *))complete {
    self.mutableRequest = [request mutableCopy];
}



/// 添加  CFNetwork 请求体
- (void)addBodyToRequestRef:(CFHTTPMessageRef)requestRef {
    CFStringRef requestBody = CFSTR("");
    CFDataRef bodyDataRef = CFStringCreateExternalRepresentation(kCFAllocatorDefault, requestBody, kCFStringEncodingUTF8, 0);

    uint8_t sub[1024] = {0};
    NSInputStream *inputStream = self.mutableRequest.HTTPBodyStream;
    NSMutableData *body = [[NSMutableData alloc] init];
    [inputStream open];
    while ([inputStream hasBytesAvailable]) {
        NSInteger len = [inputStream read:sub maxLength:1024];
        if (len > 0 && inputStream.streamError == nil) {
            [body appendBytes:(void *)sub length:len];
        }else{
            break;
        }
    }
    [inputStream close];
    bodyDataRef = (__bridge_retained CFDataRef) body;

    // 将body数据塞到requestRef
    CFHTTPMessageSetBody(requestRef, bodyDataRef);
    CFRelease(requestBody);
    CFRelease(bodyDataRef);
}

/// 设置 CFNetwork 代理
- (void)setupProxy:(CFReadStreamRef) readStream{
    NSDictionary *dict = (__bridge_transfer NSDictionary*)CFNetworkCopySystemProxySettings();
    NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
    if (dict[@"HTTPEnable"]) {
        NSString* proxyKey = (NSString *)kCFStreamPropertyHTTPProxyHost;
        NSString* portKey = (NSString *)kCFStreamPropertyHTTPProxyPort;
        mdict[proxyKey] = dict[@"HTTPProxy"];
        mdict[portKey] = dict[@"HTTPPort"];
    }
    
    if (dict[@"HTTPSEnable"]) {
        NSString* sslProxyKey = (NSString *)kCFStreamPropertyHTTPSProxyHost;
        NSString* sslPortKey = (NSString *)kCFStreamPropertyHTTPSProxyPort;
        mdict[sslProxyKey] = dict[@"HTTPSProxy"];
        mdict[sslPortKey] = dict[@"HTTPSPort"];
    }
    if (mdict.count) {
        CFReadStreamSetProperty(readStream, kCFStreamPropertyHTTPProxy, (__bridge_retained CFMutableDictionaryRef)mdict);
    }
}

/// 设置 CFNetwork SNI（Server name indication，服务器名称指示），解决一个服务器 IP 对应多个域名和多个 https 证书问题
- (void)setupSNI {
    // 只处理https
    NSString *urlString = self.mutableRequest.URL.absoluteString;
    if (![urlString hasPrefix:@"https"]) {
        return;
    }

    // 检查是否为IP请求，非ip情况直接返回
//    if (![OCBaseDNSTools checkVaildIp:self.mutableRequest.URL.host]) {
//        return;
//    }

    // 读取请求头中的host
    NSString *host = [self.mutableRequest.allHTTPHeaderFields objectForKey:@"Host"];
    if (!host) {
        host = self.mutableRequest.URL.host;
    }
    // 设置HTTPS的校验策略
    [self.inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
    // 设置SSLPeerName（在SSL握手中加入server name）
    NSDictionary *sslProperties = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   host, (__bridge id) kCFStreamSSLPeerName,
                                   nil];
    [self.inputStream setProperty:sslProperties forKey:(__bridge NSString *) kCFStreamPropertySSLSettings];
//    [[BaseDNSLog shared] putWithReq:self.mutableRequest val:@"BaseCFURLProtocol: 设置SNI场景" errorLog:NO isEnd:NO];
}

@end
