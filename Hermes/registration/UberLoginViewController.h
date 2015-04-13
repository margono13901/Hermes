//
//  UberLoginViewController.h
//  Hermes
//
//  Created by Raylen Margono on 4/9/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "keys.h"
#import "JSON.h"
#import <AFNetworking/AFNetworking.h>
#import <UberKit.h>

@interface UberLoginViewController : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property(strong,nonatomic) NSMutableData *receivedData;
@property(strong,nonatomic)NSString *isLogin;

@end
