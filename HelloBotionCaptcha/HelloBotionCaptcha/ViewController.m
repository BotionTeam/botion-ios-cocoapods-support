//
//  ViewController.m
//  HelloBotionCaptcha
//
//  Created by noctis on 2023/4/27.
//

#import "ViewController.h"
#import <BotionCaptcha/BotionCaptcha.h>

/// CaptchaID you or your company applied for
#define CaptchaID @"f46f146d6e611d0af5e51d5187e86f57"

/// 请填入你的校验接口地址
#define VerifyAPI @"http://..."

@interface ViewController ()<BotionCaptchaSessionTaskDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *changeBgColor;


@property (nonatomic, strong) BotionCaptchaSession *captchaSession;

@end

@implementation ViewController

- (BotionCaptchaSession *)captchaSession {
    if (!_captchaSession) {
        
        BotionCaptchaSessionConfiguration *config = [BotionCaptchaSessionConfiguration defaultConfiguration];
//        config.resourcePath = @"https://static.botion.com/v1/boc-index.html";
//        config.backgroundColor = [UIColor blackColor];
        
        config.language = @"en";
        _captchaSession = [BotionCaptchaSession sessionWithCaptchaID:CaptchaID configuration:config];
        _captchaSession.delegate = self;
        
        NSLog(@"init time: %.0f", [[NSDate date] timeIntervalSince1970] * 1000);
    }
    
    return _captchaSession;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self randomChangeBackgroundColor];
    
    [self captchaSession];
    
    [self.startBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];

    [self.changeBgColor addTarget:self action:@selector(randomChangeBackgroundColor) forControlEvents:UIControlEventTouchUpInside];
}

- (void)start {
    NSLog(@"Did start");
    [self.captchaSession verify];
}

- (void)randomChangeBackgroundColor {
    UIColor *color = [self randomColor];
    self.view.backgroundColor = color;
}

- (UIColor *)randomColor {
    static NSArray<UIColor *> *colors = nil;
    if (!colors) {
        colors = @[
            [UIColor blackColor],
            [UIColor whiteColor],
            [UIColor redColor],
            [UIColor greenColor],
            [UIColor blueColor],
            [UIColor grayColor],
            [UIColor purpleColor],
            [UIColor yellowColor],
            [UIColor brownColor]
        ];
    }
    
    return colors[arc4random() % colors.count];
}

- (void)showAlertController:(NSString *)title message:(NSString *)message {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:okAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertVC animated:YES completion:nil];
    });
}

#pragma mark BotionCaptchaSessionTaskDelegate

- (void)botionCaptchaSession:(BotionCaptchaSession *)captchaSession didReceive:(NSString *)code result:(NSDictionary *)result {
    NSLog(@"result: %@", result);
    if ([@"1" isEqualToString:code]) {
        if (result && result.count > 0) {
            
            BOOL offline = [result[@"offline"] boolValue];
            if (offline) {
                NSLog(@"自定义宕机模式模式");
            }
            
            __block NSMutableArray<NSString *> *kvPairs = [NSMutableArray array];
            
            [result enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([key isKindOfClass:[NSString class]] &&
                    [obj isKindOfClass:[NSString class]]) {
                    NSString *kvPair = [NSString stringWithFormat:@"%@=%@", key, obj];
                    [kvPairs addObject:kvPair];
                }
            }];
            
            NSString *formStr = [kvPairs componentsJoinedByString:@"&"];
            NSData *data = [formStr dataUsingEncoding:NSUTF8StringEncoding];
            
            NSURL *url = [NSURL URLWithString:VerifyAPI];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            request.HTTPMethod  = @"POST";
            request.HTTPBody    = data;
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (!error && data) {
                    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    [self showAlertController:@"二次校验结果" message:msg];
                }
                else {
                    NSLog(@"error: %@", error);
                    [self showAlertController:@"二次校验结果" message:error.description];
                }
            }] resume];
        }
    }
    else {
        NSLog(@"请正确完成验证码");
    }
}

- (void)botionCaptchaSession:(BotionCaptchaSession *)captchaSession didReceiveError:(BOCError *)error {
    NSLog(@"error: %@", error.description);
    if ([error.code isEqualToString:BOCErrorCodeUserDidCancel]) {
        [self showAlertController:@"验证会话被取消" message:error.description];
    }
    else {
        [self showAlertController:@"验证会话错误" message:error.description];
    }
}



@end
