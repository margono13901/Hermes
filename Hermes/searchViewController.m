//
//  searchViewController.m
//  Hermes
//
//  Created by Raylen Margono on 3/26/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "searchViewController.h"

@interface searchViewController ()

@end

@implementation searchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:@"refreshTable" object:nil];
    
}

-(void)refreshTable:(id)sender{
    [self getPendingRealtion];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    [self getFriends];
    [self refreshTable:self];
}

-(void)getFriends{
    //find Friends
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"friends"];
    PFQuery *query = [relation query];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.friendArray = objects;
    }];
}

-(void)getPendingRealtion{
    //find pending Friends
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"friendsPending"];
    PFQuery *query = [relation query];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        NSLog(@"%@",objects);
        self.friendsPendingForAccept = objects;
        [self.tableView reloadData];
    }];
}

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchController.searchBar performSelector: @selector(resignFirstResponder)
                    withObject: nil
                    afterDelay: 0.1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.searchController.isActive) {
        return [self.searchResults count];
    }
    return [self.friendsPendingForAccept count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    friendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[friendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    [cell.loadingIndicator startAnimating];
    PFUser *user;
    if (self.searchController.isActive) {
        user = [self.searchResults objectAtIndex:indexPath.row];
    }else{
        user = [self.friendsPendingForAccept objectAtIndex:indexPath.row];
    }
    cell.user=user;
    [user[@"profilePhoto"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            // image can now be set on a UIImageView
            // border radius
            cell.friendPicturePreview.layer.cornerRadius = cell.friendPicturePreview.frame.size.width/2;
            cell.friendPicturePreview.layer.masksToBounds = YES;
            cell.friendPicturePreview.image =image;
            [cell.loadingIndicator stopAnimating];
            cell.loadingIndicator.hidden = YES;
        }
    }];
    
    cell.friendUsername.text = user.username;
    
    if (self.searchController.isActive) {
        if ([self isFriend:user]) {
            [cell.friendAddButton setTitle:@"Unfriend" forState:UIControlStateNormal];
        }
        else if([self isPendingUser:user]){
            [cell.friendAddButton setTitle:@"Accept" forState:UIControlStateNormal];
        }
        else{
            [cell.friendAddButton setTitle:@"Friend" forState:UIControlStateNormal];
        }
    }else{
        [cell.friendAddButton setTitle:@"Accept" forState:UIControlStateNormal];
    }
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // The user clicked the [X] button or otherwise cleared the text.
    if([searchText length] == 0) {
        [searchBar performSelector: @selector(resignFirstResponder)
                        withObject: nil
                        afterDelay: 0.1];
    }
}

-(BOOL)isFriend:(PFUser *)user{
    for (int i = 0 ; i < self.friendArray.count; i++) {
        PFUser *friend = self.friendArray[i];
        if ([user.username isEqual:friend.username]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isPendingUser:(PFUser *)user{
    for (int i = 0 ; i < self.friendsPendingForAccept.count; i++) {
        PFUser *friend = self.friendsPendingForAccept[i];
        if ([user.username isEqual:friend.username]) {
            return YES;
        }
    }
    return NO;
}


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self filterContentForSearchText:searchString
                               scope:[[self.searchController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchController.searchBar
                                                     selectedScopeButtonIndex]]];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    //NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"username contains[c] %@", searchText];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" matchesRegex:searchText modifiers:@"i"];
    [userQuery whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.searchResults = objects;
        [self.tableView reloadData];
    }];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
