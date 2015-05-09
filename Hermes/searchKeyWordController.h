//
//  searchKeyWordController.h
//  Hermes
//
//  Created by Raylen Margono on 5/7/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "keywordCell.h"
#import "AppDelegate.h"

@interface searchKeyWordController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UITableView *trendingTable;
@property (strong, nonatomic) IBOutlet UILabel *trendingLabel;
@property (strong,nonatomic) NSMutableDictionary *keyWords;
@property (strong,nonatomic) NSArray *sortedKeys;
- (IBAction)searchButton:(id)sender;

@end
