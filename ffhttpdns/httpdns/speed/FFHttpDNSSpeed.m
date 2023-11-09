#import "FFHttpDNSSpeed.h"
//#import <sys/socket.h>
//#import <netinet/in.h>
//#import <fcntl.h>
//#import <arpa/inet.h>
//#import <netdb.h>

@implementation FFHttpDNSSpeed

+(int)speedOf:(NSString *)ip {
    float rtt = 0.0;
//    int s = 0;
//    struct sockaddr_in saddr;
//    saddr.sin_family = AF_INET;
//    saddr.sin_port  = htons(80);
//    saddr.sin_addr.s_addr  = inet_addr([ip UTF8String]);
//    if ((s = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
//        return 0;
//    }
//    NSDate *startTime = [NSDate date];
//    NSDate *endTime;
//    int flags = fcntl(s, F_GETFL, 0);
//    fcntl(s, F_SETFL, flags | O_NONBLOCK);
//    int i = connect(s, (struct sockaddr *) &saddr, sizeof(saddr));
//    if (i == 0) {
//        close(s);
//        return 1;
//    }
//
//    struct timeval tv;
//    fd_set myset;
//    int valopt;
//    socklen_t lon;
//    tv.tv_sec = 10;
//    tv.tv_usec = 0;
//    FD_ZERO(&myset);
//    FD_SET(s, &myset);
//
//    int j = select(s+1, NULL, &myset, NULL, &tv);
//    if (j > 0) {
//        lon = sizeof(int);
//        getsockopt(s, SOL_SOCKET, SO_ERROR, (void*)(&valopt), &lon);
//        if (valopt) {
//            rtt = 0;
//        } else {
//            endTime = [NSDate date];
//            rtt = [endTime timeIntervalSinceDate:startTime] * 1000;
//        }
//    } else if (j == 0) {
//        rtt = 60000;
//    } else {
//        rtt = 0;
//    }
//    close(s);
    return rtt;
}
@end
