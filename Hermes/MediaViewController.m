//
//  MediaViewController.m
//  Hermes
//
//  Created by Raylen Margono on 3/22/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "MediaViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface MediaViewController ()

@end

@implementation MediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFQuery *query = [PFUser query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.userArray = objects;
        NSLog(@"%@",self.userArray);
    }];
    [self.gridView reloadData];
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

- (CGFloat) gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex
{
    return 80;
}

- (CGFloat) gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex
{
    return 80;
}

- (NSInteger) numberOfColumnsOfGridView:(UIGridView *) grid
{
    return 4;
}


- (NSInteger) numberOfCellsOfGridView:(UIGridView *) grid
{
    return self.userArray.count;
}

- (UIGridViewCell *) gridView:(UIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex
{
    Cell *cell = (Cell *)[grid dequeueReusableCell];
    
    if (cell == nil) {
        cell = [[Cell alloc] init];
    }
    int index = rowIndex*4+columnIndex;
    PFUser *user = self.userArray[0];
    NSLog(@"%@",user.username);
    [user[@"profilePhoto"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            // image can now be set on a UIImageView
            CALayer *imageLayer = cell.thumbnail.layer;
            [imageLayer setCornerRadius:5];
            [imageLayer setBorderWidth:1];
            [imageLayer setMasksToBounds:YES];
            [cell.imageView.layer setCornerRadius:cell.imageView.frame.size.width/2];
            [imageLayer setMasksToBounds:YES];
            cell.thumbnail.image = image;
        }
    }];
    cell.label.text = [NSString stringWithFormat:@"%@", user.username];
    
    return cell;
}

- (void) gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)colIndex
{
    NSLog(@"%d, %d clicked", rowIndex, colIndex);
}
@end
