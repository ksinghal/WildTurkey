//
//  GameOverScene.m
//  Wild Turkey
//
//  Created by Karan Singhal on 5/4/14.
//  Copyright (c) 2014 Tufts University. All rights reserved.
//

#import "WTGameOverScene.h"
#import "WTGameplayScene.h"

@implementation WTGameOverScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [self initalizeBackground];
        
        NSString * message;
        message = @"Game Over";
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2 + 70);
        [self addChild:label];
        
        
        NSString * retrymessage;
        retrymessage = @"Replay Game";
        SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        retryButton.text = retrymessage;
        retryButton.fontColor = [SKColor blackColor];
        retryButton.color = [SKColor blueColor];
        retryButton.position = CGPointMake(self.size.width/2, 50);
        retryButton.name = @"retry";
        [retryButton setScale:.5];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString * highScoreMessage;
        highScoreMessage = [NSString stringWithFormat:@"High Score: %d", [[defaults objectForKey:@"edu.tufts.ksingh03-awong01.wildTurkey.highScore"] intValue]];
        SKLabelNode *highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        highScoreLabel.text = highScoreMessage;
        highScoreLabel.fontSize = 20;
        highScoreLabel.fontColor = [SKColor blackColor];
        highScoreLabel.position = CGPointMake(self.size.width/2 + 170, self.size.height/2 + 130);
        [self addChild:highScoreLabel];
        
        NSString * scoreMessage;
        scoreMessage = [NSString stringWithFormat:@"Your Score: %d", [[defaults objectForKey:@"edu.tufts.ksingh03-awong01.wildTurkey.score"] intValue]];
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        scoreLabel.text = scoreMessage;
        scoreLabel.fontSize = 20;
        scoreLabel.fontColor = [SKColor blackColor];
        scoreLabel.position = CGPointMake(self.size.width/2 - 170, self.size.height/2 + 130);
        [self addChild:scoreLabel];
        
        [self addChild:retryButton];
        
        SKAction *musicAction = [SKAction playSoundFileNamed:@"Game OVer.mp3" waitForCompletion:YES];
        [self runAction:musicAction];
    }
    return self;
}

-(void)initalizeBackground
{
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"gameover"];
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
    
    if ([node.name isEqualToString:@"retry"]) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        
        WTGameplayScene * scene = [WTGameplayScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition: reveal];
        
    }
}

@end