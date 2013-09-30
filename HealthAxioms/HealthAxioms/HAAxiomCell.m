//
//  HAAxiomCell.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import "HAAxiomCell.h"

@implementation HAAxiomCell

-(void)dealloc{

    [self removeObserver:self
              forKeyPath:@"axiomCard"];
}

-(void)awakeFromNib{

    [super awakeFromNib];
//    NSLog(@"was Here!");
//    [self setBackgroundColor:[UIColor redColor]];
    [self addObserver:self
           forKeyPath:@"axiomCard"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    [self.layer setCornerRadius:6.0f];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    NSString *imgName = self.axiomCard.frontImage;
    self.imgView.image = nil;
    if (imgName && [imgName length]>1) {
        
        dispatch_queue_t myQue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(myQue, ^(){
        
            UIImage *img = [UIImage imageNamed:imgName];
            CGSize imageSize = self.frame.size;
            float xSize = imageSize.height * (img.size.width/img.size.height);
            UIGraphicsBeginImageContextWithOptions(imageSize,YES,0);
            [img drawInRect:CGRectMake((imageSize.width-xSize)*0.5, 0, xSize, imageSize.height)];
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.imgView setImage:img];
            });
        });
    }
}


-(void)prepareForReuse{

    [super prepareForReuse];
//    NSLog(@"is Preparing!");
    self.imgView.image = nil;
}

@end
