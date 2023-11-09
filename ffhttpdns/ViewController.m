//
//  ViewController.m
//  ffhttpdns
//
//  Created by ffzp on 2023/11/8.
//

#import "ViewController.h"
#import "FFHttpDNS.h"
@interface ViewController ()<FFHttpDNSAdaptorDelegate>
@property (nonatomic, strong)UIButton *btn;
@property (nonatomic, strong)NSURLSession *session;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setSubView];
    [self registSession];
    [FFHttpDNSAdaptorDelegate setUpDelegate:self];
}

-(void)setSubView {
    _btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 60)];
    [_btn setTitle:@"请求" forState:UIControlStateNormal];
    [_btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_btn];
}

-(void)registSession{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setProtocolClasses:@[FFHTTPDNSURLProtocol.class]];
    _session = [NSURLSession sessionWithConfiguration:config];
}

-(void)clickBtn:(UIButton *)sender {
    NSURLSessionTask *task = [_session dataTaskWithURL:[NSURL new] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    [task resume];
}

-(void)beforeRequest {
    
}

-(void)readyRequest {
    
}

-(void)startRequest {
    
}

-(void)endRequest {
    
}

@end
