//
//  WKViewController.m
//  JS交互
//
//  Created by 马金丽 on 17/3/16.
//  Copyright © 2017年 majinli. All rights reserved.
//

#import "WKViewController.h"
#import <WebKit/WebKit.h>

@interface WKViewController ()<WKScriptMessageHandler>
@property(nonatomic,strong)WKWebView *wkWebView;
@end

@implementation WKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initWkWebView];
}
//OC调用js里的方法,实现后在传值给js
//初始化页面
- (void)initWkWebView
{
    //进行配置控制器
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
    //实例化对象
    configuration.userContentController = [[WKUserContentController alloc]init];
    //调用JS方法
    [configuration.userContentController addScriptMessageHandler:self name:@"ScanAction"];
    [configuration.userContentController addScriptMessageHandler:self name:@"Share"];
    [configuration.userContentController addScriptMessageHandler:self name:@"Location"];
    [configuration.userContentController addScriptMessageHandler:self name:@"Color"];
    [configuration.userContentController addScriptMessageHandler:self name:@"Pay"];
    [configuration.userContentController addScriptMessageHandler:self name:@"Shake"];
    [configuration.userContentController addScriptMessageHandler:self name:@"GoBack"];
    [configuration.userContentController addScriptMessageHandler:self name:@"PlaySound"];

    WKPreferences *preferences = [[WKPreferences alloc]init];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 40.0;
    configuration.preferences = preferences;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Example" withExtension:@"html"];
    
    _wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-20)configuration:configuration];
    [_wkWebView loadRequest:[NSURLRequest requestWithURL:url]];
    self.view.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_wkWebView];
}


#pragma mark -WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"ScanAction"]) {
        NSLog(@"扫一扫");
    }else if ([message.name isEqualToString:@"Location"]) {
        NSLog(@"获取定位");
        //获取定位信息之后,将结果返回个js
        NSString *jsStr = [NSString stringWithFormat:@"setLocation('%@')",@"江苏省苏州市"];
        [_wkWebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSLog(@"%@----%@",result, error);
        }];
    } else if ([message.name isEqualToString:@"Share"]) {
        NSLog(@"分享");
        [self shareWithParams:message.body];
    } else if ([message.name isEqualToString:@"Color"]) {
        [self changeBGColor:message.body];
        NSLog(@"修改背景颜色");
    } else if ([message.name isEqualToString:@"Pay"]) {
        NSLog(@"支付");
    } else if ([message.name isEqualToString:@"Shake"]) {
        NSLog(@"摇一摇");
    } else if ([message.name isEqualToString:@"GoBack"]) {
        NSLog(@"返回");
    } else if ([message.name isEqualToString:@"PlaySound"]) {
        NSLog(@"播放声音");
    }
}
- (void)shareWithParams:(NSDictionary *)tempDic
{
    if (![tempDic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString *title = [tempDic objectForKey:@"title"];
    NSString *content = [tempDic objectForKey:@"content"];
    NSString *url = [tempDic objectForKey:@"url"];
    // 在这里执行分享的操作
    
    // 将分享结果返回给js
    NSString *jsStr = [NSString stringWithFormat:@"shareResult('%@','%@','%@')",title,content,url];
    [self.wkWebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

- (void)changeBGColor:(NSArray *)params
{
    if (![params isKindOfClass:[NSArray class]]) {
        return;
    }
    
    if (params.count < 4) {
        return;
    }
    
    CGFloat r = [params[0] floatValue];
    CGFloat g = [params[1] floatValue];
    CGFloat b = [params[2] floatValue];
    CGFloat a = [params[3] floatValue];
    
    self.view.backgroundColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
