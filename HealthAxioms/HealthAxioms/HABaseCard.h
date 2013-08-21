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
{

    @private
    NSArray *tmppppp;
}

@property (nonatomic, copy, readonly) NSString *frontImage;
@property (nonatomic, copy, readonly) NSString *backImage;
@property (nonatomic, assign, readonly) int index;

-(id)initWithFrontImage:(NSString *)fName backImage:(NSString *)bName index:(int)number;

@end
