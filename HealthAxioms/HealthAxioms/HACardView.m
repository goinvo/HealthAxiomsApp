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
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(x) ((x) * (M_PI / 180.0))

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
    CALayer *txLayer;
    BOOL isFront;
    CGPoint preTouchLocation;
}

- (id)initWithFrame:(CGRect)frame model:(HABaseCard *)card
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isFront = YES;
        _modelCard = card;
        preTouchLocation = CGPointZero;
        
        UIPinchGestureRecognizer *pinchReco = [[UIPinchGestureRecognizer alloc]initWithTarget:self
                                                              action:@selector(handlePinch:)];
        
        [self addGestureRecognizer:pinchReco];
        _fontSize = DEFAULT_FONT_SIZE;
        
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

#pragma mark create layer with the given parameters

-(CALayer *)layerWithContents:(id)contents rect:(CGRect)frameRect maskRect:(CGRect)maskBounds{
    
    CALayer *layerToReturn = [CALayer layer];
    layerToReturn.frame = frameRect;
    layerToReturn.contents = contents;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:maskBounds];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    [layerToReturn setMask:maskLayer];
    [layerToReturn setDoubleSided:NO];
    
    return layerToReturn;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"started");
    preTouchLocation = [[touches anyObject] locationInView:self];
    
}


-(void)addLayers{

    if (isFront) {
        
        [self addBackView];
        
        //Add Up and down Layers
        if (!upperLayer) {

            CGRect upFrame = self.frontImageView.frame;
            upperLayer = [self layerWithContents:(id)(self.frontImageView.image.CGImage)
                                            rect:upFrame
                                        maskRect:CGRectMake(upFrame.origin.x
                                                            , upFrame.origin.y
                                                            , upFrame.size.width
                                                            , upFrame.size.height*0.5)];
            upperLayer.transform = CATransform3DIdentity;
            [self.layer addSublayer:upperLayer];
            
        }
        
        if (!lowerLayer) {

            CGRect lowFrame = self.backImageView.frame;
            lowerLayer = [self layerWithContents:(id)(self.backImageView.image.CGImage)
                                            rect:lowFrame
                                        maskRect:CGRectMake(lowFrame.origin.x
                                                            , lowFrame.origin.y
                                                            , lowFrame.size.width
                                                            , lowFrame.size.height*0.5)];
           
            CATextLayer *txtlayer = [CATextLayer layer];
            [txtlayer setFrame:CGRectMake(TEXT_VIEW_PADDING*1.25, TEXT_VIEW_PADDING *6.4, self.frame.size.width - TEXT_VIEW_PADDING *2.5, self.frame.size.height - TEXT_VIEW_PADDING *6.5)];
            [txtlayer setString:_modelCard.axiomText];
            [txtlayer setFont:@"GillSans"];
            [txtlayer setFontSize:16.0f];
            [txtlayer setForegroundColor:[UIColor colorWithRed:0.16f green:0.14f blue:0.40f alpha:1.00f].CGColor];
            [txtlayer setAlignmentMode:kCAAlignmentLeft];
            [txtlayer setWrapped:YES];
            txtlayer.contentsScale = [[UIScreen mainScreen] scale];
            [lowerLayer addSublayer:txtlayer];
            
            lowerLayer.transform = CATransform3DIdentity;
            [self.layer insertSublayer:lowerLayer below:upperLayer];
            [self.axiomTextView setHidden:NO];
        }

        /*
         float height = self.frame.size.height - TEXT_VIEW_PADDING *7;
         float width = self.frame.size.width - TEXT_VIEW_PADDING *2;
         */
    }
    else{
        if (!upperLayer) {

            CGRect upFrame = self.backImageView.frame;
            upperLayer = [self layerWithContents:(id)(self.backImageView.image.CGImage)
                                            rect:upFrame
                                        maskRect:CGRectMake(upFrame.origin.x
                                                            , upFrame.origin.y + upFrame.size.height*0.5
                                                            , upFrame.size.width
                                                            , upFrame.size.height*0.5)];
            
            
            CATextLayer *txtlayer = [CATextLayer layer];
            [txtlayer setFrame:CGRectMake(TEXT_VIEW_PADDING*1.25, TEXT_VIEW_PADDING *6.4, self.frame.size.width - TEXT_VIEW_PADDING *2.5, self.frame.size.height - TEXT_VIEW_PADDING *6.5)];
            [txtlayer setString:_modelCard.axiomText];
            [txtlayer setFont:@"GillSans"];
            [txtlayer setFontSize:16.0f];
            [txtlayer setForegroundColor:[UIColor colorWithRed:0.16f green:0.14f blue:0.40f alpha:1.00f].CGColor];
            [txtlayer setAlignmentMode:kCAAlignmentLeft];
            [txtlayer setWrapped:YES];
            txtlayer.contentsScale = [[UIScreen mainScreen] scale];
            [upperLayer addSublayer:txtlayer];

            [self.layer addSublayer:upperLayer];
        }
        
        if (!lowerLayer) {
         
            CGRect lowFrame = self.frontImageView.frame;
            lowerLayer = [self layerWithContents:(id)(self.frontImageView.image.CGImage)
                                            rect:lowFrame
                                        maskRect:CGRectMake(lowFrame.origin.x
                                                            , lowFrame.origin.y +lowFrame.size.height*0.5
                                                            , lowFrame.size.width
                                                            , lowFrame.size.height*0.5)];
            
            // lowerLayer.transform = CATransform3DIdentity;
            [self.layer addSublayer:lowerLayer];
            [lowerLayer setHidden:YES];
        }
    }

}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{

    [super touchesCancelled:touches withEvent:event];
    [self removeLayers];
}

//bool toUSE = NO;
#pragma mark handle Touches

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
//    NSLog(@"moving");
    
    if([self.nextResponder isKindOfClass:[UIScrollView class]] ){
        
        UIScrollView *scrollParent = (UIScrollView *)self.nextResponder;

        if(!scrollParent.isDragging){
            
            [self addLayers];
     
            CGPoint currPoint  = [[touches anyObject]locationInView:self];
            CGFloat displacementInX = currPoint.x - preTouchLocation.x;
            CGFloat displacementInY = preTouchLocation.y - currPoint.y;
            
            CGFloat totalRotation = sqrt(displacementInX * displacementInX + displacementInY * displacementInY);
            rotation = (currPoint.y < preTouchLocation.y)?  rotation +totalRotation/110 :
                                                            rotation -totalRotation/110;
           
            float Rad_Deg = RADIANS_TO_DEGREES(M_PI * rotation);
 //           NSLog(@"RAD is %f",Rad_Deg);
            BOOL case1 = (Rad_Deg<136.0  && Rad_Deg >0)?YES : NO;
            BOOL case2 = isFront;
            if(case1 && case2){
//               NSLog(@"m34 value is %f",lowerLayer.transform.m34);
 
                CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
                rotationAndPerspectiveTransform.m34 = 1.0 / -500.0;
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI * rotation, 1.0f, 0.0f, 0.0f);
                
                self.frontImageView.layer.transform = rotationAndPerspectiveTransform;
                lowerLayer.transform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI *(0.5+rotation), 1.0f, 0.0f, 0.0f);
               // lowerLayer.sublayerTransform = CATransform3DRotate(rotationAndPerspectiveTransform, -(M_PI *(0.5+rotation)), 1.0f, 0.0f, 0.0f);
                if(lowerLayer.transform.m34 < -0.00196){
                    NSLog(@"Match match match...");
                    [upperLayer setHidden:YES];
                }else{
//                    NSLog(@"upper layer is also hidden");
                    [upperLayer setHidden:NO];
                }
                
                if(Rad_Deg >=90){
                    [lowerLayer setHidden:NO];
                }
                else{
//                NSLog(@"yo hiding the lower layer %f",Rad_Deg);
                    [lowerLayer setHidden:YES];
                }
            }
            else if(!isFront){
                NSLog(@"inside not front");
                CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
                rotationAndPerspectiveTransform.m34 = 1.0 / -500.0;
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI * rotation, 1.0f, 0.0f, 0.0f);
                
               self.backImageView.layer.transform = rotationAndPerspectiveTransform;
                lowerLayer.transform = CATransform3DRotate(rotationAndPerspectiveTransform, M_PI *(-0.5+rotation), 1.0f, 0.0f, 0.0f);
                
                if(Rad_Deg <= -90){
                    NSLog(@"setting not hidden");
                    [lowerLayer setHidden:NO];
                }
                else{
                    [lowerLayer setHidden:YES];
                }
            }
            
            preTouchLocation = currPoint;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
//    NSLog(@"touches ended");
    
    if (isFront && RADIANS_TO_DEGREES(M_PI * rotation)) {
        if(lowerLayer.transform.m34 < -0.00196){
            [self bringSubviewToFront:self.backImageView];
            [self removeLayers];
        }
        else if(lowerLayer.transform.m34 >0){
        
            if (self.frontImageView.layer.transform.m34 !=CATransform3DIdentity.m34) {
                
                CABasicAnimation *animation = [self animationForKeyPath:@"transform"
                                                                options:@{@"TransformAnimation": @"resetFrontImage"}
                                                              transform:CATransform3DIdentity];
                animation.delegate = self;
                [self.frontImageView.layer addAnimation:animation forKey:@"transform"];
            }
           // NSLog(@"m34 value is %f",lowerLayer.transform.m34);
        }
        else if(lowerLayer.transform.m34 <0){
            
            NSLog(@"m34 value is %f",lowerLayer.transform.m34);
            CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform.m34 = 1.0 / -500.0;
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, DEGREES_TO_RADIANS(359.9), 1.0f, 0.0f, 0.0f);
            
            CABasicAnimation *animation = [self animationForKeyPath:@"transform"
                                                            options:@{@"TransformAnimation": @"finishFrontToBack"}
                                                          transform:rotationAndPerspectiveTransform];
            animation.delegate = self;
            [lowerLayer addAnimation:animation forKey:@"transform"];
        }
    }
    else if(!isFront){
    
        if (lowerLayer.hidden) {
            
            CABasicAnimation *animation = [self animationForKeyPath:@"transform"
                                                            options:@{@"TransformAnimation": @"resetbackImage"}
                                                          transform:CATransform3DIdentity];
            animation.delegate = self;
            [self.backImageView.layer addAnimation:animation forKey:@"transform"];
        }
        else{
        
            CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform.m34 = 1.0 / -500.0;
            
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, DEGREES_TO_RADIANS(359.0), 1.0f, 0.0f, 0.0f);
           
            CABasicAnimation *animation = [self animationForKeyPath:@"transform"
                                                            options:@{@"TransformAnimation": @"finishBackToFront"}
                                                          transform:rotationAndPerspectiveTransform];
            animation.delegate = self;
            [lowerLayer addAnimation:animation forKey:@"transform"];
        }
    }
}

-(CABasicAnimation *)animationForKeyPath:(NSString *)keyPath options:(NSDictionary *)optionsDict transform:(CATransform3D)transform3D{

    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath: keyPath];
    [transformAnimation setValue:[optionsDict allValues][0] forKey:[optionsDict allKeys][0]];
    transformAnimation.fillMode = kCAFillModeForwards;
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.toValue = [NSValue valueWithCATransform3D:transform3D];
    transformAnimation.duration = 0.3;
    
    return transformAnimation;
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{

    NSLog(@"called for animation %@",[anim description]);
    
    if (flag) {

        rotation = 0;
        
        [self removeLayers];
        
        [self.frontImageView.layer removeAllAnimations];
        self.frontImageView.layer.transform = CATransform3DIdentity;
        
        NSString *animKeyValue = [anim valueForKey:@"TransformAnimation"];
        
        if([animKeyValue isEqual:@"resetFrontImage"] || [animKeyValue isEqual:@"finishBackToFront"]){
        
            [self removeBackView];
            isFront = YES;
        }
        else if ([animKeyValue isEqual:@"finishFrontToBack"] || [animKeyValue isEqual:@"resetbackImage"]){
            
            [self.backImageView.layer removeAllAnimations];
            self.backImageView.layer.transform = CATransform3DIdentity;
            [self bringSubviewToFront:self.backImageView];
            isFront = NO;
        }
    }
}

#pragma mark manage adding/ removing of backView
-(void)addBackView{

    if (!self.backImageView) {
      
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
       // [image setImage:[UIImage imageNamed:_modelCard.backImage]];
//TODO: use proper images
         [image setImage:[UIImage imageNamed:@"Tmp"]];
        [self insertSubview:image belowSubview:self.frontImageView];
        self.backImageView = image;
        [self.backImageView.layer setDoubleSided:NO];
//        
        float height = self.frame.size.height - TEXT_VIEW_PADDING *7;
        float width = self.frame.size.width - TEXT_VIEW_PADDING *2;
        
        CGRect txtRect = CGRectMake(TEXT_VIEW_PADDING, TEXT_VIEW_PADDING *6, width, height);

        UITextView *txtView = [[UITextView alloc] initWithFrame:txtRect];
        [txtView setText:_modelCard.axiomText];

        [self.backImageView addSubview:txtView];

        self.axiomTextView = txtView;
        [self.axiomTextView setAxiomTextViewStyle];
        [self.axiomTextView setHidden:YES];
    }
}

-(void)removeLayers{

    [lowerLayer removeAllAnimations];
    [lowerLayer removeFromSuperlayer];
    lowerLayer = nil;

    [upperLayer removeAllAnimations];
    [upperLayer removeFromSuperlayer];

    upperLayer = nil;
}

-(void)removeBackView{
    
    [self.axiomTextView removeFromSuperview];
    self.axiomTextView = nil;
    
    [self.backImageView.layer removeAllAnimations];
    [self.backImageView removeFromSuperview];
    self.backImageView = nil;
}
#pragma mark -

@end
