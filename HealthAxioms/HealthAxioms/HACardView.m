//
//  HACardView.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/22/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import "HACardView.h"
#import "HABaseCard.h"
#import "UITextView+HAAxiomStyle.h"

#define DEFAULT_FONT_SIZE 16.0f
#define TEXT_VIEW_PADDING 20.0f

@interface HACardView ()
@property (nonatomic, assign) int fontSize;
@property (nonatomic, weak) UITextView *axiomTextView;
@property (nonatomic, weak) UIImageView *frontImageView;
@property (nonatomic, weak) UIImageView *backImageView;
@end

@implementation HACardView{

    float rotation;
}

- (id)initWithFrame:(CGRect)frame model:(HABaseCard *)card
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _modelCard = card;
        UIPinchGestureRecognizer *pinchReco = [[UIPinchGestureRecognizer alloc]initWithTarget:self
                                                              action:@selector(handlePinch:)];
        
        [self addGestureRecognizer:pinchReco];
        _fontSize = DEFAULT_FONT_SIZE;
        
        if (card.index ==9) {
            
            float height = self.frame.size.height - TEXT_VIEW_PADDING *7;
            float width = self.frame.size.width - TEXT_VIEW_PADDING *2;
            
            CGRect txtRect = CGRectMake(TEXT_VIEW_PADDING, TEXT_VIEW_PADDING *6, width, height);
            
            UITextView *txtView = [[UITextView alloc] initWithFrame:txtRect];
            [txtView setText:card.axiomText];
            [self addSubview:txtView];
            
            self.axiomTextView = txtView;
            [self.axiomTextView setAxiomTextViewStyle];
        }
        
        NSString *imgNameToUse = (_modelCard.isFront)? _modelCard.frontImage :
                                                        _modelCard.backImage;
//        NSLog(@"self frame is %@", NSStringFromCGRect(self.frame));
        
        {
            UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [image setImage:[UIImage imageNamed:_modelCard.backImage]];
            //[self addSubview:image];
           // self.backImageView = image;
        }
        
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [image setImage:[UIImage imageNamed:imgNameToUse]];
        [self addSubview:image];
        self.frontImageView = image;
        
        rotation = 0;
    }
    return self;
}

#pragma mark handle Pinch for scaling the text

-(void)handlePinch:(UIPinchGestureRecognizer *)pinchReco{
    
    if (pinchReco.velocity > 0) {
        
        _fontSize = fmin(36.0, _fontSize+=1);
        NSLog(@"Increasing font size");
        [_axiomTextView setZoomScale:2.0 animated:YES];
    }else if (pinchReco.velocity <0){

        _fontSize = fmax(12.0, _fontSize -=1);
        NSLog(@"Reducing font size");
        [_axiomTextView setZoomScale:1.0 animated:YES];
    }
    
    [_axiomTextView setFont:[UIFont fontWithName:@"GillSans" size:_fontSize]];

}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef ctxRef = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor]setFill];
    CGContextFillRect(ctxRef, rect);
    
    NSString *imgNameToUse = (_modelCard.isFront)? _modelCard.frontImage :
                                                   _modelCard.backImage;
    
    if (imgNameToUse &&[imgNameToUse length]>1) {
     
        UIImage *img = [UIImage imageNamed:_modelCard.frontImage];
        [img drawInRect:rect];
    }
}
 */

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"touches began");
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (self.isFirstResponder) {

        NSLog(@"touches moving");
        
        rotation +=0.009;
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 / -500.0;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI * rotation, 1.0f, 0.0f, 0.0f);
        
        self.frontImageView.layer.transform = rotationAndPerspectiveTransform;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touches ended");
    rotation = 0;
}

@end
