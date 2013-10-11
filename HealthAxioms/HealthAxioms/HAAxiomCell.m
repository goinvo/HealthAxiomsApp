//
//  HAAxiomCell.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import "HAAxiomCell.h"
#import "HACacheManager.h"


@interface HAAxiomCell ()

//@property (nonatomic, copy)NSString *keyName;
@end

@implementation HAAxiomCell
/*
-(void)dealloc{

    [self removeObserver:self
              forKeyPath:@"imgName"];
}

-(void)awakeFromNib{

    [super awakeFromNib];
//Observing the value for model
    [self addObserver:self
           forKeyPath:@"imgName"
              options:NSKeyValueObservingOptionNew
              context:nil];
//Rounding the Corner
    [self.imgView.layer setCornerRadius:6.0f];
    
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{


    _imgView.image = nil;
    __weak UIImageView *weakCopy = _imgView ;
    CGSize frameSize = self.frame.size;
    _keyName = nil;
    
    if (_imgName && [_imgName length]>1) {
        
        NSString *name =[_imgName stringByAppendingString:[NSString stringWithFormat:@"%f",frameSize.height]] ;
        _keyName = [[name dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        
            dispatch_queue_t myQue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(myQue, ^(){
//Fetching the stored small image from userDefaults
                UIImage *imge = nil;
//checking if the key exists or not
                if([[NSUserDefaults standardUserDefaults] objectForKey:_keyName]){
                    NSData *imageData = [[NSUserDefaults standardUserDefaults] dataForKey:_keyName];
                    imge = [NSKeyedUnarchiver unarchiveObjectWithData: imageData];
                }
                else if(!imge) {
                
                    imge = [UIImage imageNamed:_imgName];
                    CGSize imageSize = self.frame.size;
                    float xSize = imageSize.height * (imge.size.width/imge.size.height);
                    UIGraphicsBeginImageContextWithOptions(imageSize,YES,0);
                    [imge drawInRect:CGRectMake((imageSize.width-xSize)*0.5, 0, xSize, imageSize.height)];
                    imge = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
//Storing small image to userDefaults                    
                    NSData *imageDta = [NSKeyedArchiver archivedDataWithRootObject:imge];
                   [[NSUserDefaults standardUserDefaults] setObject:imageDta forKey:_keyName];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [weakCopy setImage:imge];
                    [weakCopy setNeedsDisplay];
                   // NSLog(@"setting image %@",_imgName);
                    
                });
            });
    }
}
*/
@end
