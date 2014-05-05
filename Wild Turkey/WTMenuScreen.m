//
//  WTMenuScreen.m
//  Wild Turkey
//
//  Created by Karan Singhal on 5/4/14.
//  Copyright (c) 2014 Tufts University. All rights reserved.
//

#import "WTMenuScreen.h"
#import "WTGameplayScene.h"

@implementation WTMenuScreen

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        [self initalizeBackground];
        
        NSString * message;
        message = @"Wild Turkey";
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2 + 80);
        [self addChild:label];
        
        
        NSString * retrymessage;
        retrymessage = @"Play!";
        SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        retryButton.text = retrymessage;
        retryButton.fontColor = [SKColor blackColor];
        retryButton.position = CGPointMake(self.size.width/2, 50);
        retryButton.name = @"play";
        [retryButton setScale:.5];
        
        SKAction *music = [SKAction playSoundFileNamed:@"timber-8-bit.mp3" waitForCompletion:YES];
        [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[music, [SKAction waitForDuration:0], ]]] withKey:@"MUSIC_PLAYING"];
        
        [self addChild:retryButton];
        
    }
    return self;
}

-(void)initalizeBackground
{
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"wildturkey"];
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        [self addChild:bg];
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"play"]) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        
        WTGameplayScene * scene = [WTGameplayScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition: reveal];
        
    }
}

@end