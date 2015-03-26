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
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

// Here we remove all the custom stuff that we added to our subclassed cell
-(void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
}

@end
