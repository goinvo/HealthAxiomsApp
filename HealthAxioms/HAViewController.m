//
//  HAViewController.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/15/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import "HAViewController.h"
#import "HAModel.h"
#import "HABaseCard.h"
#import "HAAxiomCell.h"
#import "HADetailViewController.h"


#define WINDOW_WIDTH ([[UIScreen mainScreen] applicationFrame].size.width)
#define WINDOW_HEIGHT ([[UIScreen mainScreen] applicationFrame].size.height)

#define PADDING 10.0f

#define ITEM_WIDTH ((WINDOW_WIDTH -PADDING*4)/3)

@interface HAViewController () <HADetailViewCtrlDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *axiomsCollectionView;
@property (nonatomic, assign) int hiddenCellIndex;
@end

@implementation HAViewController{

    HAModel *axiomsModel;
    CGSize cellSizeToUse;
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}
-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
}

-(void)awakeFromNib{

    [super awakeFromNib];
    axiomsModel = [HAModel sharedModel];
    
    HABaseCard *card = (HABaseCard *)axiomsModel.axiomCardsList[0];
    NSString *itemName = [card.frontImage copy];
    UIImage *img = [UIImage imageNamed:itemName];
    float ratio = img.size.width/img.size.height ;
    float height = ITEM_WIDTH/ratio;

    cellSizeToUse = CGSizeMake(ITEM_WIDTH, height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Memory warning");
}

#pragma mark Collection View DataSource Delegate Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return [axiomsModel.axiomCardsList count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *const CELL_IDENTIFIER = @"AxiomCard";
    
    HAAxiomCell *axiomCell = (HAAxiomCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                       forIndexPath:indexPath];
    axiomCell.imgView.image = nil;
    [axiomCell.imgView.layer setCornerRadius:6.0f];
    
     @autoreleasepool {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
             
             [self loadCellImageForIndexPath:indexPath];
         });
     }
    return axiomCell;
}

-(void)loadCellImageForIndexPath:(NSIndexPath *)cellIndexPath{

    __weak HABaseCard *card = axiomsModel.axiomCardsList[cellIndexPath.item];
    
    CGSize frameSize = cellSizeToUse;
    NSString *imgName = [card.frontImage copy];
    NSString *keyName = nil;
    UIImage *imge = nil;
    if (imgName && [imgName length]>1) {
        
        NSString *name =[imgName stringByAppendingString:[NSString stringWithFormat:@"%f",frameSize.height]] ;
        keyName = [[name dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        
        @synchronized(keyName){
        
            //checking if the key exists or not
            if([[NSUserDefaults standardUserDefaults] objectForKey:keyName]){
                
                NSData *imageData = [[NSUserDefaults standardUserDefaults] dataForKey:keyName];
                imge = [NSKeyedUnarchiver unarchiveObjectWithData: [imageData copy]];
                //[self setImage:imge forCellAtIndex:[cellIndexPath copy]];
            }
            else{
                
                //Drawing the smaller image
                imge = [UIImage imageNamed:[imgName copy]];
                //CGSize imageSize = cellSizeToUse;
                float xSize = cellSizeToUse.height * (imge.size.width/imge.size.height);
                UIGraphicsBeginImageContextWithOptions(cellSizeToUse,YES,0);
                [imge drawInRect:CGRectMake((cellSizeToUse.width-xSize)*0.5, 0, xSize, cellSizeToUse.height)];
                imge = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                //Storing small image to userDefaults
                NSData *imageDta = [NSKeyedArchiver archivedDataWithRootObject:imge];
                [[NSUserDefaults standardUserDefaults] setObject:[imageDta copy] forKey:[keyName copy]];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setImage:imge forCellAtIndex:[cellIndexPath copy]];
            });
        }
    }
}

-(void)setImage:(UIImage *)axiomImage forCellAtIndex:(NSIndexPath *)axiomIndexPath{

//Updating the cell
        HAAxiomCell *axiomCellToUpdate = (HAAxiomCell *)[self.axiomsCollectionView cellForItemAtIndexPath:axiomIndexPath];
        if(axiomCellToUpdate){
            axiomCellToUpdate.imgView.image = nil;
            [axiomCellToUpdate.imgView setImage:axiomImage];
         //   [axiomCellToUpdate setNeedsDisplay];
        }
    
}

#pragma mark -


#pragma mark Collection View Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{

    HAAxiomCell *axiomCell = (HAAxiomCell *)cell;
    axiomCell.imgView.image = nil;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    @autoreleasepool {
        HAAxiomCell *cell = (HAAxiomCell *)[collectionView cellForItemAtIndexPath:indexPath];
        //    NSLog(@"item details are \n frontImage:%@ \n backImage:%@", cell.axiomCard.frontImage, cell.axiomCard.backImage);
        float yOffset = cell.frame.origin.y - collectionView.contentOffset.y;
        CGRect newFrame = CGRectMake(cell.frame.origin.x, yOffset, cell.frame.size.width, cell.frame.size.height);
        
        
        HADetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
        detailVC.startAxiomIndex = indexPath.row +1;
        detailVC.providesPresentationContextTransitionStyle = YES;
        
        [self.view addSubview:detailVC.view];
        
        CGPoint newCenter = CGPointMake(cell.center.x, cell.center.y - collectionView.contentOffset.y);
        [detailVC.view setCenter:newCenter];
        
        float win_Width =[UIScreen mainScreen].bounds.size.width;
        float win_Height =[UIScreen mainScreen].applicationFrame.size.height;
        
        float xScale = win_Width / cell.frame.size.width;
        float yScale = win_Height / cell.frame.size.height;
        [detailVC.view setTransform:CGAffineTransformMakeScale(1/xScale, 1/yScale) ];
        
        [UIView animateWithDuration:0.5
                              delay:0.1
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.2
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             [detailVC.view setCenter:CGPointMake(win_Width*0.5, win_Height*0.5)];
                             [detailVC.view setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                             
                             //  NSLog(@"animating ......");
                         }
                         completion:^(BOOL finished){
                             
                             if (finished) {
                                 [detailVC willMoveToParentViewController:self];
                                 [self addChildViewController:detailVC];
                                 [detailVC didMoveToParentViewController:self];
                                 detailVC.delegate = self;
                                 
                                 [detailVC setStartRect:newFrame];
                                 [detailVC.view setTransform:CGAffineTransformIdentity];
                                 [cell setHidden:YES];
                                 self.hiddenCellIndex = [indexPath indexAtPosition:1];
                                 // NSLog(@"selected index :%d",self.hiddenCellIndex);
                             }
                         }
         ];

    }
}

#pragma mark -

#pragma mark CollectionView FlowLayout Delegate methods

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{

    return PADDING;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{

    return 5.0f;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return cellSizeToUse;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{

    UIEdgeInsets insetToReturn = UIEdgeInsetsMake(PADDING, PADDING, PADDING, PADDING);
    
    if (section <=2) {
        insetToReturn = UIEdgeInsetsMake(PADDING*3, PADDING, PADDING, PADDING);
    }
//    NSLog(@"inset To Return is %@", NSStringFromUIEdgeInsets(insetToReturn));
    return insetToReturn;
}

#pragma mark -

#pragma mark Handle Detailed Axioms Scroll Delegate methods

-(void)handleRemoval{

    NSIndexPath *indexPathToUse = [NSIndexPath indexPathForItem:self.hiddenCellIndex
                                                      inSection:0];
    HAAxiomCell *cellToUnhide = (HAAxiomCell *)[self.axiomsCollectionView cellForItemAtIndexPath:indexPathToUse];
    [cellToUnhide setHidden:NO];
}

-(CGRect)manageVisibilityForCellAtIndex:(int)index isHidden:(BOOL)hidden{
    
    NSIndexPath *indexPathToUse = [NSIndexPath indexPathForItem:index
                                                 inSection:0];
    
    NSArray *visibleIndexes = [self.axiomsCollectionView indexPathsForVisibleItems];
    
    if (![visibleIndexes containsObject:indexPathToUse]) {
        //means the item is not visible right now
        [self.axiomsCollectionView scrollToItemAtIndexPath:indexPathToUse
                                          atScrollPosition:UICollectionViewScrollPositionBottom
                                                  animated:NO];
        [self.axiomsCollectionView reloadItemsAtIndexPaths:@[indexPathToUse]];
    }
    
     HAAxiomCell *cell = (HAAxiomCell *)[self.axiomsCollectionView cellForItemAtIndexPath:indexPathToUse];
    [cell setHidden:hidden];
    [cell setNeedsDisplay];
//    NSLog(@"returning frame %@", NSStringFromCGRect(cell.frame));
    
    return cell.frame;
}

-(void)handleScrollForAxiomAtIndex:(int)axiomIndex{
 
//    NSLog(@"Need to manage scroll for index :%d",axiomIndex);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.hiddenCellIndex
                                                 inSection:0];
    
    int indexToCompare = 0;
   indexToCompare = [indexPath indexAtPosition:1];
    if ((indexToCompare-1) != axiomIndex) {
//Unhide current invisible cell
        [self manageVisibilityForCellAtIndex:self.hiddenCellIndex
                                   isHidden:NO];
//Hide the new cell

        self.hiddenCellIndex = MAX(0, (axiomIndex-1));
        [self manageVisibilityForCellAtIndex:self.hiddenCellIndex
                                    isHidden:YES];
    }
}

-(CGRect)rectForDismissAnimation{
//    NSLog(@"dismissing with item %d",self.hiddenCellIndex);
    HAAxiomCell *cell = (HAAxiomCell *)[self.axiomsCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.hiddenCellIndex inSection:0]];
    CGRect cellRect = cell.frame;
    cellRect.origin.y = cellRect.origin.y - [self.axiomsCollectionView contentOffset].y ;
    return cellRect;
}
#pragma mark -

@end
