#import <Foundation/Foundation.h>
#import "FFIPType.h"
NS_ASSUME_NONNULL_BEGIN

@interface FFIPModel : NSObject
@property(nonatomic, copy) NSString *ip;
@property(nonatomic, assign) NSInteger *weight;
@property(nonatomic, assign) FFIPTypeENUM ipType;
@end

NS_ASSUME_NONNULL_END
