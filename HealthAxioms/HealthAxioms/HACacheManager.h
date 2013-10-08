//
//  HACacheManager.h
//  HealthAxioms
//
//  Created by Dhaval Karwa on 10/8/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HACacheManager : NSObject

@property (nonatomic, retain)NSCache *imageCache;

+(HACacheManager *)sharedCacheManager;

-(void)addImageToCahe:(UIImage *)image withImageId:(NSString *)uniqueID;
-(UIImage *)imageWithImageId:(NSString *)uniqueID;

@end
