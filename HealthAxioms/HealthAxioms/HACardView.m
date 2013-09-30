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
#import <CoreText/CoreText.h>

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
    BOOL needToChange;
}

- (id)initWithFrame:(CGRect)frame model:(HABaseCard *)card
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//Initializing Local Variables
        isFront = YES;
        _modelCard = card;
        rotation = 0;
        needToChange = NO;
        preTouchLocation = CGPointZero;
        _fontSize = DEFAULT_FONT_SIZE;
        
//Adding Pinch Gesturte
//        UIPinchGestureRecognizer *pinchReco = [[UIPinchGestureRecognizer alloc]initWithTarget:self
//                                                              action:@selector(handlePinch:)];
//        
//        [self addGestureRecognizer:pinchReco];
        
//Setting the Image based on the state
        NSString *imgNameToUse = (_modelCard.isFront)? _modelCard.frontImage :
                                                        _modelCard.backImage;
        
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [image setImage:[UIImage imageNamed:imgNameToUse]];
        [self addSubview:image];
        self.frontImageView = image;
//Setting backGround Color
#warning Comment this to remove image background color
        [self.frontImageView setBackgroundColor:[UIColor blackColor]];
        
    }
    return self;
}

#pragma mark handle the change in views visibility

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    NSLog(@"change is %@", change);
}

#pragma mark manage touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"started");
    preTouchLocation = [[touches anyObject] locationInView:self];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{

    [super touchesCancelled:touches withEvent:event];
}

-(float)rotationFromNewPoint:(CGPoint)newPoint{

    //CGPoint currPoint  = [[touches anyObject]locationInView:self];
    CGFloat displacementInX = newPoint.x - preTouchLocation.x;
    CGFloat displacementInY = preTouchLocation.y - newPoint.y;
    
    CGFloat totalRotation = sqrt(displacementInX * displacementInX + displacementInY * displacementInY);
    rotation = (newPoint.y < preTouchLocation.y)?  (rotation +totalRotation) :
                                                    (rotation -totalRotation);
    rotation = fmodf(rotation, 360.0);
    return rotation;
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
//    NSLog(@"moving");
    
    if([self.nextResponder isKindOfClass:[UIScrollView class]] ){
        
        UIScrollView *scrollParent = (UIScrollView *)self.nextResponder;
//CHecking to see if the scrollview is not dragging
        if(!scrollParent.isDragging){
            
            CGPoint currPoint  = [[touches anyObject]locationInView:self];
//creating the new transform to be applied
            CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
            rotationAndPerspectiveTransform.m34 = 1.0 / -500.0;
            rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform
                                                                  , M_PI/180 * [self rotationFromNewPoint:currPoint]
                                                                  , 1.0f
                                                                  , 0.0f
                                                                  , 0.0f);
//Setting the image transform to the new one
            self.frontImageView.layer.transform = rotationAndPerspectiveTransform;
          
//Finding the angle of rotation (tan∆ = y/x)
            float angleRot = RADIANS_TO_DEGREES(atan2(rotationAndPerspectiveTransform.m23, rotationAndPerspectiveTransform.m22));
 // NSLog(@"rotation is %f", rotation);
            
            BOOL case1 =(angleRot >=90)?YES : NO;
            BOOL case2 = (angleRot >0.0)?YES :NO;
            
            if (case1 &&case2 && !needToChange) {
                NSLog(@"called");

                [self.frontImageView setImage:[self imageForBakcView:@"Tmp"]];
                needToChange = YES;
            }
            if (!case1 && case2) {
                
                [self.frontImageView setImage:[UIImage imageNamed:_modelCard.frontImage]];
            }
            preTouchLocation = currPoint;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //    NSLog(@"touches ended");
    
    if (isFront && RADIANS_TO_DEGREES(M_PI * rotation)) {
        
        
        CABasicAnimation *animation = [self animationForKeyPath:@"transform"
                                                        options:@{@"TransformAnimation": @"resetFrontImage"}
                                                      transform:CATransform3DIdentity];
        animation.delegate = self;
        [self.frontImageView.layer addAnimation:animation forKey:@"transform"];
    }
    
    needToChange = NO;
}

#pragma mark Creating the back image with text
//Creating the back image with text
-(UIImage *)imageForBakcView:(NSString *)imgName{
    
    UIImage *imgToReturn = nil;
    UIImage *image = [UIImage imageWithCGImage:[UIImage imageNamed:imgName].CGImage
                                         scale:2.0
                                    orientation:UIImageOrientationDownMirrored];
    CGSize imgSize = self.frontImageView.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 2.0);
    //drawing the image
    [image drawAtPoint:CGPointMake(0, 0)];
    
    //creating the text
    UIGraphicsPushContext(UIGraphicsGetCurrentContext());

    CGMutablePathRef path = CGPathCreateMutable(); //1
    CGPathAddRect(path, NULL, CGRectMake(TEXT_VIEW_PADDING *1.25, TEXT_VIEW_PADDING , self.frontImageView.bounds.size.width - TEXT_VIEW_PADDING *2.5, self.frontImageView.bounds.size.height - TEXT_VIEW_PADDING *6.5) );
    
    NSString *font =@"GillSans";
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font,
                                             16.0f, NULL);
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)[UIColor colorWithRed:0.16f green:0.14f blue:0.40f alpha:1.00f].CGColor, kCTForegroundColorAttributeName,
                           (__bridge id)fontRef, kCTFontAttributeName,
                                                      nil];
    
    NSAttributedString* attString = [[NSAttributedString alloc]
                                      initWithString:_modelCard.axiomText
                                     attributes:attrs]; //2

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString); //3
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                             CFRangeMake(0, [attString length]), path, NULL);
    
    CTFrameDraw(frame, UIGraphicsGetCurrentContext()); //4
    
    CFRelease(frame); //5
    CFRelease(path);
    CFRelease(framesetter);
    
    UIGraphicsPopContext();
        //creating image from the current context
    imgToReturn = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    needToChange = NO;
    return imgToReturn;
}

#pragma mark handling the animations
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
        self.frontImageView.layer.transform = CATransform3DIdentity;
        [self.frontImageView.layer removeAllAnimations];
        [self.frontImageView setImage:[UIImage imageNamed:_modelCard.frontImage]];
        isFront = YES;
        
//        NSString *animKeyValue = [anim valueForKey:@"TransformAnimation"];
//        
//        if([animKeyValue isEqual:@"resetFrontImage"] || [animKeyValue isEqual:@"finishBackToFront"]){
//        
//            isFront = YES;
//        }
//        else if ([animKeyValue isEqual:@"finishFrontToBack"] || [animKeyValue isEqual:@"resetbackImage"]){
//            
//            isFront = NO;
//        }
    }
}

@end
