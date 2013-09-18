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
    CALayer *upperLayer;
    CALayer *lowerLayer;
    BOOL isFront;
}

- (id)initWithFrame:(CGRect)frame model:(HABaseCard *)card
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isFront = YES;
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
        
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [image setImage:[UIImage imageNamed:imgNameToUse]];
        [self addSubview:image];
        self.frontImageView = image;
         [self.frontImageView.layer setDoubleSided:NO];
        rotation = 0;
        
    }
    return self;
}

#pragma mark handle the change in views visibility

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    NSLog(@"change is %@", change);
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"touches began");
   [self addBackView];
    
    upperLayer = [CALayer layer];
    upperLayer.frame = self.frontImageView.frame;
    upperLayer.contents = (id)self.frontImageView.image.CGImage;

    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(self.frontImageView.frame.origin.x, self.frontImageView.frame.origin.y, self.frontImageView.frame.size.width, self.frontImageView.frame.size.height*0.5)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    [upperLayer setMask:maskLayer];
    [self.layer insertSublayer:upperLayer below:self.frontImageView.layer];
    
    
    {
    lowerLayer = [CALayer layer];
    lowerLayer.frame = self.backImageView.frame;
    lowerLayer.contents = (id)self.backImageView.image.CGImage;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(self.backImageView.frame.origin.x, self.frontImageView.frame.origin.y, self.frontImageView.frame.size.width, self.frontImageView.frame.size.height*0.5)];

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    [lowerLayer setMask:maskLayer];
    [lowerLayer setDoubleSided:NO];
    [self.layer insertSublayer:lowerLayer below:upperLayer];

    }
}

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
bool toUSE = NO;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
//    NSLog(@"touches moving");
    if(RADIANS_TO_DEGREES(M_PI * rotation) <180.0 ){
        rotation +=0.01;
        
        if( RADIANS_TO_DEGREES(M_PI * rotation) <=180.0){
            CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform.m34 = 1.0 / -500.0;
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI * rotation, 1.0f, 0.0f, 0.0f);
            self.frontImageView.layer.transform = rotationAndPerspectiveTransform;
        }

        lowerLayer.transform = CATransform3DMakeRotation( (M_PI*181/180) *(1 +rotation), 1.0f, 0.0f, 0.0f);
       
        if (RADIANS_TO_DEGREES(M_PI * rotation) >=90.0 && toUSE == NO) {
           
//            NSLog(@"already changed the boolean");
            toUSE = YES;
        }
//        NSLog(@"still in here :%f",RADIANS_TO_DEGREES(M_PI * rotation));
    }
    else if(RADIANS_TO_DEGREES(M_PI * rotation) >180.0 && toUSE){
        [upperLayer setHidden:YES];
        [lowerLayer setHidden:YES];
        [self sendSubviewToBack:self.frontImageView];
        toUSE = NO;
        isFront = NO;
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"touches ended");
    rotation = 0;
    self.frontImageView.layer.transform = CATransform3DIdentity;
    toUSE = NO;
    if (upperLayer) {
        [upperLayer removeFromSuperlayer];
        [lowerLayer removeFromSuperlayer];
    }
}

-(void)addBackView{

    if (!self.backImageView) {
      
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [image setImage:[UIImage imageNamed:_modelCard.backImage]];
        [self insertSubview:image belowSubview:self.frontImageView];
        self.backImageView = image;
    
    }
}

-(void)removeBackView{

    [self.backImageView removeFromSuperview];
    self.backImageView = nil;
}
@end
