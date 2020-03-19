//
//  ViewController.m
//  native-js-hug
//
//  Created by valentine on 2020/3/19.
//  Copyright © 2020 https://github.com/mrxir. All rights reserved.
//

#import "ViewController.h"

#import <WebKit/WebKit.h>
#import <UIKit/UITextView.h>

@interface ViewController ()<WKNavigationDelegate, WKScriptMessageHandler>

// 用来展示 demo web 页面
@property (nonatomic, weak) IBOutlet WKWebView *webView;

// 仅用来显示一些重要日志，与业务无关
@property (nonatomic, weak) IBOutlet UITextView *textView;

@property (nonatomic, assign) BOOL isProcessing;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView.navigationDelegate = self;
    
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"performAppleSelector"];
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"reportPerformReponse"];
    NSString *html_file_path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    
    NSError *load_file_error = nil;
    NSString *html_file_data_string = [NSString stringWithContentsOfFile:html_file_path encoding:NSUTF8StringEncoding error:&load_file_error];
    if (load_file_error) {
        NSLog(@"加载index.html文件错误：%@", load_file_error);
        return;
    }
    
    [self.webView loadHTMLString:html_file_data_string baseURL:nil];
    
}

#pragma mark - <WKNavigationDelegate>

/*!
 @abstract Invoked when a main frame navigation starts.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"%@", @"开始加载");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"%@", @"加载完成");
}


#pragma mark - <WKScriptMessageHandler>

/*!
 @abstract Invoked when a script message is received from a webpage.
 @param userContentController The user content controller invoking the delegate method.
 @param message The script message received.
 */
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    /*!
     @abstract The name of the message handler to which the message is sent.
     */
    NSString *name = message.name;
    
    /*!
     @abstract The body of the message.
     @discussion Allowed types are NSNumber, NSString, NSDate, NSArray, NSDictionary, and NSNull.
    */
    id body = message.body;
    
    if ([name isEqualToString:@"reportPerformReponse"]) {
        NSLog(@"js: reportPerformReponse %@", body);
    }
    
    if ([name isEqualToString:@"performAppleSelector"]) {
        
        NSString *method = nil;
        NSDictionary *expression_dictionary = body;
        if ([expression_dictionary isKindOfClass:[NSDictionary class]]) {
            
            // 丛约定表达式中获取方法名
            
            method = [expression_dictionary valueForKey:@"method"];
            NSLog(@"js: %@", method);
            
            if ([method isKindOfClass:[NSString class]]) {
                
                // 确定一次事件，本次事件为js调用oc，想要获取用户工号
                if ([method isEqualToString:@"tt.getUserCode"]) {
                    
                    if (_isProcessing == YES) {
                        // 本次js调用设置的回调函数，oc通过该函数将数据传给js
                        NSMutableString *completion = [NSMutableString stringWithFormat:@"%@", [expression_dictionary valueForKey:@"completion"]];
                        NSDictionary *response_object = @{@"code": @"555", @"data": [NSNull null], @"message": @"正在处理，请稍后..."};
                        NSError *serialization_error = nil;
                        NSData *response_data = [NSJSONSerialization dataWithJSONObject:response_object options:0 error:&serialization_error];
                        if (serialization_error) {
                            NSLog(@"oc: serialization_error: %@", serialization_error);
                        }
                        NSString *response_json_string = [[NSString alloc] initWithData:response_data encoding:NSUTF8StringEncoding];
                        [completion appendFormat:@"('%@')", response_json_string];
                        
                        [self.webView evaluateJavaScript:completion completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                            if (error) {
                                NSLog(@"oc: evaluateJavaScript_error: %@", error);
                            }
                        }];
                        return;
                    }
                    
                    _isProcessing = YES;
                    // 开始处理，假设oc花费3秒获取到工号，然后将结果通过js调用时预设的回调函数传给js
                    NSLog(@"oc: 正在尝试获取工号...");
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        self->_isProcessing = NO;
                        
                        // 获取到的工号
                        NSString *userCode = @"BMW-AK47";
                        
                        // 本次js调用设置的回调函数，oc通过该函数将数据传给js
                        NSMutableString *completion = [NSMutableString stringWithFormat:@"%@", [expression_dictionary valueForKey:@"completion"]];
                        NSDictionary *response_object = @{@"code": @"200", @"data": userCode, @"message": @"工号获取成功"};
                        NSError *serialization_error = nil;
                        NSData *response_data = [NSJSONSerialization dataWithJSONObject:response_object options:0 error:&serialization_error];
                        if (serialization_error) {
                            NSLog(@"oc: serialization_error: %@", serialization_error);
                        }
                        NSString *response_json_string = [[NSString alloc] initWithData:response_data encoding:NSUTF8StringEncoding];
                        [completion appendFormat:@"('%@')", response_json_string];
                        
                        // 调用js传入工号
                        [self.webView evaluateJavaScript:completion completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                            if (error) {
                                NSLog(@"oc: evaluateJavaScript_error: %@", error);
                            }
                        }];
                        
                    });
                    
                }
                
            }
            
        }
        
    }
}

@end
