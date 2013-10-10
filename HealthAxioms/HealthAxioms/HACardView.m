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

static NSString * const ANIMATIONKEY = @"TransformAnimation";
static NSString * const ANIM_B2F = @"backToFront";
static NSString * const ANIM_F2B = @"frontToBack";



@interface HACardView ()

@property (nonatomic, assign) int fontSize;
@property (nonatomic, weak) UIImageView *frontImageView;
@property (nonatomic, weak) UISwipeGestureRecognizer *upSwipe;
@property (nonatomic, weak) UISwipeGestureRecognizer *downSwipe;

@end

@implementation HACardView{

    float rotation;
    BOOL isFront;
    CGPoint preTouchLocation;
    BOOL needToChange;
    NSTimer *animTimer;

}



- (id)initWithFrame:(CGRect)frame model:(HABaseCard *)card
{
    self = [super initWithFrame:frame];
    if (self) {
        
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
        [self.frontImageView setBackgroundColor:[UIColor blackColor]];
//        [self.layer setCornerRadius:6.0f];

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
    self.upSwipe = upReco;
    
    UISwipeGestureRecognizer *downReco = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleSwipe:)];
    [downReco setDirection:UISwipeGestureRecognizerDirectionDown];
    downReco.delegate = self;
    downReco.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:downReco];
    self.downSwipe = downReco;

}

-(void)handleSwipe:(UIGestureRecognizer *)reco{

   
    
    UISwipeGestureRecognizer *swipeReco = (UISwipeGestureRecognizer *)reco;
    BOOL isUp = (swipeReco.direction == UISwipeGestureRecognizerDirectionUp)? YES :NO;
    
    if (swipeReco.state == UIGestureRecognizerStateEnded || swipeReco.state == UIGestureRecognizerStateFailed){

        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 / -500.0;
        
        float rotationAngle = (isUp)? 170.0f : -179.0f;
        NSString *animationValue = (isFront)? ANIM_F2B : ANIM_B2F;
        
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform
                                                              , M_PI/180 * (rotationAngle)
                                                              , 1.0f
                                                              , 0.0f
                                                              , 0.0f);
        [self addAnimationWithTransform:rotationAndPerspectiveTransform
                                options:@{ANIMATIONKEY: animationValue}];
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

/*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"started");
    preTouchLocation = [[touches anyObject] locationInView:self];
    
    [self.upSwipe setEnabled:NO];
    [self.downSwipe setEnabled:NO];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{

    [super touchesCancelled:touches withEvent:event];
    [self.upSwipe setEnabled:YES];
    [self.downSwipe setEnabled:YES];
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
//Checking to see if the scrollview is not dragging
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
//TODO: Check for current state and based on that allow the rotation to be applied

//    1) isFront and +rotation - allow
//               and -rotation - allow to certain and then snap back 
// 
//    2) !isFront and -rotation - allow
//                and +rotation - allow to certain and then snap back

            self.frontImageView.layer.transform = rotationAndPerspectiveTransform;
          
//Finding the angle of rotation (tan∆ = y/x)
            float angleRot = RADIANS_TO_DEGREES(atan2(rotationAndPerspectiveTransform.m23, rotationAndPerspectiveTransform.m22));
            NSLog(@"angleRot is %f", angleRot);
            
            BOOL case1 = (angleRot >=90)?YES : NO;
            BOOL case2 = (angleRot >0.0)?YES : NO;
            
            if (case1 &&case2 && !needToChange) {
                NSLog(@"called");

                [self.frontImageView setImage:[self imageForBackView:@"Card-Back" flipped:YES]];
                needToChange = YES;
            }
            else if (!case2 && angleRot < -89.0f) {
//drawing the image upsideDown
                UIImage *image = [UIImage imageWithCGImage:[UIImage imageNamed:_modelCard.frontImage].CGImage
                                                     scale:2.0
                                               orientation:UIImageOrientationDownMirrored];
                CGSize imgSize = self.frontImageView.bounds.size;
                
                UIGraphicsBeginImageContextWithOptions(imgSize, NO, 2.0);
                [image drawAtPoint:CGPointMake(0, 0)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                [self.frontImageView setImage:image];
            }
            preTouchLocation = currPoint;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //    NSLog(@"touches ended");
    float angleRot = [self persPectiveRotation];
    NSLog(@"angle Rot is %f", angleRot);
    CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;

    if(isFront && angleRot >0){
    
        rotationAndPerspectiveTransform = self.frontImageView.layer.transform;
        //rotationAndPerspectiveTransform.m34 = 1.0 / -500.0;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform
                                                              , (M_PI/180)*(179.0 - angleRot)
                                                              , 1.0f
                                                              , 0.0f
                                                              , 0.0f);
        [self addAnimationWithTransform:rotationAndPerspectiveTransform
                                options:@{@"TransformAnimation": @"frontToBack"}];
        
    }else if (!isFront && angleRot <0){
    
        rotationAndPerspectiveTransform = self.frontImageView.layer.transform;
//        rotationAndPerspectiveTransform.m34 = 1.0 / -500.0;
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform
                                                              , M_PI/180 * -(359.9f -angleRot)
                                                              , 1.0f
                                                              , 0.0f
                                                              , 0.0f);
        [self addAnimationWithTransform:rotationAndPerspectiveTransform
                                options:@{@"TransformAnimation": @"backToFront"}];
    }
    
    needToChange = NO;
    [self.upSwipe setEnabled:YES];
    [self.downSwipe setEnabled:YES];
}
*/
#pragma mark Creating the back image with text
//Creating the back image with text

-(UIImage *)imageForBackView:(NSString *)imgName flipped:(BOOL)isFlipped{
    
    UIImage *imgToReturn = nil;
    UIImage *image = (isFlipped)?[UIImage imageWithCGImage:[UIImage imageNamed:imgName].CGImage
                                                     scale:2.0
                                               orientation:UIImageOrientationDownMirrored] :
                                 [UIImage imageNamed:imgName];
    
    CGSize imgSize = self.frontImageView.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 2.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //drawing the image
    [image drawInRect:self.frontImageView.bounds];

    UIGraphicsPushContext(ctx);
    
    //draw title
    CGSize titleSize =   [self drawTitleInContext:ctx
                                           ofSize:self.frontImageView.bounds.size
                                          flipped:isFlipped];
    
//draw string
    [self drawTextInContext:ctx
                     ofSize:titleSize
                    flipped:isFlipped];
    
    UIGraphicsPopContext();
    
    imgToReturn = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    needToChange = NO;
    return imgToReturn;
}

//num of lines in the title
int titleLines = 1;

-(CGSize)drawTitleInContext:(CGContextRef)graphicsCtx ofSize:(CGSize)size flipped:(BOOL)isFlip {
    
    static  NSString *titleFont =@"Kremlin";
    
    CGMutablePathRef path = CGPathCreateMutable(); //1
    CGPathAddRect(path, NULL, CGRectMake(TEXT_VIEW_PADDING *1.25
                                         , size.height - 240.0f
                                         , size.width - TEXT_VIEW_PADDING *2.5
                                         , size.height - TEXT_VIEW_PADDING *14) );
    
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)titleFont,
                                             24.0f, NULL);
    //(id)[NSNumber numberWithFloat:-1.0f], kCTKernAttributeName,
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)[UIColor colorWithRed:0.16f green:0.14f blue:0.40f alpha:1.00f].CGColor, kCTForegroundColorAttributeName,
                           (__bridge id)fontRef, kCTFontAttributeName,
                           nil];
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc]
                                            initWithString:[_modelCard.axiomTitle uppercaseString]
                                            attributes:attrs]; //2

    NSInteger strLength = [attString length];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    [attString addAttribute:NSParagraphStyleAttributeName
                      value:style
                      range:NSMakeRange(0, strLength)];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString); //3
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, strLength), path, NULL);
    
    if (!isFlip) {
        CGContextTranslateCTM(graphicsCtx, 0, size.height);
        CGContextScaleCTM(graphicsCtx, 1.0, -1.0);
    }
    
//Calculating number of lines in the title
    CFArrayRef array = CTFrameGetLines(frame);
    CFIndex index = CFArrayGetCount(array);
    titleLines = index;
//    NSLog(@"num of lines is %ld", index);
    
    CTFrameDraw(frame, graphicsCtx); //4
    CFRelease(frame); //5
    CFRelease(path);
    CFRelease(framesetter);

    CGSize strSize = [attString size];
    attString = nil;
    return strSize;
    
}


-(void)drawTextInContext:(CGContextRef)graphicsCtx ofSize:(CGSize)size flipped:(BOOL)isFlip {

    static  NSString *font = @"GillSans";
    
    CGMutablePathRef path = CGPathCreateMutable(); //1
    CGPathAddRect(path, NULL, CGRectMake(TEXT_VIEW_PADDING *1.25
                                         ,( self.frame.origin.y -size.height*titleLines)
                                         , self.frame.size.width - TEXT_VIEW_PADDING *2.5
                                         , self.frame.size.height - TEXT_VIEW_PADDING *6.5) );
    
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font,
                                             16.0f, NULL);
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)[UIColor colorWithRed:0.16f green:0.14f blue:0.40f alpha:1.00f].CGColor, kCTForegroundColorAttributeName,
                           (__bridge id)fontRef, kCTFontAttributeName,
                           nil];
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc]
                                     initWithString:_modelCard.axiomText
                                     attributes:attrs]; //2
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    [style setMinimumLineHeight:14];
    [style setMaximumLineHeight:14];

    [attString addAttribute:NSParagraphStyleAttributeName
                      value:style
                      range:NSMakeRange(0, [attString length])];
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString); //3
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, [attString length]), path, NULL);
    
    /*
     did not flip the coordinate system since, it was already flipped while drawing the title.
     And we are still using the same context to draw text
     */
    
    CTFrameDraw(frame, graphicsCtx); //4
    CFRelease(frame); //5
    CFRelease(path);
    CFRelease(framesetter);
}

-(float)persPectiveRotation{

    CALayer* layer = [self.frontImageView.layer presentationLayer];
    
    CATransform3D rotationTransform = [(CALayer *)[layer presentationLayer] transform];
    
    float deg = RADIANS_TO_DEGREES(atan2(rotationTransform.m23, rotationTransform.m22));
    
//    NSLog(@"rad To Degree is %f", deg);
    return deg;
}

#pragma mark handle the change in views visibility

-(void)checkAnimations:(id)sender{
    
    float radToDeg = [self persPectiveRotation];
    
    NSLog(@"rad To Degree is %f", radToDeg);
    
    if (isFront) {
    
        if ((radToDeg >0 && radToDeg >=40.0f) || (radToDeg <0 && radToDeg < -40.0f)) {
            self.frontImageView.image = nil;
            
            [self.frontImageView setImage:[self imageForBackView:@"Card-Back" flipped:YES]];
            [animTimer invalidate];
            NSLog(@"changing contents +radToDeg");
        }
    }
    else{
    
        if ((radToDeg <0 && radToDeg < -80.0f) || (radToDeg >0 && radToDeg >=80.0f)) {
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
            NSLog(@"changing contents -radToDeg");
            [animTimer invalidate];

        }
    }
    
}

#pragma mark handling the animations
-(CABasicAnimation *)animationForKeyPath:(NSString *)keyPath options:(NSDictionary *)optionsDict transform:(CATransform3D)transform3D{

    static float duration = 0.3f;
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath: keyPath];
    [transformAnimation setValue:[optionsDict allValues][0] forKey:[optionsDict allKeys][0]];
    transformAnimation.fillMode = kCAFillModeForwards;
    transformAnimation.removedOnCompletion = NO;
    transformAnimation.toValue = [NSValue valueWithCATransform3D:transform3D];
    transformAnimation.duration = duration;
    
    animTimer = [NSTimer scheduledTimerWithTimeInterval:(duration/10)
                                                 target:self
                                               selector:@selector(checkAnimations:)
                                               userInfo:nil
                                                repeats:YES];
    return transformAnimation;
}


-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{

//    NSLog(@"Handling End of animation %@",[anim description]);
    if([animTimer isValid])    [animTimer invalidate];
    if (flag) {

        rotation = 0;
        self.frontImageView.layer.transform = CATransform3DIdentity;
        [self.frontImageView.layer removeAllAnimations];
        
        NSString *animKeyValue = [anim valueForKey:ANIMATIONKEY];
        
        if([animKeyValue isEqual:@"resetFrontImage"] || [animKeyValue isEqual:ANIM_B2F]){
        
            isFront = YES;
            [self.frontImageView setImage:[UIImage imageNamed:_modelCard.frontImage]];
        }
        else if ([animKeyValue isEqual:ANIM_F2B]){
            
            isFront = NO;
            [self.frontImageView setImage:[self imageForBackView:@"Card-Back" flipped:NO]];
        }
    }
}

-(void)manageBackToDeck{

    if (!isFront) {
        CATransform3D rotationAndPerspectiveTransform = CATransform3DIdentity;
        rotationAndPerspectiveTransform = self.frontImageView.layer.transform;
        
        rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform
                                                              , M_PI/180 * -179.9f
                                                              , 1.0f
                                                              , 0.0f
                                                              , 0.0f);
        [self addAnimationWithTransform:rotationAndPerspectiveTransform
                                options:@{ANIMATIONKEY: ANIM_B2F}];
    }
}

@end
