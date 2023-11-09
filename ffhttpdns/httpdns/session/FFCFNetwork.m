#import "FFCFNetwork.h"
#import <objc/runtime.h>

static char * const BaseEvaluatedStream = "FF_EvaluatedStream";

@interface FFCFNetwork()<NSStreamDelegate>
@property (nonatomic, copy) NSMutableURLRequest *mutableRequest;
@property(nonatomic, strong) NSInputStream *inputStream;
@property(nonatomic, strong) NSRunLoop *runloop;
@property(nonatomic, strong) NSTimer *timer;
@end

@implementation FFCFNetwork


-(void)startLoadingWithRequest:(NSURLRequest *)request{
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

/// 设置 CFNetwork 超时时间
- (void)setupTimer {
    if (!self.timer) {
        __weak __typeof(self)weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.mutableRequest.timeoutInterval repeats:NO block:^(NSTimer * _Nonnull timer) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            // 超时了关闭当前流
            [strongSelf closeStream:strongSelf.inputStream];
            // 返回一个超时错误给上层
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"CFDNSProtocol请求超时", NSLocalizedDescriptionKey, @"失败原因：请求超时", NSLocalizedFailureReasonErrorKey, @"恢复建议：请检查当前网络环境",NSLocalizedRecoverySuggestionErrorKey,nil];
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:-1001 userInfo:userInfo];
            if(strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(error:)]) {
                [strongSelf.delegate error:error];
            }
        }];
    }
    [self.runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
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
    [self setupTimer];
}



- (void)closeStream:(NSStream *)aStream {
    [self.timer invalidate];
    self.timer = nil;
    [aStream removeFromRunLoop:self.runloop forMode:NSRunLoopCommonModes];
    [aStream setDelegate:nil];
    [aStream close];
    [self.delegate didfinishTask];
}


#pragma mark - NSStreamDelegate

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable: {
            if(![aStream isKindOfClass:[NSInputStream class]]) {
                break;
            }
            NSInputStream *inputStream = (NSInputStream *) aStream;
            CFReadStreamRef readStream = (__bridge CFReadStreamRef) inputStream;
            
            // 响应头完整性校验
            CFHTTPMessageRef messageRef = (CFHTTPMessageRef) CFReadStreamCopyProperty(readStream, kCFStreamPropertyHTTPResponseHeader);
            CFAutorelease(messageRef);
            if (!CFHTTPMessageIsHeaderComplete(messageRef)) {
                return;
            }
            CFIndex statusCode = CFHTTPMessageGetResponseStatusCode(messageRef);
            // https校验过了，直接读取数据
            if ([self hasEvaluatedStreamSuccess:aStream]) {
                [self readStreamData:inputStream];
            } else {
                // 添加校验标记
                objc_setAssociatedObject(aStream,
                                         BaseEvaluatedStream,
                                         @(YES),
                                         OBJC_ASSOCIATION_RETAIN);

                if ([self evaluateStreamSuccess:aStream]) {     // 校验成功，则读取数据
                    // 非重定向
                    if (![self isRedirectCode:statusCode]) {
                        // 读取响应头
                        [self readStreamHeader:messageRef];

                        // 读取响应数据
                        [self readStreamData:inputStream];
                    } else {    // 重定向
                        // 关闭流
                        [self closeStream:aStream];

                        // 处理重定向
                        [self handleRedirect:messageRef];
                    }
                } else {
                    // 校验失败，关闭stream
                    [self closeStream:aStream];
                    NSError *error = [[NSError alloc] initWithDomain:@"fail to evaluate the server trust" code:-1 userInfo:nil];
                    [self.delegate error:error];
                }
            }
            
        }
            break;
        case NSStreamEventErrorOccurred:{
            [self closeStream:aStream];
            // 回调error
        }
            break;
        case NSStreamEventEndEncountered:{
            // 关闭请求
            [self closeStream:aStream];
        }
            
            break;
        case NSStreamEventOpenCompleted:{}
            break;
        default:
            break;
    }
}

/// 判断是否已经校验 https ssl 证书信任
/// - Parameter aStream: 数据流对象
/// - Returns: YES 已校验，可信，NO 未校验
- (BOOL)hasEvaluatedStreamSuccess:(NSStream *)aStream {
    NSNumber *hasEvaluated = objc_getAssociatedObject(aStream, BaseEvaluatedStream);
    if (hasEvaluated && hasEvaluated.boolValue) {
        return YES;
    }
    return NO;
}

/// 校验 https ssl 是否信任
/// - Parameter aStream: 数据流对象
/// - Returns: YES 可信，NO 不可信任
- (BOOL)evaluateStreamSuccess:(NSStream *)aStream {
    NSString *scheme = [[self.mutableRequest  URL] scheme];
    // http不用校验
    if ([scheme isEqualToString:@"http"]) {
        return YES;
    }
    // 拿到ssl握手结果
    SecTrustRef trust = (__bridge SecTrustRef) [aStream propertyForKey:(__bridge NSString *) kCFStreamPropertySSLPeerTrust];
    // 设置一个初始校验结果（无效设置）
    SecTrustResultType res = kSecTrustResultInvalid; // kSecTrustResultInvalid
    NSMutableArray *policies = [NSMutableArray array];
    NSString *domain = [[self.mutableRequest allHTTPHeaderFields] valueForKey:@"Host"];
    // 返回当前域名的评估SSL证书链的策略对象
    if (domain) {
        [policies addObject:(__bridge_transfer id) SecPolicyCreateSSL(true, (__bridge CFStringRef) domain)];
    } else {
        NSString *host = [[self.mutableRequest URL] host];
        [policies addObject:(__bridge_transfer id) SecPolicyCreateSSL(true, (__bridge CFStringRef) host)];
    }
    // 设置信任
    SecTrustSetPolicies(trust, (__bridge CFArrayRef) policies);
    // 校验结果
    OSStatus status = SecTrustEvaluate(trust, &res);
    if (status != errSecSuccess) {
        return NO;  // 如果有任何报错就返回失败
    }
    if (res != kSecTrustResultProceed && res != kSecTrustResultUnspecified) {
        return NO;  // 隐式信任，用户信任意图不明确，所以返回校验失败
    }
    return YES;
}



/// 读取数据流 和告诉客户端协议已经加载数据同步
/// - Parameter aInputStream: 数据流对象
- (void)readStreamData:(NSInputStream *)aInputStream {
    UInt8 buffer[16 * 1024];
    UInt8 *buf = NULL;
    NSUInteger length = 0;

    // 从stream读数据
    if (![aInputStream getBuffer:&buf length:&length]) {
        NSInteger amount = [self.inputStream read:buffer maxLength:sizeof(buffer)];
        buf = buffer;
        length = amount;
    }
    NSData *data = [[NSData alloc] initWithBytes:buf length:length];

    // 数据上报
    [self.delegate successWithData:data];
}

/// 是否重定向的状态码 [300, 400)
/// - Parameter statusCode: http 状态码
- (BOOL)isRedirectCode:(NSInteger)statusCode {
    if (statusCode >= 300 && statusCode < 400) {
        return YES;
    }
    return NO;
}

/// 读取数据流 和告诉客户端协议已经为请求创建了一个响应对象
/// - Parameter message: 响应头信息引用
- (void)readStreamHeader:(CFHTTPMessageRef )message {
    // 读取响应头
    CFDictionaryRef headerFieldsRef = CFHTTPMessageCopyAllHeaderFields(message);
    NSDictionary *headDict = (__bridge_transfer NSDictionary *)headerFieldsRef;

    // 读取http version
    CFStringRef httpVersionRef = CFHTTPMessageCopyVersion(message);
    NSString *httpVersion = (__bridge_transfer NSString *)httpVersionRef;

    // 读取状态码
    CFIndex statusCode = CFHTTPMessageGetResponseStatusCode(message);

    // 非重定向的数据，才上报
    if (![self isRedirectCode:statusCode]) {
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.mutableRequest.URL statusCode:statusCode HTTPVersion: httpVersion headerFields:headDict];
        [self.delegate successWithResponse:response];
    }
}

/// 处理重定向
/// - Parameter messageRef: 响应头信息引用
- (void)handleRedirect:(CFHTTPMessageRef )messageRef {
    // 响应头
    CFDictionaryRef headerFieldsRef = CFHTTPMessageCopyAllHeaderFields(messageRef);
    NSDictionary *headDict = (__bridge_transfer NSDictionary *)headerFieldsRef;

    // 响应头的loction
    NSString *location = headDict[@"Location"];
    if (!location) {
        location = headDict[@"location"];
    }
    NSURL *redirectUrl = [[NSURL alloc] initWithString:location];

    // 读取http version
    CFStringRef httpVersionRef = CFHTTPMessageCopyVersion(messageRef);
    NSString *httpVersion = (__bridge_transfer NSString *)httpVersionRef;

    // 读取状态码
    CFIndex statusCode = CFHTTPMessageGetResponseStatusCode(messageRef);

    // 生成response
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:self.mutableRequest.URL statusCode:statusCode HTTPVersion: httpVersion headerFields:headDict];

    // 上层实现了redirect协议，则回调到上层
    // 否则，内部进行redirect
    if(![self.delegate redirect:redirectUrl response:response]) {
        [self doRedirect:headDict];
    }
}

/// 内部重定向
/// - Parameter headDict: 响应头信息字典
- (void)doRedirect:(NSDictionary *)headDict {
    // 读取重定向的location，设置成新的url
    NSString *location = headDict[@"Location"];
    if (!location) {
        location = headDict[@"location"];
    }
    NSURL *url = [[NSURL alloc] initWithString:location];
    self.mutableRequest.URL = url;

    // 根据RFC文档，当重定向请求为POST请求时，要将其转换为GET请求
    if ([[self.mutableRequest.HTTPMethod lowercaseString] isEqualToString:@"post"]) {
        self.mutableRequest.HTTPMethod = @"GET";
        self.mutableRequest.HTTPBody = nil;
    }

    [self startRequest];
}

#pragma mark - retry/重试逻辑
- (void)retry {
    
}

@end
