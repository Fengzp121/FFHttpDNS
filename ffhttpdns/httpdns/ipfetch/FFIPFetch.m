#import "FFIPFetch.h"
#import "FFURLSession.h"
#import "FFHttpDNSCache.h"
@implementation FFIPFetch

-(void)updateIPWithparam:(NSDictionary *)param Complete:(void (^)(id _Nonnull))complete{
    [[FFURLSession sharedInstance] updateIPWithparam:param Complete:^(id  _Nonnull data) {
        
        [FFHttpDNSCache save];
    }];
}

-(void)updateIPsWithparam:(NSDictionary *)param Complete:(void (^)(id _Nonnull))complete{
    [[FFURLSession sharedInstance] updateIPsWithparam:param Complete:^(id  _Nonnull data) {
        
        [FFHttpDNSCache save];
    }];
}

@end
