//
//  searchKeyWordController.m
//  Hermes
//
//  Created by Raylen Margono on 5/7/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "searchKeyWordController.h"

@interface searchKeyWordController ()

@end

@implementation searchKeyWordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.trendingLabel.font = [UIFont fontWithName:@"SackersGothicLightAT" size:14 ];
    self.trendingTable.delegate = self;
    self.trendingTable.dataSource = self;
    [self.trendingTable allowsSelection];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.searchField resignFirstResponder];
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    [self downloadKeyWords];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)downloadKeyWords{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    PFGeoPoint *userLocation = [PFGeoPoint geoPointWithLocation:delegate.location];
    PFQuery *query = [PFQuery queryWithClassName:@"mediaPosts"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"location" nearGeoPoint:userLocation withinMiles:20];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    NSDate *oneDayAgo = [[NSDate date]dateByAddingTimeInterval:-60*60*24];
    [query whereKey:@"createdAt" greaterThan:oneDayAgo];
    [query selectKeys:@[@"message"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            // Perform long running process
            self.keyWords = [NSMutableDictionary dictionary];
            for (PFObject *post  in objects) {
                NSArray *values = [post[@"message"] componentsSeparatedByCharactersInSet:
                                   [NSCharacterSet whitespaceCharacterSet]];
                
                // Remove the empty strings.
                NSString *myRegex = @"[A-Z0-9a-z_]*";
                values = [values filteredArrayUsingPredicate:
                          [NSPredicate predicateWithFormat:@"SELF MATCHES %@", myRegex]];
                [self checkWord:values];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                 self.sortedKeys = [self.keyWords keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
                    return [obj1 compare:obj2];
                }];
                [self.trendingTable reloadData];
            });
        }); 

    }];
}

-(void)checkWord:(NSArray *)arrayOfWords{
    for (NSString *string in arrayOfWords) {
        NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:[NSArray arrayWithObject:NSLinguisticTagSchemeLexicalClass] options:~NSLinguisticTaggerOmitWords];
        [tagger setString:string];
        [tagger setOrthography:[NSOrthography orthographyWithDominantScript:@"Latn" languageMap:@{@"Latn" : @[@"en"]}] range:NSMakeRange(0, string.length)];
        [tagger enumerateTagsInRange:NSMakeRange(0, [string length])
                              scheme:NSLinguisticTagSchemeLexicalClass
                             options:~NSLinguisticTaggerOmitWords
                          usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
                              NSArray *collection = @[@"Noun",@"Verb",@"OtherWord"];
                              if ([collection containsObject:tag]) {
                                  [self addToDictionary:string];
                              }
                              
                          }];

        
    }
    
}

-(void)addToDictionary:(NSString *)string{
    if ([self.keyWords objectForKey:string]) {
        NSNumber *count = [self.keyWords objectForKey:string];
        int increment = [count intValue];
        [self.keyWords setValue:[NSNumber numberWithInt:++increment] forKey:string];
    }else{
        [self.keyWords setValue:[NSNumber numberWithInt:0] forKey:string];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.keyWords count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    keywordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[keywordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.rankingText.text = [NSString stringWithFormat:@"%lu",indexPath.row+1];
    cell.wordText.text = self.sortedKeys[(self.sortedKeys.count-1)-indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *word = self.sortedKeys[(self.sortedKeys.count-1)-indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"searchKeyWord" object:word];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)searchButton:(id)sender {
    
    if (self.searchField.text.length>0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchKeyWord" object:self.searchField.text];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
