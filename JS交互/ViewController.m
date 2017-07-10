//
//  ViewController.m
//  JS交互
//
//  Created by 马金丽 on 17/3/16.
//  Copyright © 2017年 majinli. All rights reserved.
//

#import "ViewController.h"

#import <JavaScriptCore/JavaScriptCore.h>
#import "WKViewController.h"
/**
 JavaScriptCore中类及协议：
 
 JSContext：给JavaScript提供运行的上下文环境
 
 JSValue：JavaScript和Objective-C数据和方法的桥梁
 
 JSManagedValue：管理数据和方法的类
 
 JSVirtualMachine：处理线程相关，使用较少
 
 JSExport：这是一个协议，如果采用协议的方法交互，自己定义的协议必须遵守此协议
 */
//在ios7以前我们只能使用UIWebView,所以在js交互中只能通过stringByEvaluatingJavaScriptFromString进行本地调用h5,而h5调用本地多采用UrlSchemes方式,iOS7之后使用WebView则可以使用JavaScriptCore框架,通过JSContext进行js交互.iOS 8之后可以使用WKWebView本身的框架,毕竟WKWebView本身已经优化很多，并且提供了更多的方法和协议，不过注意一点的是在WKWebView中鉴于一些线程和进程的问题是无法获取JSContext的。


@interface ViewController ()<UIWebViewDelegate>
@property(nonatomic,strong)JSContext *jsContext;
@end

@implementation ViewController


/**
 js交互时,最好要由web前端去定义方法名,以防后期改来改去很麻烦
 */
- (void)viewDidLoad {
    //https://m.imexue.com/data/platform/static/single/2017/7/10/360333650472341499656779908.html
    [super viewDidLoad];
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"https://m.imexue.com/data/platform/static/single/2017/7/10/360333650472341499656779908" withExtension:@"html"];
    NSURL *url = [NSURL URLWithString:@"https://m.imexue.com/data/platform/static/single/2017/7/10/360333650472341499656779908.html"];
    [self.mainWebView loadRequest:[[NSURLRequest alloc]initWithURL:url]];
    self.mainWebView.scalesPageToFit = YES;
    self.mainWebView.delegate = self;
    self.view.backgroundColor = [UIColor orangeColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"WKwebView" style:UIBarButtonItemStylePlain target:self action:@selector(jumpWKWebView)];
 
}

#pragma mark -WebDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //在页面加载完成之后获取js运行环境JSContext
    self.jsContext = [webView     valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //h5中实现的js函数,是由OC端主动调用的
    JSValue *jaValue = [self.jsContext evaluateScript:@"showAppAlertMsg"];
    [jaValue callWithArguments:@[@"这是app本地交互文案"]];
    //由h5调用的,然后在OC端实现
    self.jsContext[@"callSystemCamera"] = ^(){
        NSLog(@"调用系统相机");
    };
    self.jsContext[@"showAlertMsg"] = ^(NSString *title,NSString *message){
        NSLog(@"调用系统弹框");
    };
    self.jsContext[@"callWithDict"] = ^(id jsonDic){
        NSLog(@"callWithDict%@",jsonDic);
        
    };
    self.jsContext[@"jsCallObjcAndObjcCallJsWithDict"] = ^(id jsonDic){
       
    };
    NSString *titleString = [self.mainWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = titleString;
    NSString *contentString = [self.mainWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerHTML"];
    NSLog(@"网页内容:%@",contentString);
}

- (IBAction)jumpWKWebView {
    WKViewController *WKweb = [[WKViewController alloc]init];
    [self.navigationController pushViewController:WKweb animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
