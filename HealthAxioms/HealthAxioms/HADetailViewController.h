//
//  HADetailViewController.h
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HADetailViewCtrlDelegate <NSObject>

-(CGRect)handleScrollForAxiomAtIndex:(int)axiomIndex;

@end

@interface HADetailViewController : UIViewController <UIScrollViewDelegate , UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGRect initRect;
@property (nonatomic, weak)IBOutlet UIScrollView *frontScroll;
@property (nonatomic, assign) int startAxiomIndex;
@property (nonatomic, readwrite) BOOL willDealloc;
@property (nonatomic, assign)id <HADetailViewCtrlDelegate>delegate;

-(void)addItemsToScrollView;
-(IBAction)handleTap:(id)sender;
@end
