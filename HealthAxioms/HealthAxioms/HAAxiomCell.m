//
//  HAAxiomCell.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import "HAAxiomCell.h"

@implementation HAAxiomCell


-(void)awakeFromNib{

    [super awakeFromNib];
    [self setBackgroundColor:[UIColor brownColor]];
    NSLog(@"was Here!");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)prepareForReuse{

    [super prepareForReuse];
    NSLog(@"is Preparing!");
}

@end
