#import "FFURLSession.h"
#import "FFHttpDNSConfig.h"
#import "FFURLSession+Helper.h"
@interface FFURLSession()<NSURLSessionDelegate>
//@property(nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableSet<NSString *> *urls;
@property (nonatomic, strong) NSMutableArray<NSURLRequest *> *requests;
@end

@implementation FFURLSession

+(id)sharedInstance{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(instancetype)init{
    if([super self]){
        _urls = [NSMutableSet set];
    }
    return self;
}


-(void)config:(NSMutableSet<NSString *> *)urls {
    self.urls = [urls copy];
}

-(void)requestWithParam:(NSDictionary *)param complete:(void(^)(id data ,int code, NSString * message))complete{
    NSURLSession *session = [self buildSession];
    NSURLRequest *request = [self buildRequest];
    [self.requests addObject:request];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    [task resume];
    
}

-(NSURLSession *)buildSession {
    NSURLSession *session = nil;
    if([[FFHttpDNSConfig sharedInstance] httpType] == FFHTTPS) {
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }else {
        session = [NSURLSession sharedSession];
    }
    return session;
}

// 解决https证书信任问题
-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    NSString *authMethod = [[challenge protectionSpace] authenticationMethod];
    NSURLSessionAuthChallengeDisposition type = NSURLSessionAuthChallengeUseCredential;
    NSURLCredential *credential = nil;
    if([authMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        credential = [[NSURLCredential alloc] initWithTrust:[[challenge protectionSpace] serverTrust]];
    } else {
        type = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    completionHandler(type, credential);
}


@end
