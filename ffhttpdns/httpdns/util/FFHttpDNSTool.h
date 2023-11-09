#import <Foundation/Foundation.h>
#import "FFDNSModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FFHttpDNSTool : NSObject

+(BOOL)checkIfNeedProtect:(NSString *)host;
//+(NSString *)randomIP:(FFDNSModel *)model type

@end

NS_ASSUME_NONNULL_END
