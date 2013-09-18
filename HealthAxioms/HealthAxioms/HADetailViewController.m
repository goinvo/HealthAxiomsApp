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

@property (nonatomic, strong)HAModel *axiomsModel;
@property (nonatomic, strong)NSMutableArray *currIndexes;
@property (nonatomic, weak) UIPanGestureRecognizer *panReco;
@property (weak, nonatomic) IBOutlet UICollectionView *miniAxiomPicker;

-(IBAction)actionItemTapped:(id)sender;
@end

@implementation HADetailViewController{

    CGPoint scrollLastOffset;
}

#pragma mark view related methods

-(IBAction)actionItemTapped:(id)sender{

    NSLog(@"I was tapped");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    
    int totalAxiomNum = [self.axiomsModel totalAxioms];
// diving by 2 beacuse trying to keep 5 images
// in memory in total at a time
    
    int indexToStart = _startAxiomIndex - MAX_NUM_PAGES / 2;
    indexToStart = (indexToStart <0)? (totalAxiomNum + indexToStart) :
                                      indexToStart;
    //Adding cards to scroll View
    for (int i=0; i<MAX_NUM_PAGES; i++) {
    
        int indexForModel = ((indexToStart -1) <0) ? totalAxiomNum-1 : indexToStart-1;

        [self addAxiomCardToScrollWithIndex:indexForModel];
        
        indexToStart = ((indexToStart +1) > totalAxiomNum)? 1 :
                                            indexToStart+1;
        
        [self.currIndexes addObject:@(indexForModel)];
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
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        UIPanGestureRecognizer *panReco = (UIPanGestureRecognizer *)gestureRecognizer;
        if ([panReco translationInView:self.frontScroll].x < [panReco translationInView:self.frontScroll].y) {
            toReturn = NO;
            [self.frontScroll resignFirstResponder];
            [panReco setTranslation:CGPointZero inView:self.view];
           // NSLog(@"detected up down pan");
        }
    }
    NSLog(@"returning %d",toReturn);
    return toReturn;
}

-(IBAction)handleTap:(id)sender{
    
    __weak UIView *selfView = self.view;
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.9
          initialSpringVelocity:0.5
                        options: UIViewAnimationOptionAllowAnimatedContent| UIViewAnimationOptionBeginFromCurrentState
                     animations:^(){
                         float shrinkScaleY = self.initRect.size.height/470.0;
                         float shrinkScaleX = self.initRect.size.width/[UIScreen mainScreen].bounds.size.width;
                         [selfView setCenter:CGPointMake(_initRect.origin.x+ _initRect.size.width*0.5,_initRect.origin.y+_initRect.size.height*0.5)];
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

#pragma mark ScrollView Delegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"scroll view %@ did scroll",scrollView );
    BOOL case1 = ([[scrollView class] isSubclassOfClass:[UICollectionView class]])?YES : NO;
    if(!case1){
        
        CGPoint offsetToUse = scrollView.contentOffset;
        //Checking for left right motion of scrollView
        if(!CGPointEqualToPoint(scrollLastOffset, offsetToUse)){
            BOOL isMotionRight = (scrollLastOffset.x < offsetToUse.x) ? YES : NO;
            [self manageViewsWithOffSet:offsetToUse movingRight:isMotionRight];
            scrollLastOffset = offsetToUse;
        }
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{

    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    [scrollView becomeFirstResponder];
    
    //Checking to see if the scrollview belongs to a mini UIcollectionView Picker
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    [scrollView resignFirstResponder];
    NSLog(@"did end decelerating");
}

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
        if (isMovingRight) [self.currIndexes removeObjectAtIndex:0];
        else [self.currIndexes removeLastObject];
        
        if (ObjToRemove) {
            
            [ObjToRemove removeFromSuperview];
            ObjToRemove = nil;
        }
        
        if(isMovingRight){[self.currIndexes addObject:@(indexToCheck)];}
        else{[self.currIndexes insertObject:@(indexToCheck) atIndex:0];}
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
    HABaseCard *card = self.axiomsModel.axiomCardsList[indexPath.row];
    [axiomCell setAxiomCard:card];
    
    return axiomCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"touched item at Index:%d", indexPath.row);
    float newX = indexPath.row * self.frontScroll.frame.size.width;
    float newY = self.frontScroll.frame.origin.y;
    [self.frontScroll scrollRectToVisible:CGRectMake(newX, newY, self.frontScroll.frame.size.width, self.frontScroll.frame.size.height)
                                 animated:YES];
}
@end
