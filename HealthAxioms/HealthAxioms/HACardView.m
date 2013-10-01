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
//@property (nonatomic, weak) UITextView *axiomTextView;
@property (nonatomic, weak) UIImageView *frontImageView;
//@property (nonatomic, weak) UIImageView *backImageView;
@end

@implementation HACardView{

    float rotation;
    CALayer *upperLayer;
    CALayer *lowerLayer;
    CALayer *txLayer;
    BOOL isFront;
    CGPoint preTouchLocation;
    BOOL needToChange;
    NSTimer *animTimer;
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
        
//Adding the swipe Gestures
        [self addSwipeGestures];
        
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

#pragma mark add the SwipeGestures

-(void)addSwipeGestures{
    UISwipeGestureRecognizer *upReco = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleSwipe:)];
    [upReco setDirection:UISwipeGestureRecognizerDirectionUp];
    upReco.delegate = self;
    upReco.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:upReco];
    
    
    UISwipeGestureRecognizer *downReco = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleSwipe:)];
    [downReco setDirection:UISwipeGestureRecognizerDirectionDown];
    downReco.delegate = self;
    downReco.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:downReco];

}

-(void)handleSwipe:(UIGestureRecognizer *)reco{

    UISwipeGestureRecognizer *swipeReco = (UISwipeGestureRecognizer *)reco;
    BOOL isUp = (swipeReco.direction == UISwipeGestureRecognizerDirectionUp)? YES :NO;
    
    if (swipeReco.state == UIGestureRecognizerStateEnded || swipeReco.state == UIGestureRecognizerStateFailed){

        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 / -500.0;
//        CABasicAnimation *animation;
        if (isUp) {
            NSLog(@"swipe Up Ended");
            if (isFront) {
                //Animate from front to back
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform
                                                                      , M_PI/180 * 179.9f
                                                                      , 1.0f
                                                                      , 0.0f
                                                                      , 0.0f);
                 [self addAnimationWithTransform:rotationAndPerspectiveTransform
                                         options:@{@"TransformAnimation": @"frontToBack"}];
            }
            else{
                //Animate a lil and snap back
            }
        }
        else{
            NSLog(@"swipe Down Ended");
            if (!isFront) {
                //Animate from back to Front
                rotationAndPerspectiveTransform = self.frontImageView.layer.transform;
                //rotationAndPerspectiveTransform.m34 = 1.0 / -500.0;
                rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform
                                                                      , M_PI/180 * -179.9f
                                                                      , 1.0f
                                                                      , 0.0f
                                                                      , 0.0f);
                [self addAnimationWithTransform:rotationAndPerspectiveTransform
                                        options:@{@"TransformAnimation": @"backToFront"}];
            }
            else{
                //Animate a lil and snap back
            }
        }
    }
}

-(void)addAnimationWithTransform:(CATransform3D)perspectiveAndRotateTx options:(NSDictionary *)options{

   static NSString *transFormKeyPath = @"transform";
    
    CABasicAnimation *animation;

    animation = [self animationForKeyPath:transFormKeyPath
                                  options:[options copy]
                                transform:perspectiveAndRotateTx];
    animation.delegate = self;
    [self.frontImageView.layer addAnimation:animation forKey:transFormKeyPath];
}

#pragma mark -

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

                [self.frontImageView setImage:[self imageForBakcView:@"Card-Back" flipped:YES]];
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
-(UIImage *)imageForBakcView:(NSString *)imgName flipped:(BOOL)isFlipped{
    
    UIImage *imgToReturn = nil;
    UIImage *image = (isFlipped)?[UIImage imageWithCGImage:[UIImage imageNamed:imgName].CGImage
                                         scale:2.0
                                               orientation:UIImageOrientationDownMirrored] :
                                 [UIImage imageNamed:imgName];
    
    CGSize imgSize = self.frontImageView.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 2.0);
    //drawing the image
    [image drawInRect:self.frontImageView.bounds];
    //[image drawAtPoint:CGPointMake(0, 0)];
    
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
    
    if (!isFlipped) {
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, imgSize.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
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



#pragma mark handle the change in views visibility

-(void)checkAnimations:(id)sender{
    
    CALayer* layer = [self.frontImageView.layer presentationLayer];
    
    CATransform3D rotationTransform = [(CALayer *)[layer presentationLayer] transform];
    
    float radToDeg = RADIANS_TO_DEGREES(atan2(rotationTransform.m23, rotationTransform.m22));
    
    NSLog(@"rad To Degree is %f", radToDeg);
    
    if (radToDeg >=30.0 && isFront) {
        self.frontImageView.image = nil;

        [self.frontImageView setImage:[self imageForBakcView:@"Card-Back" flipped:YES]];
        [animTimer invalidate];
        NSLog(@"changing contents");
    }
    else if (radToDeg <0.0 && !isFront) {
        self.frontImageView.image = nil;
        
        UIImage *image = [UIImage imageWithCGImage:[UIImage imageNamed:_modelCard.frontImage].CGImage
                                             scale:2.0
                                       orientation:UIImageOrientationDownMirrored];
        CGSize imgSize = self.frontImageView.bounds.size;
        
        UIGraphicsBeginImageContextWithOptions(imgSize, NO, 2.0);
        //drawing the image
        [image drawAtPoint:CGPointMake(0, 0)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.frontImageView setImage:image];
        
        [animTimer invalidate];
        NSLog(@"changing contents");
    }
    
    NSLog(@"front view bounds are %@", NSStringFromCGRect(self.frontImageView.bounds));
    
//    NSLog(@"angle is %f",RADIANS_TO_DEGREES(atan2(rotationTransform.m23, rotationTransform.m22)));

}

#pragma mark handling the animations
-(CABasicAnimation *)animationForKeyPath:(NSString *)keyPath options:(NSDictionary *)optionsDict transform:(CATransform3D)transform3D{

    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath: keyPath];
    [transformAnimation setValue:[optionsDict allValues][0] forKey:[optionsDict allKeys][0]];
    transformAnimation.fillMode = kCAFillModeForwards;
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.toValue = [NSValue valueWithCATransform3D:transform3D];
    transformAnimation.duration = 0.3;
    
    animTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                 target:self
                                               selector:@selector(checkAnimations:)
                                               userInfo:nil
                                                repeats:YES];
    return transformAnimation;
}


-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{

    NSLog(@"called for animation %@",[anim description]);
  if([animTimer isValid])    [animTimer invalidate];
    if (flag) {

        rotation = 0;
//        self.frontImageView.layer.transform = CATransform3DIdentity;
        [self.frontImageView.layer removeAllAnimations];
        
        NSString *animKeyValue = [anim valueForKey:@"TransformAnimation"];
        
        if([animKeyValue isEqual:@"resetFrontImage"] || [animKeyValue isEqual:@"backToFront"]){
        
            isFront = YES;
            [self.frontImageView setImage:[UIImage imageNamed:_modelCard.frontImage]];
        }
        else if ([animKeyValue isEqual:@"frontToBack"]){
            
            isFront = NO;
            [self.frontImageView setImage:[self imageForBakcView:@"Card-Back" flipped:NO]];
        }
    }
    
    NSLog(@"front view bounds  at end are %@", NSStringFromCGRect(self.frontImageView.bounds));
}

@end
