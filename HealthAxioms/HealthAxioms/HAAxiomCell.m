//
//  HAAxiomCell.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import "HAAxiomCell.h"

@implementation HAAxiomCell


-(void)awakeFromNib{

    [super awakeFromNib];
//    NSLog(@"was Here!");
    [self addObserver:self
           forKeyPath:@"axiomCard" options:NSKeyValueObservingOptionNew
              context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    NSString *imgName = self.axiomCard.frontImage;
    self.imgView.image = nil;
    if (imgName && [imgName length]>1) {
        
        dispatch_queue_t myQue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(myQue, ^(){
        
            UIImage *img = [UIImage imageNamed:imgName];
            CGSize imageSize = self.frame.size;
            UIGraphicsBeginImageContextWithOptions(imageSize,YES,0);
            [img drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.imgView setImage:img];
            });
        });
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

/*
-(void)prepareForReuse{

    [super prepareForReuse];
    NSLog(@"is Preparing!");
}
*/
@end
