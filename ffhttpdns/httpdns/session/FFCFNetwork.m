#import "FFCFNetwork.h"

@interface FFCFNetwork()<NSStreamDelegate>
@property (nonatomic, copy) NSMutableURLRequest *mutableRequest;
@property(nonatomic, strong) NSInputStream *inputStream;
@property(nonatomic, strong) NSRunLoop *runloop;

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
}

/// 添加  CFNetwork 请求头
- (void)addHeadersToRequestRef:(CFHTTPMessageRef)requestRef {
    // 遍历请求头，将数据塞到requestRef
    // 不包含POST请求时存放在header的body信息
    NSDictionary *headFields = self.mutableRequest.allHTTPHeaderFields;
    for (NSString *header in headFields) {
        CFStringRef requestHeader = (__bridge CFStringRef) header;
        CFStringRef requestHeaderValue = (__bridge CFStringRef) [headFields valueForKey:header];
        CFHTTPMessageSetHeaderFieldValue(requestRef, requestHeader, requestHeaderValue);
    }
}

/// 设置 CFNetwork Runloop
- (void)setupRunloop {
    // 保存当前线程的runloop，这对于重定向的请求很关键
    if (!self.runloop) {
        self.runloop = [NSRunLoop currentRunLoop];
    }

    // 将请求放入当前runloop的事件队列
    [self.inputStream scheduleInRunLoop:self.runloop forMode:NSRunLoopCommonModes];
}

/// 创建 CFNetwork 请求
- (CFHTTPMessageRef)createCFRequest {
    // 创建url
    CFStringRef urlStringRef = (__bridge CFStringRef) [self.mutableRequest.URL absoluteString];
    CFURLRef urlRef = CFURLCreateWithString(kCFAllocatorDefault, urlStringRef, NULL);
    CFAutorelease(urlRef);

    // 读取HTTP method
    CFStringRef methodRef = (__bridge CFStringRef) self.mutableRequest.HTTPMethod;

    // 创建request
    CFHTTPMessageRef requestRef = CFHTTPMessageCreateRequest(kCFAllocatorDefault, methodRef, urlRef, kCFHTTPVersion1_1);

    return requestRef;
}

/// 开启 CFNetwork 请求
-(void)startRequest {
    // 创建请求
    CFHTTPMessageRef requestRef = [self createCFRequest];
    CFAutorelease(requestRef);

    // 添加请求头
    [self addHeadersToRequestRef:requestRef];

    // 添加请求体
    [self addBodyToRequestRef:requestRef];

    // 创建CFHTTPMessage对象的输入流
    CFReadStreamRef readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, requestRef);
    
    // 设置代理
    [self setupProxy:readStream];
    self.inputStream = (__bridge_transfer NSInputStream *) readStream;

    // 设置SNI
    [self setupSNI];
    [self.inputStream setDelegate:self];
    // 设置Runloop
    [self setupRunloop];

    // 打开输入流
    [self.inputStream open];

    // 设置超时时间
//    [self setupTimer];
}

#pragma mark - NSStreamDelegate

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
}


@end
