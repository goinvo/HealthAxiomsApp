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

NSString *const FRONT_KEY = @"front_image";
NSString *const CELL_IDENTIFIER = @"AxiomCard";

#define WINDOW_WIDTH ([[UIScreen mainScreen] applicationFrame].size.width)
#define WINDOW_HEIGHT ([[UIScreen mainScreen] applicationFrame].size.height)

#define PADDING 10.0f

#define ITEM_WIDTH ((WINDOW_WIDTH -PADDING*4)/3)

@interface HAViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *axiomsCollectionView;
@end

@implementation HAViewController{

    HAModel *axiomsModel;
    CGSize cellSizeToUse;
}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    axiomsModel = [HAModel sharedModel];
    
    _axiomsCollectionView.delegate = self;
    _axiomsCollectionView.dataSource = self;
    
    HABaseCard *card = (HABaseCard *)axiomsModel.axiomCardsList[0];
    NSString *itemName = [card.frontImage copy];
    UIImage *img = [UIImage imageNamed:itemName];
    
    float ratio = img.size.width/img.size.height ;
    float height = ITEM_WIDTH/ratio;
    
    cellSizeToUse = CGSizeMake(ITEM_WIDTH, height);
 //   self.modalPresentationStyle = UIModalPresentationCurrentContext;

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
    
    HAAxiomCell *axiomCell = (HAAxiomCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                       forIndexPath:indexPath];
    HABaseCard *card = axiomsModel.axiomCardsList[indexPath.row];
    [axiomCell setAxiomCard:card];
    NSString *imgName = [card.frontImage copy];
    
    if (imgName && [imgName length]>1) {
        axiomCell.imgView.image = [UIImage imageNamed:imgName];
    }
    
    return axiomCell;
}
#pragma mark -


#pragma mark Collection View Delegate Methods

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{


    HAAxiomCell *cell = (HAAxiomCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    NSLog(@"item details are \n frontImage:%@ \n backImage:%@", cell.axiomCard.frontImage, cell.axiomCard.backImage);

    HADetailViewController *viewCtrl = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"DetailViewController"];
    
    float yOffset = cell.frame.origin.y - collectionView.contentOffset.y;

//    NSLog(@"yOffset is %f", yOffset);
    CGRect newFrame = CGRectMake(cell.frame.origin.x, yOffset, cell.frame.size.width, cell.frame.size.height);
    
    [viewCtrl.view setFrame:newFrame];
    viewCtrl.initRect = newFrame;
    [viewCtrl.imgView setImage:[UIImage imageNamed:cell.axiomCard.frontImage]];

    [self.view addSubview:viewCtrl.view];

    float win_Width =[UIScreen mainScreen].bounds.size.width;
    float win_Height =[UIScreen mainScreen].bounds.size.height;
    
    float xScale = win_Width / cell.frame.size.width;
    float yScale = win_Height / cell.frame.size.height;
    
    
    __weak UIView *selfView = viewCtrl.view;
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.9
          initialSpringVelocity:0.5
                        options: UIViewAnimationOptionAllowAnimatedContent| UIViewAnimationOptionBeginFromCurrentState
                     animations:^(){
                         [selfView setCenter:CGPointMake(win_Width*0.5, win_Height*0.5)];
                         [selfView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, xScale, yScale)];
                     }
                     completion:^(BOOL finished){
                     
                         if (finished) {
                             [self addChildViewController:viewCtrl];
                             [viewCtrl didMoveToParentViewController:self];
                         }
                     }
     ];
}

#pragma mark -

#pragma mark CollectionView FlowLayout Delegate methods

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return cellSizeToUse;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{

    if (section <3) {
        return UIEdgeInsetsMake(PADDING*3, PADDING, PADDING, PADDING);
    }
    return UIEdgeInsetsMake(PADDING, PADDING, PADDING, PADDING);
}

#pragma mark -

@end
