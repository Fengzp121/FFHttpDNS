#import "FFURLSession+Helper.h"
#import "FFHttpDNSConfig.h"
@implementation FFURLSession (Helper)



-(NSURLRequest *)buildRequest {
    NSURLRequest *request = nil;
    
    return request;
}

-(NSString *)buildURL:(NSString *)host api:(NSString *)api param:(NSString *)param {
    
    return @"";
}

// 通常都是get请求，所以只需要拼接字符串
-(NSString *)buildParam:(NSDictionary *)dict {
    
    return @"";
}

// 检查是否非法（签名、数据非法、是否为空）
-(BOOL)vaildJson:(NSDictionary *)json {
    return YES;
}
@end
