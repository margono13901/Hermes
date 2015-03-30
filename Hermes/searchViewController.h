//
//  searchViewController.h
//  Hermes
//
//  Created by Raylen Margono on 3/26/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "friendCell.h"
@interface searchViewController : UITableViewController<UISearchBarDelegate,UISearchControllerDelegate,UISearchDisplayDelegate,UISearchResultsUpdating>

@property(strong,nonatomic) NSArray *friendArray;
@property(strong,nonatomic) NSArray *searchResults;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) IBOutlet UISearchBar *searchbar;
@property (strong,nonatomic) NSArray *userArray;
@end
