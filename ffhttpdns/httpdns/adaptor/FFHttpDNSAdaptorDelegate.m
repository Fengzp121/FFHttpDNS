#import "FFHttpDNSAdaptorDelegate.h"
#import "FFHttpDNSAdaptor.h"

@implementation FFHttpDNSAdaptorDelegate
+(void)setUpDelegate:(id<FFHttpDNSAdaptorDelegate>)delegate{
    [[FFHttpDNSAdaptor sharedInstance] setUpDelegate:delegate];
}
@end
