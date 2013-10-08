//
//  HACacheManager.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 10/8/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#define CACHE_LIMIT 12

#import "HACacheManager.h"

@implementation HACacheManager


+(HACacheManager *)sharedCacheManager{
    
    static HACacheManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

-(id)init{
    
    self = [super init];
    if (self) {
        self.imageCache = [[NSCache alloc]init];
        [self.imageCache setCountLimit:CACHE_LIMIT];
    }
    return self;
}

-(void)addImageToCahe:(UIImage *)image withImageId:(NSString *)uniqueID{
    
    if (image) {
        [self.imageCache setObject:image
                            forKey:uniqueID];
    }
}

-(UIImage *)imageWithImageId:(NSString *)uniqueID{
    
    UIImage *found = nil;
    found = [self.imageCache objectForKey:uniqueID];
    
    return found;
}

@end
