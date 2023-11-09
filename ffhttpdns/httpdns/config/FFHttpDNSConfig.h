#import <Foundation/Foundation.h>
#import "FFIPType.h"
#import "FFHttpType.h"
NS_ASSUME_NONNULL_BEGIN

@interface FFHttpDNSConfig : NSObject

@property (nonatomic,strong) NSMutableArray<NSString *> *dnsRemoteURLs;
@property (nonatomic, strong) NSMutableArray<NSString *> *dnsRemoteUrlCache;
@property (nonatomic,copy) NSString *dnsRemoteHosts;

@property (nonatomic, strong) NSMutableSet<NSString *> *whiteSet;
@property (nonatomic, strong) NSMutableSet<NSString *> *mainHost;

@property (nonatomic, copy) NSString *dnsSaveKey;

@property (nonatomic, copy) NSString *appid;
@property (nonatomic, copy) NSString *secret;

@property (nonatomic, assign) FFIPTypeENUM ipType;
@property (nonatomic, assign) FFHttpTypeENUM httpType;

+(id)sharedInstance;
-(void)updateConfig;
@end

NS_ASSUME_NONNULL_END
