#import "FFHttpDNSCache.h"
#import "FFHttpDNSConfig.h"
@interface FFHttpDNSCache()
@end

@implementation FFHttpDNSCache
+(void)save{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:[FFHttpDNSCache createKey:@""]];
    
}

+(void)fetch{
    
}

+(NSString *)createKey:(NSString *)str {
    NSString *configKey = [[FFHttpDNSConfig sharedInstance] dnsSaveKey];
    NSString *saveKey = [NSString stringWithFormat:@"%@%@",configKey,str];
    return saveKey;
}
@end
