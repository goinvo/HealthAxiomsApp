//
//  HAAxiomCell.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import "HAAxiomCell.h"
#import "HACacheManager.h"

@implementation HAAxiomCell

-(void)dealloc{

    [self removeObserver:self
              forKeyPath:@"axiomCard"];
}

-(void)awakeFromNib{

    [super awakeFromNib];
//Observing the value for model
    [self addObserver:self
           forKeyPath:@"axiomCard"
              options:NSKeyValueObservingOptionNew
              context:nil];
//Rounding the Corner
    [self.imgView.layer setCornerRadius:6.0f];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    NSString *imgName = self.axiomCard.frontImage;
    self.imgView.image = nil;
    if (imgName && [imgName length]>1) {
        NSString *name =[imgName stringByAppendingString:[NSString stringWithFormat:@"%f",self.frame.size.height]] ;
        NSString *encodedStr = [[name dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        
            dispatch_queue_t myQue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(myQue, ^(){
//Fetching the stored small image from userDefaults
                UIImage *imge = nil;
                NSData *imageData = [[NSUserDefaults standardUserDefaults] dataForKey:encodedStr];
                imge = [NSKeyedUnarchiver unarchiveObjectWithData: imageData];
                if (!imge) {
                
                    imge = [UIImage imageNamed:imgName];
                    CGSize imageSize = self.frame.size;
                    float xSize = imageSize.height * (imge.size.width/imge.size.height);
                    UIGraphicsBeginImageContextWithOptions(imageSize,YES,0);
                    [imge drawInRect:CGRectMake((imageSize.width-xSize)*0.5, 0, xSize, imageSize.height)];
                    imge = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
//Storing small image to userDefaults                    
                    NSData *imageDta = [NSKeyedArchiver archivedDataWithRootObject:imge];
                    NSString *name =[imgName stringByAppendingString:[NSString stringWithFormat:@"%f",self.frame.size.height]] ;
                    [[NSUserDefaults standardUserDefaults] setObject:imageDta forKey:[[name dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.imgView setImage:imge];
                    [self.imgView setNeedsDisplay];
                    
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
