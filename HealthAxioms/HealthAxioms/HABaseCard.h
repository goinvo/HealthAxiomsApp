//
//  HABaseCard.h
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HABaseCard;

@interface HABaseCard : NSObject

@property (nonatomic, copy, readonly) NSString *frontImage;
@property (nonatomic, copy, readonly) NSString *backImage;
@property (nonatomic, assign, readonly) int index;
@property (nonatomic, readwrite) BOOL isFront;
@property (nonatomic, copy, readonly) NSString *axiomText;

-(id)initWithFrontImage:(NSString *)fName backImage:(NSString *)bName text:(NSString *)content index:(int)number;

@end
