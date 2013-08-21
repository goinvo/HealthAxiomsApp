//
//  HADetailViewController.m
//  HealthAxioms
//
//  Created by Dhaval Karwa on 8/19/13.
//  Copyright (c) 2013 Dhaval Karwa. All rights reserved.
//

#import "HADetailViewController.h"

#define PAGE_WIDTH   ([[UIScreen mainScreen] bounds].size.width)
#define PAGE_HEIGHT  ([[UIScreen mainScreen] bounds].size.height)

@interface HADetailViewController ()

//@property (nonatomic, weak) UIScrollView *frontScroll;

@end

@implementation HADetailViewController


-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self.imgView setFrame:self.view.frame];
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


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    __weak UIView *selfView = self.view;
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.9
          initialSpringVelocity:0.5
                        options: UIViewAnimationOptionAllowAnimatedContent| UIViewAnimationOptionBeginFromCurrentState
                     animations:^(){
                         [selfView setCenter:CGPointMake(_initRect.origin.x+ _initRect.size.width*0.5,_initRect.origin.y+_initRect.size.height*0.5)];
                         [selfView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)];
                     }
                     completion:^(BOOL finished){
                         
                         if (finished) {
                             
                             [self.view removeFromSuperview];
                             [self didMoveToParentViewController:nil];
                             [self removeFromParentViewController];
                             
                         }
                     }
     ];

}


-(void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{

    NSLog(@"called");
}


@end
