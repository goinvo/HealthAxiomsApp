//
//  HAModel.h
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HABaseCard;

@interface HAModel : NSObject

@property (nonatomic, strong, readonly) NSDictionary *axiomsDict;

@property (nonatomic, strong, readonly) NSMutableArray *axiomCardsList;

+(HAModel *)sharedModel;
-(HABaseCard *)cardForIndex:(int)indexOfCard;

@end
