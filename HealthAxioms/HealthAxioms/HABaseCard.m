//
//  HABaseCard.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import "HABaseCard.h"

@interface HABaseCard ()

@end

@implementation HABaseCard

-(id)initWithFrontImage:(NSString *)fName backImage:(NSString *)bName text:(NSString *)content index:(int)number{

    self = [super init];
    if (self) {
        
//        NSLog(@"Init card of index:%d frontImage:%@ BackImage:%@", number, fName, bName);
        
        _index = number;
        _isFront = YES;
        
        if(fName && ![fName isEqualToString:@""]) _frontImage = [fName copy];
//        else NSAssert(!([fName isEqualToString:@""]),@"No front Image Name");
        
        if(bName && ![bName isEqualToString:@""]) _backImage = [bName copy];
//        else NSAssert(!([bName isEqualToString:@""]),@"No back Image Name");
        
        if (content) {
            _axiomText = [content copy];
        }
        
    }
    return self;
}

@end
