//
//  HAModel.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import "HAModel.h"
#import "HABaseCard.h"

@implementation HAModel

static HAModel *instance = nil;

+(HAModel *)sharedModel{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HAModel alloc]init];
    });

    return instance;
}

-(id)init{

    self = [super init];

    if (self) {
    
        NSString *path = [[NSBundle mainBundle] pathForResource:@"HAAxiomsList" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        _axiomsDict = dict;
       // NSLog(@"dict is %@",_axiomsDict);
        
        _axiomCardsList = [NSMutableArray arrayWithCapacity:[_axiomsDict count]];

        for (NSString *str in [_axiomsDict allKeys]) {
            int num= [str integerValue];
            NSDictionary *dict = _axiomsDict[str];
            HABaseCard *baseCard = [[HABaseCard alloc]initWithFrontImage:dict[@"front_image"]
                                                               backImage:dict[@"back_image"]
                                                                   index:num];
            [_axiomCardsList addObject:baseCard];
        }
        
        //Sorting the entries in the array based on Index
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        _axiomCardsList = [NSMutableArray arrayWithArray:[_axiomCardsList sortedArrayUsingDescriptors:@[descriptor]] ];
        
        
    }
    return self;
}


-(HABaseCard *)cardForIndex:(int)indexOfCard{
    
    return nil;
}


@end
