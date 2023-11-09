#import "FFHttpDNSConfig.h"

@implementation FFHttpDNSConfig
+(id)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(void)updateConfig {
    
}
@end
