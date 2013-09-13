//
//  UITextView+HAAxiomStyle.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/30/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#define DEFAULT_FONT_SIZE 16.0f

#import "UITextView+HAAxiomStyle.h"

@implementation UITextView (HAAxiomStyle)

-(void)setAxiomTextViewStyle{

    [self setEditable:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setTextColor:[UIColor colorWithRed:0.16f green:0.14f blue:0.40f alpha:1.00f]];
    [self setFont:[UIFont fontWithName:@"GillSans" size:DEFAULT_FONT_SIZE]];
}
@end
