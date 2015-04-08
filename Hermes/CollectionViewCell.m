//
//  CollectionViewCell.m
//  Hermes
//
//  Created by Raylen Margono on 3/22/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell



- (UIImageView *) imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.layer.cornerRadius = 50;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.borderWidth = 3;
        _imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UITextField *) newPostField
{
    CGRect rect = CGRectMake(70, 75, 20, 23);
    if (!_newPostField) {
        _newPostField = [[UITextField alloc] initWithFrame:rect];
        [_newPostField setEnabled:NO];
        _newPostField.hidden = YES;
        [_newPostField setTextColor:[UIColor whiteColor]];
        _newPostField.textAlignment = NSTextAlignmentCenter;
        _newPostField.backgroundColor = [UIColor redColor];
        _newPostField.layer.cornerRadius = 10;
        [_newPostField setFont:[UIFont boldSystemFontOfSize:15]];
        [self.contentView addSubview:_newPostField];
    }
    return _newPostField;
}

// Here we remove all the custom stuff that we added to our subclassed cell
-(void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    [self.newPostField removeFromSuperview];
    self.newPostField = nil;
}

@end
