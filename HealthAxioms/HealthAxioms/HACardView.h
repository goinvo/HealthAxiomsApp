//
//  HACardView.h
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/22/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HABaseCard;

@interface HACardView : UIView <UIGestureRecognizerDelegate, UITextViewDelegate>

@property (nonatomic, strong)HABaseCard *modelCard;

- (id)initWithFrame:(CGRect)frame model:(HABaseCard *)card;
-(void)manageBackToDeck;
//-(void)addBackView;
//-(void)removeBackView;
@end
