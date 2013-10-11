//
//  HADetailViewController.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import "HADetailViewController.h"
#import "HACardView.h"
#import "HAModel.h"
#import "HABaseCard.h"
#import "HAAxiomCell.h"

#define PAGE_WIDTH   ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define MAX_NUM_PAGES 5

@interface HADetailViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (nonatomic, strong)HAModel *axiomsModel;
@property (nonatomic, strong)NSMutableArray *currIndexes;
@property (weak, nonatomic) IBOutlet UICollectionView *miniAxiomPicker;

-(IBAction)actionItemTapped:(id)sender;
@end

@implementation HADetailViewController{

    CGPoint scrollLastOffset;
}

#pragma mark view related methods

-(void)dealloc{

    self.delegate = nil;
    self.axiomsModel = nil;
    self.miniAxiomPicker = nil;
    self.navBar = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //TODO: Hide the Navigation Bar with Animation
    [self addItemsToScrollView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

-(NSMutableArray *)currIndexes{

    if (!_currIndexes) {
        _currIndexes = [NSMutableArray arrayWithCapacity:MAX_NUM_PAGES];
    }
    return _currIndexes;
}

-(HAModel *)axiomsModel{

    if (!_axiomsModel) {
        _axiomsModel = [HAModel sharedModel];
    }
    return _axiomsModel;
}

#pragma mark Add Items to ScrollView

-(int)startIndexFromChosenCardIndex:(int)chosen{
    
    int totalAxiomNum = [self.axiomsModel totalAxioms];
    
    int indexToStart = chosen - MAX_NUM_PAGES / 2;
    if ((indexToStart + MAX_NUM_PAGES) > totalAxiomNum) indexToStart = totalAxiomNum - MAX_NUM_PAGES;
    else if ((indexToStart - MAX_NUM_PAGES/2) < 0) indexToStart = 0;
    return indexToStart;
}
-(void)addItemsToScrollView{

//    If scroll indicatorrs will be visible
//Then scroll view will have two children uiimageViews
    
    float scrollContentWidth = PAGE_WIDTH * ([self.axiomsModel.axiomCardsList count]);
    float scrollContentHeight = PAGE_WIDTH/(self.axiomsModel.cardAspectRatio);
    
    //Prepare the container ScrollView
    [self.frontScroll setContentSize:CGSizeMake(scrollContentWidth, scrollContentHeight)];
    [self.frontScroll setFrame:CGRectMake(0
                                          , 0
                                          , PAGE_WIDTH
                                          , scrollContentHeight)];
    
    //Adding cards to scroll View
    int start = [self startIndexFromChosenCardIndex:_startAxiomIndex];
    for (int i= start; i< start+MAX_NUM_PAGES; i++) {

        [self addAxiomCardToScrollWithIndex:i];
        [self.currIndexes addObject:@(i)];
//        NSLog(@"adding %d", i);
    }
    
    // Scrolling to the selected card
    float xContentOffset = PAGE_WIDTH * (_startAxiomIndex-1);
    [_frontScroll setContentOffset:CGPointMake(xContentOffset, 0)
                          animated:NO];
    
    scrollLastOffset = _frontScroll.contentOffset;
    
}

#pragma mark adding axiom to the scroll view
-(void)addAxiomCardToScrollWithIndex:(int)modelIndex{

    float scrollContentHeight = PAGE_WIDTH/(self.axiomsModel.cardAspectRatio);
 
    HABaseCard *cardToUse = [self.axiomsModel.axiomCardsList objectAtIndex:modelIndex];
    CGRect cardRect = CGRectMake(modelIndex*PAGE_WIDTH
                                 ,(SCREEN_HEIGHT - scrollContentHeight)*0.5
                                 ,PAGE_WIDTH
                                 ,scrollContentHeight);
    
    HACardView *cardToAddToScroll = [[HACardView alloc]initWithFrame:cardRect
                                                               model:cardToUse];
    [self.frontScroll addSubview:cardToAddToScroll];
}

#pragma mark -

#pragma mark handling touches

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{

    BOOL toReturn = YES;
    
//    NSLog(@"gesture is Kind Of Class %@", [gestureRecognizer class]);
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] || [gestureRecognizer.view isKindOfClass:[UIScrollView class] ]) {
        
        
        if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
            UIPanGestureRecognizer *panReco = (UIPanGestureRecognizer *)gestureRecognizer;
            
//            NSLog(@"translation in x:%f y:%f",[panReco translationInView:self.frontScroll].x,[panReco translationInView:self.frontScroll].y );
            
            if ([panReco translationInView:self.frontScroll].x < [panReco translationInView:self.frontScroll].y ) {

                toReturn = NO;
                [self.frontScroll resignFirstResponder];
                [panReco setTranslation:CGPointZero inView:self.view];
                // NSLog(@"detected up down pan");
            }
        }
//        else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]){
//
//        }
    }
//    NSLog(@"returning %d",toReturn);
    return toReturn;
}

-(IBAction)handleTap:(id)sender{
    
    [self.navBar setHidden:YES];
    [self.miniAxiomPicker setHidden:YES];
    [self.view setBackgroundColor:[UIColor clearColor]];
// Making the card handle its state while being put back into decl
    [self makeCardHandlePlacingInDeck];
   
    __weak UIView *selfView = self.view;
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.9
          initialSpringVelocity:0.5
                        options: UIViewAnimationOptionAllowAnimatedContent| UIViewAnimationOptionBeginFromCurrentState
                     animations:^(){
                         float shrinkScaleY = self.initRect.size.height/470.0;
                         float shrinkScaleX = self.initRect.size.width/[UIScreen mainScreen].bounds.size.width;
                         [selfView setCenter:CGPointMake(self.initRect.origin.x+ self.initRect.size.width*0.5,self.initRect.origin.y+self.initRect.size.height*0.5)];
                         [selfView setTransform:CGAffineTransformScale(CGAffineTransformIdentity,shrinkScaleX, shrinkScaleY )];
                        
                     }
                     completion:^(BOOL finished){
                         
                         if (finished) {
                             self.willDealloc = YES;
                             [self removeObserver:self.parentViewController forKeyPath:@"willDealloc"];
                             self.delegate = nil;
                             [self.view removeFromSuperview];
                             [self didMoveToParentViewController:nil];
                             [self removeFromParentViewController];
                             
                         }
                     }
     ];
}

-(void)sortTheCurrentIndexes{
    [self.currIndexes sortUsingComparator:^(id obj1, id obj2){
        return ([obj1 compare:obj2]);
    }];
}

#pragma mark ScrollView Delegate Methods

-(void)sanityCheckForViewsWithOffset:(CGPoint)offset{
    
    int index = (offset.x/PAGE_WIDTH +1) -1;
    int upperBound = fmin([self.axiomsModel totalAxioms], index+2);
    int lowerBound = fmax(0, index-2);
    //    int length = upperBound - lowerBound;

    NSMutableArray *indexToRem = [NSMutableArray array];
    for (id obj in self.currIndexes) {
        NSLog(@"Checking for %d against low:%d high:%d", [obj integerValue],lowerBound,upperBound);
        if ([obj integerValue] > upperBound || [obj integerValue] < lowerBound) {
            [indexToRem addObject:obj];
             NSLog(@"marked %d for removal",[obj integerValue]);
            __block id ObjToRemove = nil;
            __weak NSArray *toIter = [self.frontScroll subviews] ;
            [toIter enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx,BOOL *stop){
                
                if ([obj2 isKindOfClass:[HACardView class]]) {
                    
                    HACardView  *card = (HACardView *)obj2;
                    HABaseCard *model = card.modelCard;
                    int index2 = model.index-1;
                    //Index for comparison calculated based on the direction of scroll
                    if (index2 == [obj integerValue]) {
                        ObjToRemove = card;
                        *stop = YES;
                    }
                }
                
            }];
            if (ObjToRemove) {
                
                [ObjToRemove removeFromSuperview];
                ObjToRemove = nil;
            }
        }
    }
    if([indexToRem count]){
        [self.currIndexes removeObjectsInArray:indexToRem];
    }
    indexToRem = nil;
    
    NSMutableArray *notFoundIndex = [NSMutableArray array];
    
    for (int i=lowerBound; i<upperBound; i++) {
        if (![self.currIndexes containsObject:@(i)]) {
            [notFoundIndex addObject:@(i)];
            [self addAxiomCardToScrollWithIndex:i];
        }
    }
   
    if([notFoundIndex count]){
    
        [self.currIndexes addObjectsFromArray:notFoundIndex];
        notFoundIndex = nil;
        [self sortTheCurrentIndexes];
    }
    
//    NSLog(@"Not found indexes were %@ \n current indexes %@ \n visible index is %d", notFoundIndex,self.currIndexes, index);
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"scroll view %@ did scroll",scrollView );
    BOOL case1 = ([[scrollView class] isSubclassOfClass:[UICollectionView class]])?YES : NO;
    if(!case1){
        
        CGPoint offsetToUse = scrollView.contentOffset;
        //Checking for left right motion of scrollView
//        NSLog(@"called");
        if(!CGPointEqualToPoint(scrollLastOffset, offsetToUse)){
            BOOL isMotionRight = (scrollLastOffset.x < offsetToUse.x) ? YES : NO;
            [self manageViewsWithOffSet:offsetToUse movingRight:isMotionRight];
            scrollLastOffset = offsetToUse;
        }
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{

    BOOL case1 = ([[scrollView class] isSubclassOfClass:[UICollectionView class]])?YES : NO;
    if(!case1){
        [self sanityCheckForViewsWithOffset:scrollView.contentOffset];
    }
}
/*
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

//    [scrollView becomeFirstResponder];

//    NSLog(@"scroll next responder is %@", scrollView.nextResponder);
    //Checking to see if the scrollview belongs to a mini UIcollectionView Picker
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

//    [scrollView resignFirstResponder];

//    BOOL case1 = ([[scrollView class] isSubclassOfClass:[UICollectionView class]])?YES : NO;
//    if(!case1){
//        [self sanityCheckForViewsWithOffset:scrollView.contentOffset];
//    }
//    NSLog(@"did end decelerating");
    
}
*/
#pragma mark -

#pragma mark manage images in memory
-(void)manageViewsWithOffSet:(CGPoint)contOffset movingRight:(BOOL)isMovingRight{
    
    int index = (contOffset.x/PAGE_WIDTH +1);
    
//    NSLog(@"Axiom at index:%d is in View ",index);
//Asking the delegate to handle and update view based on scroll
    if ([self.delegate respondsToSelector:@selector(handleScrollForAxiomAtIndex:)]) {
       self.initRect = [self.delegate handleScrollForAxiomAtIndex:index];
    }
//TODO: Use direction to calcutate the
//      required Image at index to Add and Remove
    int indexItemToAdd = (isMovingRight)? fmin([self.axiomsModel.axiomCardsList count], (index + MAX_NUM_PAGES/2)) :
                                          fmax(1, (index - MAX_NUM_PAGES/2))      ;
//check if the indexItem needs to be added
    if(![self isItemIndexInCurrentItems:indexItemToAdd-1 movingRight:isMovingRight]){
        NSLog(@"Need to add axiom with Index %d", indexItemToAdd-1);
        [self addAxiomCardToScrollWithIndex:indexItemToAdd-1];
    }
}


#pragma mark -

#pragma mark Manage addition of new Index and making sure indexes are correct
-(BOOL)isItemIndexInCurrentItems:(int)indexToCheck movingRight:(BOOL)isMovingRight{
    __block  BOOL toReturn = NO;

    [self.currIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,BOOL *stop){
     
        if ([obj integerValue] == indexToCheck ) {
            toReturn = YES;
            *stop = YES;
        }
    }];
    
    if (!toReturn) {
        
        __block id ObjToRemove = nil;
         __weak NSArray *toIter = [self.frontScroll subviews] ;
        [toIter enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,BOOL *stop){
        
            if ([obj isKindOfClass:[HACardView class]]) {

                HACardView  *card = (HACardView *)obj;
                HABaseCard *model = card.modelCard;
                int index = model.index-1;
//Index for comparison calculated based on the direction of scroll
                int indexToCompare = (isMovingRight)?[[self.currIndexes firstObject] integerValue] :
                                                     [[self.currIndexes lastObject] integerValue] ;
                if (index == indexToCompare) {
                    ObjToRemove = card;
                    *stop = YES;
                }
            }

        }];
//Removing the object that is not needed from the current set of indexes
        if (isMovingRight){[self.currIndexes removeObjectAtIndex:0];}
        else{[self.currIndexes removeLastObject];}
        
        if (ObjToRemove) {
            
            [ObjToRemove removeFromSuperview];
            ObjToRemove = nil;
        }
        
        [self.currIndexes addObject:@(indexToCheck)];
        [self sortTheCurrentIndexes];
    }
    
    return toReturn;
}
#pragma mark -

#pragma mark Managing the Collection View/DataSource/Flow delegate methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return [self.axiomsModel totalAxioms];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static  NSString *const CELL_IDENTIFIER = @"AxiomCardSmall";
    HAAxiomCell *axiomCell = (HAAxiomCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                                      forIndexPath:indexPath];
    [axiomCell.imgView.layer setCornerRadius:6.0f];
    
    //Getting the card from Model
    HABaseCard *card = self.axiomsModel.axiomCardsList[indexPath.row];

    
    CGSize frameSize = axiomCell.frame.size;
    NSString *imgName = [card.frontImage copy];
    NSString *keyName = nil;
    if (imgName && [imgName length]>1) {
        
        NSString *name =[imgName stringByAppendingString:[NSString stringWithFormat:@"%f",frameSize.height]] ;
        keyName = [[name dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        
        dispatch_queue_t myQue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_async(myQue, ^(){
    //Fetching the stored small image from userDefaults
            UIImage *imge = nil;
    //checking if the key exists or not
            if([[NSUserDefaults standardUserDefaults] objectForKey:keyName]){
                NSData *imageData = [[NSUserDefaults standardUserDefaults] dataForKey:keyName];
                imge = [NSKeyedUnarchiver unarchiveObjectWithData: imageData];
            }
    //Drawing the smaller image
            else if(!imge) {
                
                imge = [UIImage imageNamed:imgName];
                CGSize imageSize = frameSize;
                float xSize = imageSize.height * (imge.size.width/imge.size.height);
                UIGraphicsBeginImageContextWithOptions(imageSize,YES,0);
                [imge drawInRect:CGRectMake((imageSize.width-xSize)*0.5, 0, xSize, imageSize.height)];
                imge = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
        //Storing small image to userDefaults
                NSData *imageDta = [NSKeyedArchiver archivedDataWithRootObject:imge];
                [[NSUserDefaults standardUserDefaults] setObject:imageDta forKey:keyName];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(){
        //Updating the cell
                HAAxiomCell *axiomCellToUpdate = (HAAxiomCell *)[collectionView cellForItemAtIndexPath:indexPath];
                if(axiomCellToUpdate){
                    axiomCellToUpdate.imgView.image = nil;
                    [axiomCellToUpdate.imgView setImage:imge];
                    [axiomCellToUpdate setNeedsDisplay];
                }
            });
        });
    }

    return axiomCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"touched item at Index:%d", indexPath.row);
    float newX = indexPath.row * self.frontScroll.frame.size.width;
    float newY = self.frontScroll.frame.origin.y;
    [self.frontScroll scrollRectToVisible:CGRectMake(newX, newY, self.frontScroll.frame.size.width, self.frontScroll.frame.size.height)
                                 animated:YES];
}

#pragma mark Handle navBar item tap and Mail composer

-(IBAction)actionItemTapped:(id)sender{
    
    
    if (![MFMailComposeViewController canSendMail]) {
       
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cannot send email"
                                                       message:@"Please check email configuration"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil] ;
        [alert show];
    }
    else{
        
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc]init];
        mailVC.mailComposeDelegate = self;

        HABaseCard *cardToAttach = [self cardFromScrollOffset:scrollLastOffset];
        [mailVC setSubject:[NSString stringWithFormat:@"Health Axiom: %@", cardToAttach.axiomTitle]];
        
        UIImage *frontImage = [UIImage imageNamed:cardToAttach.frontImage];
        [mailVC addAttachmentData:[NSData dataWithData:UIImageJPEGRepresentation(frontImage, 1.0)]
                         mimeType:@"jpg"
                         fileName:[NSString stringWithFormat:@"%@.jpg",cardToAttach.frontImage]];
        
//Iterating through the subViews to find the one in view and create
//a back image to be added to the mail composer
        __weak  NSArray *views = self.frontScroll.subviews;
        __block  UIImage *backImage = nil;
        [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
            if ([obj isKindOfClass:[HACardView class]]) {
                
                HACardView  *card = (HACardView *)obj;
                HABaseCard *model = card.modelCard;
                int index2 = model.index;
                //Index for comparison calculated based on the direction of scroll
                if (index2 == cardToAttach.index) {
                    *stop = YES;
                    backImage = [card imageForBackView:@"Card-Back"
                                               flipped:NO];
                }
            }

        }];
        
        if(backImage){
            [mailVC addAttachmentData:[NSData dataWithData:UIImageJPEGRepresentation(backImage, 1.0)]
                             mimeType:@"jpg"
                             fileName:[NSString stringWithFormat:@"%@.jpg",cardToAttach.backImage]];
        }
        if (cardToAttach) {

            [mailVC setMessageBody:cardToAttach.axiomText isHTML:YES];
        }
        

        [self presentViewController:mailVC
                           animated:YES
                         completion:nil];
    }
}


-(HABaseCard *)cardFromScrollOffset:(CGPoint)offset{

    int cardNum = offset.x / self.frontScroll.frame.size.width;
    
    HABaseCard *card = [self.axiomsModel cardForIndex:cardNum];

    return card;
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{

    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark manage the card state while placing it back in deck

-(void)makeCardHandlePlacingInDeck{

    int cardNum = scrollLastOffset.x / self.frontScroll.frame.size.width;
    __weak NSArray *toIter = [self.frontScroll subviews] ;
    
    [toIter enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx,BOOL *stop){
        
        if ([obj2 isKindOfClass:[HACardView class]]) {
            
            HACardView  *card = (HACardView *)obj2;
            HABaseCard *model = card.modelCard;
            int index2 = model.index-1;
            //Index for comparison calculated based on the direction of scroll
            if (index2 == cardNum) {
                [card manageBackToDeck];
                *stop = YES;
            }
        }
        
    }];
}
#pragma mark -
@end
