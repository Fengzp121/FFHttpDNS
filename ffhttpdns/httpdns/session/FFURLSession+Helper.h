#import "FFURLSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface FFURLSession (Helper)
-(NSURLRequest *)buildRequest;
-(NSString *)buildURL:(NSString *)host api:(NSString *)api param:(NSString *)param;
-(NSString *)buildParam:(NSDictionary *)dict;
-(BOOL)vaildJson:(NSDictionary *)json;
@end

NS_ASSUME_NONNULL_END
