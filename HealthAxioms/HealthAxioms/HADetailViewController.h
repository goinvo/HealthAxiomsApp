//
//  HADetailViewController.h
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@protocol HADetailViewCtrlDelegate <NSObject>

-(void)handleScrollForAxiomAtIndex:(int)axiomIndex;
-(void)handleRemoval;
-(CGRect)rectForDismissAnimation;
@end

@interface HADetailViewController : UIViewController <UIScrollViewDelegate , UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, weak)IBOutlet UIScrollView *frontScroll;
@property (nonatomic, assign) int startAxiomIndex;
@property (nonatomic, readwrite) BOOL willDealloc;
@property (nonatomic, weak)id <HADetailViewCtrlDelegate>delegate;

-(void)addItemsToScrollView;
-(IBAction)handleTap:(id)sender;
-(void)setStartRect:(CGRect)rect;
@end
