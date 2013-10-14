//
//  HAAxiomCell.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import "HAAxiomCell.h"
#import "HACacheManager.h"

@implementation HAAxiomCell

-(void)prepareForReuse{

    [super prepareForReuse];
    self.imgView.image = nil;
    [self.imgView setNeedsDisplay];
}

@end
