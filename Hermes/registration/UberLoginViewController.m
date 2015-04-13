//
//  UberLoginViewController.m
//  Hermes
//
//  Created by Raylen Margono on 4/9/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "UberLoginViewController.h"

@interface UberLoginViewController ()

@end

@implementation UberLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UberKit *uberkit = [[UberKit alloc]initWithClientID:uberClientId ClientSecret:uberSecret RedirectURL:redirectURI ApplicationName:@"Hermes"];
    NSString *url = [NSString stringWithFormat:@"https://login.uber.com/oauth/authorize?response_type=code&client_id=%@",uberClientId];
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //    [indicator startAnimating];
    if ([[[request URL] host] isEqual:@"com.Hyphen.Hermes"]) {
        
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"code"]) {
                verifier = [keyValue objectAtIndex:1];
                
                NSLog(@"%@",verifier);
                break;
            }
        }
        if (verifier) {
            NSString *data = [NSString stringWithFormat:@"code=%@&client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=authorization_code", verifier,uberClientId,uberSecret,redirectURI];
            NSString *url = @"https://login.uber.com/oauth/token";
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];
            NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
            self.receivedData = [[NSMutableData alloc] init];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccess" object:nil];
        } else {
            // ERROR!
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:nil];

        }
        [self.navigationController popToRootViewControllerAnimated:YES];

        return NO;
    }
    
    return YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *url = [[webView.request URL]absoluteString];
    if ([url hasPrefix:@"https://m.facebook.com/v2.2/dialog/oauth"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Login Successful!" message:@"Complete Sign Up by Pressing Facebook Login Once More!" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        [self.webView goBack];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];
    NSLog(@"verifier %@",self.receivedData);
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"%@", error]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *response = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    SBJsonParser *jResponse = [[SBJsonParser alloc]init];
    NSDictionary *tokenData = [jResponse objectWithString:response];
    NSLog(@"%@",tokenData);
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
