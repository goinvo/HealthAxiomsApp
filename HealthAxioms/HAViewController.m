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

//Getting the card from Model
    HABaseCard *card = axiomsModel.axiomCardsList[indexPath.row];
    
    CGSize frameSize = cellSizeToUse;
    NSString *imgName = [card.frontImage copy];
    NSString *keyName = nil;
    if (imgName && [imgName length]>1) {
        
        NSString *name =[imgName stringByAppendingString:[NSString stringWithFormat:@"%f",frameSize.height]] ;
        keyName = [[name dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        
        //checking if the key exists or not
        if([[NSUserDefaults standardUserDefaults] objectForKey:keyName]){
            @autoreleasepool {

                UIImage *imge = nil;
                NSData *imageData = [[NSUserDefaults standardUserDefaults] dataForKey:keyName];
                imge = [NSKeyedUnarchiver unarchiveObjectWithData: imageData];
                [self setImage:imge forCellAtIndex:[indexPath copy]];
            }
        }
        else{
            dispatch_queue_t myQue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(myQue, ^(){
                //Fetching the stored small image from userDefaults
                UIImage *imge = nil;
                __weak NSIndexPath *indexPathCopy = indexPath;
                
                //Drawing the smaller image
                imge = [UIImage imageNamed:imgName];
                CGSize imageSize = cellSizeToUse;
                float xSize = imageSize.height * (imge.size.width/imge.size.height);
                UIGraphicsBeginImageContextWithOptions(imageSize,YES,0);
                [imge drawInRect:CGRectMake((imageSize.width-xSize)*0.5, 0, xSize, imageSize.height)];
                imge = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                //Storing small image to userDefaults
                NSData *imageDta = [NSKeyedArchiver archivedDataWithRootObject:imge];
                [[NSUserDefaults standardUserDefaults] setObject:imageDta forKey:keyName];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [self setImage:imge forCellAtIndex:indexPathCopy];
            });
        }
    }

    return axiomCell;
}

-(void)setImage:(UIImage *)axiomImage forCellAtIndex:(NSIndexPath *)axiomIndexPath{

    dispatch_async(dispatch_get_main_queue(), ^(){
//Updating the cell
        HAAxiomCell *axiomCellToUpdate = (HAAxiomCell *)[self.axiomsCollectionView cellForItemAtIndexPath:axiomIndexPath];
        if(axiomCellToUpdate){
            axiomCellToUpdate.imgView.image = nil;
            [axiomCellToUpdate.imgView setImage:axiomImage];
            [axiomCellToUpdate setNeedsDisplay];
        }
    });
    
}

#pragma mark -


#pragma mark Collection View Delegate Methods

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{

    HAAxiomCell *axiomCell = (HAAxiomCell *)cell;
    if (axiomCell) {
        axiomCell.imgView.image = nil;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    HAAxiomCell *cell = (HAAxiomCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    NSLog(@"item details are \n frontImage:%@ \n backImage:%@", cell.axiomCard.frontImage, cell.axiomCard.backImage);
    float yOffset = cell.frame.origin.y - collectionView.contentOffset.y;
    CGRect newFrame = CGRectMake(cell.frame.origin.x, yOffset, cell.frame.size.width, cell.frame.size.height);
    
    @autoreleasepool {

        HADetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
        detailVC.startAxiomIndex = indexPath.row +1;
        [detailVC setStartRect:newFrame];
        
        //detailVC.initRect = newFrame;
        CGPoint newCenter = CGPointMake(cell.center.x, cell.center.y - collectionView.contentOffset.y);
        [self.view addSubview:detailVC.view];
        [detailVC.view setCenter:newCenter];
        
        float win_Width =[UIScreen mainScreen].bounds.size.width;
        float win_Height =[UIScreen mainScreen].applicationFrame.size.height;
        
        float xScale = win_Width / cell.frame.size.width;
        float yScale = win_Height / cell.frame.size.height;
        [detailVC.view setTransform:CGAffineTransformMakeScale(1/xScale, 1/yScale) ];
        
        __weak UIView *detailVCView = detailVC.view;
        
        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.2
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^(){
                             [detailVCView setCenter:CGPointMake(win_Width*0.5, win_Height*0.5)];
                             [detailVC.view setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                         }
                         completion:^(BOOL finished){
                             
                             if (finished) {
                                 [self addChildViewController:detailVC];
                                 
                                 detailVC.delegate = self;
                                 [detailVC didMoveToParentViewController:self];
                                 [detailVC setStartRect:newFrame];
                                 [cell setHidden:YES];
                                 self.hiddenCellIndex = [indexPath indexAtPosition:1];
                                 NSLog(@"selected index :%d",self.hiddenCellIndex);
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
    [self.axiomsCollectionView reloadItemsAtIndexPaths:@[[indexPathToUse copy]]];
    
//Removing child controllers
    NSArray *childCtrl = [self childViewControllers];

    if (childCtrl) {
        [[self.childViewControllers lastObject] willMoveToParentViewController:nil];
        [[[self.childViewControllers lastObject] view] removeFromSuperview];
        [[self.childViewControllers lastObject] removeFromParentViewController];
        
    }
}

-(CGRect)manageVisibilityForCellAtIndex:(int)index isVisible:(BOOL)visible{
    
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
    [cell setHidden:visible];
    [cell setNeedsDisplay];
//    NSLog(@"returning frame %@", NSStringFromCGRect(cell.frame));
    
    return cell.frame;
}

-(CGRect)handleScrollForAxiomAtIndex:(int)axiomIndex{
 
//    NSLog(@"Need to manage scroll for index :%d",axiomIndex);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.hiddenCellIndex
                                                 inSection:0];
    HAAxiomCell *cell = (HAAxiomCell *)[self.axiomsCollectionView cellForItemAtIndexPath:indexPath];
    CGRect toReturn = cell.frame;
    
    int indexToCompare = 0;
   indexToCompare = [indexPath indexAtPosition:1];
    if (indexToCompare != (axiomIndex-1)) {
//Unhide current invisible cell
        [self manageVisibilityForCellAtIndex:self.hiddenCellIndex
                                   isVisible:NO];
//Hide the new cell

        self.hiddenCellIndex = MAX(0, (axiomIndex-1));
       toReturn =  [self manageVisibilityForCellAtIndex:self.hiddenCellIndex
                                              isVisible:YES];
        [cell setNeedsDisplay];
        toReturn.origin.y = toReturn.origin.y - self.axiomsCollectionView.contentOffset.y;
        NSLog(@"returning rect %@", NSStringFromCGRect(toReturn));
    }
    return toReturn;
}

#pragma mark -

@end
