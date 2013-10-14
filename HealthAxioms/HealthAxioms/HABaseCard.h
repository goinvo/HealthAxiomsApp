//
//  HABaseCard.h
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HABaseCard;

@interface HABaseCard : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *frontImage;
@property (nonatomic, copy, readonly) NSString *backImage;
@property (nonatomic, copy, readonly) NSString *axiomText;
@property (nonatomic, copy, readonly) NSString *axiomTitle;
@property (nonatomic, assign, readonly) int index;
@property (nonatomic, readwrite) BOOL isFront;

-(id)initWithFrontImage:(NSString *)fName backImage:(NSString *)bName text:(NSString *)content index:(int)number title:(NSString *)cardTitle;

@end
