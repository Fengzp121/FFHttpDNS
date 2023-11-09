//
//  FFDNSModel.h
//  ffhttpdns
//
//  Created by ffzp on 2023/11/9.
//

#import <Foundation/Foundation.h>
#import "FFIPModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FFDNSModel : NSObject
@property (nonatomic,copy) NSString *host;
@property (nonatomic,strong) NSMutableArray<FFIPModel *> *ipv4s;
@property (nonatomic,strong) NSMutableArray<FFIPModel *> *ipv6s;
@property (nonatomic, assign) NSInteger ttl;
@property (nonatomic, assign) BOOL report;
@end

NS_ASSUME_NONNULL_END
