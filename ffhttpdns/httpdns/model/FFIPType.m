#import "FFIPType.h"

@implementation FFIPType

+(NSString *)getValueWithType:(FFIPTypeENUM)type{
    NSString *res = @"";
    switch (type) {
        case IPType_ipv4:
            res = @"A";
            break;
        case IPType_ipv6:
            res = @"AAAA";
            break;
        case IPType_all:
            res = @"ADDDRS";
            break;
        default:
            break;
    }
    return res;
}

@end
