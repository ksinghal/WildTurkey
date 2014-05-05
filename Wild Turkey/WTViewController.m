//
//  WTViewController.m
//  Wild Turkey
//
//  Created by Karan Singhal on 5/4/14.
//  Copyright (c) 2014 Tufts University. All rights reserved.
//

#import "WTViewController.h"
#import "WTMenuScreen.h"

@implementation WTViewController

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    SKView * skView = (SKView *)self.view;
    
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        SKScene * scene = [WTMenuScreen sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        // Present the scene.
        [skView presentScene:scene];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
