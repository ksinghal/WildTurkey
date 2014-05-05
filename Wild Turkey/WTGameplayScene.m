//
//  WTMyScene.m
//  Wild Turkey
//
//  Created by Karan Singhal on 5/4/14.
//  Copyright (c) 2014 Tufts University. All rights reserved.
//

#import "WTGameplayScene.h"
#import "WTGameOverScene.h"

static const uint32_t turkeyCategory =  0x1 << 0;
static const uint32_t obstacleCategory =  0x1 << 1;
static const uint32_t floorCategory =  0x1 << 2;
static const uint32_t waterBottleCategory =  0x1 << 3;

static const float BG_VELOCITY = 100.0;
static const float OBJECT_VELOCITY = 160.0;

static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

int water_life = 100;
int score = 0;
float velocity_multiplier = 1.0;

SKLabelNode *scoreLabel = nil;
SKLabelNode *hydrationLabel = nil;

@implementation WTGameplayScene{
    
    SKSpriteNode *turkey;
    SKAction *actionMoveUp;
    SKAction *actionMoveDown;
    
    SKSpriteNode *bg1;
    SKSpriteNode *bg2;
    
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    NSTimeInterval _lastBulletAdded;
    NSTimeInterval _lastArrowAdded;
    NSTimeInterval _lastWaterBottleAdded;
    
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        [self initalizingScrollingBackground];
        [self addTurkey];
        [self addFloor];
        
        //Making self delegate of physics World
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        water_life = 100;
        score = 0;
    }
    
    return self;
}

-(void)addTurkey
{
    //initalizing spaceship node
    turkey = [SKSpriteNode spriteNodeWithImageNamed:@"Turkey"];
    [turkey setScale:0.2];
    turkey.zRotation = 0;
    
    //Adding SpriteKit physicsBody for collision detection
    turkey.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:turkey.size];
    turkey.physicsBody.categoryBitMask = turkeyCategory;
    turkey.physicsBody.dynamic = YES;
    turkey.physicsBody.contactTestBitMask = obstacleCategory;
    turkey.physicsBody.collisionBitMask = 0;
    turkey.physicsBody.usesPreciseCollisionDetection = YES;
    turkey.physicsBody.affectedByGravity = NO;
    turkey.name = @"turkey";
    turkey.position = CGPointMake(120,160);
    actionMoveUp = [SKAction moveByX:0 y:30 duration:.2];
    actionMoveDown = [SKAction moveByX:0 y:-30 duration:.2];
    
    [self addChild:turkey];
}

-(void)addBullet
{
    //initalizing spaceship node
    SKSpriteNode *missile;
    missile = [SKSpriteNode spriteNodeWithImageNamed:@"bullet"];
    [missile setScale:0.7];
    
    //Adding SpriteKit physicsBody for collision detection
    missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.size];
    missile.physicsBody.categoryBitMask = obstacleCategory;
    missile.physicsBody.dynamic = YES;
    missile.physicsBody.contactTestBitMask = turkeyCategory;
    missile.physicsBody.collisionBitMask = 0;
    missile.physicsBody.usesPreciseCollisionDetection = YES;
    missile.name = @"bullet";
    
    //selecting random y position for missile
    int r = arc4random() % 300;
    missile.position = CGPointMake(self.frame.size.width + 20,r);
    
    [self addChild:missile];
}

-(void)addArrow
{
    //initalizing spaceship node
    SKSpriteNode *missile;
    missile = [SKSpriteNode spriteNodeWithImageNamed:@"arrow"];
    [missile setScale:0.7];
    
    //Adding SpriteKit physicsBody for collision detection
    missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.size];
    missile.physicsBody.categoryBitMask = obstacleCategory;
    missile.physicsBody.dynamic = YES;
    missile.physicsBody.contactTestBitMask = turkeyCategory;
    missile.physicsBody.collisionBitMask = 0;
    missile.physicsBody.usesPreciseCollisionDetection = YES;
    missile.name = @"arrow";
    
    //selecting random y position for missile
    int r = arc4random() % 230;
    missile.position = CGPointMake(self.frame.size.width + 20,r+70);
    
    [self addChild:missile];
}

-(void)addWaterBottle
{
    //initalizing spaceship node
    SKSpriteNode *missile;
    missile = [SKSpriteNode spriteNodeWithImageNamed:@"waterbottle"];
    [missile setScale:0.7];
    
    //Adding SpriteKit physicsBody for collision detection
    missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.size];
    missile.physicsBody.categoryBitMask = waterBottleCategory;
    missile.physicsBody.dynamic = YES;
    missile.physicsBody.contactTestBitMask = turkeyCategory;
    missile.physicsBody.collisionBitMask = 0;
    missile.physicsBody.usesPreciseCollisionDetection = YES;
    missile.name = @"waterbottle";
    
    //selecting random y position for missile
    int r = arc4random() % 230;
    missile.position = CGPointMake(self.frame.size.width + 20,r+70);
    
    velocity_multiplier = 1;
    
    [self addChild:missile];
}

-(void)addFloor
{
    //initalizing spaceship node
    SKSpriteNode *floor;
    floor = [SKSpriteNode spriteNodeWithImageNamed:@"grass"];
    
    //Adding SpriteKit physicsBody for collision detection
    floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:floor.size];
    floor.physicsBody.categoryBitMask = floorCategory;
    floor.physicsBody.affectedByGravity = NO;
    floor.physicsBody.dynamic = NO;
    floor.physicsBody.contactTestBitMask = turkeyCategory;
    floor.physicsBody.collisionBitMask = 0;
    floor.physicsBody.usesPreciseCollisionDetection = YES;
    floor.name = @"floor";
    
    //selecting random y position for missile
    floor.position = CGPointMake(floor.size.width/2,20);
    
    [self addChild:floor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    if(touchLocation.y >turkey.position.y){
        if(turkey.position.y < 270){
            [turkey runAction:actionMoveUp];
        }
    }else{
        if(turkey.position.y > 75){
            [turkey runAction:actionMoveDown];
        }
    }
}

-(void)initalizingScrollingBackground
{
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        [self addChild:bg];
    }
}

- (void)moveBg
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY*velocity_multiplier, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
     }];
}

- (void)moveObstacle
{
    NSArray *nodes = self.children;
    
    for(SKNode * node in nodes){
        if ([node.name  isEqual: @"bullet"]) {
            SKSpriteNode *ob = (SKSpriteNode *) node;
            CGPoint obVelocity = CGPointMake(-OBJECT_VELOCITY*velocity_multiplier, 0);
            CGPoint amtToMove = CGPointMultiplyScalar(obVelocity,_dt);
            
            ob.position = CGPointAdd(ob.position, amtToMove);
            if(ob.position.x < -100)
            {
                score++;
                [ob removeFromParent];
            }
        } else if ([node.name  isEqual: @"waterbottle"]) {
            SKSpriteNode *ob = (SKSpriteNode *) node;
            CGPoint obVelocity = CGPointMake(-OBJECT_VELOCITY*velocity_multiplier, 10);
            CGPoint amtToMove = CGPointMultiplyScalar(obVelocity,_dt);
            
            ob.position = CGPointAdd(ob.position, amtToMove);
            if(ob.position.x < -100)
            {
                [ob removeFromParent];
            }
        }else if ([node.name isEqual: @"arrow"]) {
            SKSpriteNode *ob = (SKSpriteNode *) node;
            CGPoint obVelocity = CGPointMake(-OBJECT_VELOCITY*velocity_multiplier, -10);
            CGPoint amtToMove = CGPointMultiplyScalar(obVelocity,_dt);
            
            ob.position = CGPointAdd(ob.position, amtToMove);
            if(ob.position.x < -100)
            {
                score++;
                [ob removeFromParent];
            }
        } else if ([node.name isEqual: @"floor"]) {
            SKSpriteNode *ob = (SKSpriteNode *)node;
            [ob removeFromParent];
            [self addFloor];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    
    if (_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    
    if( currentTime - _lastBulletAdded > 1)
    {
        _lastBulletAdded = currentTime + 1;
        [self addBullet];
        velocity_multiplier += 0.05;
        
        water_life -= 4;
        if (water_life <= 0) {
            [self gameOver];
        }
    }
    
    if (currentTime - _lastArrowAdded > 0.8) {
        _lastArrowAdded = currentTime + 0.8;
        [self addArrow];
    }
    
    if (currentTime - _lastWaterBottleAdded > 2.3) {
        _lastWaterBottleAdded = currentTime + 2.3;
        [self addWaterBottle];
    }
    
    if (turkey.position.y <= 75) {
        turkey.position = CGPointMake(120, 80);
    }
    
    [self moveBg];
    [self moveObstacle];
    [self updateScore];
    [self updateWaterLife];
}

-(void)updateScore {
    NSString * message;
    message = [NSString stringWithFormat:@"Score: %d", score];
    [scoreLabel removeFromParent];
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    scoreLabel.text = message;
    scoreLabel.fontSize = 24;
    scoreLabel.fontColor = [SKColor blackColor];
    scoreLabel.position = CGPointMake(500, 290);
    [self addChild:scoreLabel];
}

-(void)updateWaterLife {
    NSString * message;
    message = [NSString stringWithFormat:@"Hydration: %d", water_life];
    [hydrationLabel removeFromParent];
    hydrationLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
    hydrationLabel.text = message;
    hydrationLabel.fontSize = 24;
    hydrationLabel.fontColor = [SKColor blackColor];
    hydrationLabel.position = CGPointMake(470, 260);
    [self addChild:hydrationLabel];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & turkeyCategory) != 0 &&
        (secondBody.categoryBitMask & floorCategory) != 0) {
    } else if ((firstBody.categoryBitMask & turkeyCategory) != 0 &&
               (secondBody.categoryBitMask & waterBottleCategory) != 0) {
        water_life += 10;
        if (water_life > 100) {
            water_life = 100;
        }
        [secondBody.node removeFromParent];
    } else if ((firstBody.categoryBitMask & turkeyCategory) != 0 &&
        (secondBody.categoryBitMask & obstacleCategory) != 0)
    {
        [turkey removeFromParent];
        [self gameOver];
    }
}

-(void)setHighScore {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"edu.tufts.ksingh03-awong01.wildTurkey.highScore"] intValue] < score) {
        [defaults setObject:[NSNumber numberWithInt:score] forKey:@"edu.tufts.ksingh03-awong01.wildTurkey.highScore"];
    }
    [defaults setObject:[NSNumber numberWithInt:score] forKey:@"edu.tufts.ksingh03-awong01.wildTurkey.score"];
    [defaults synchronize];
}

-(void)gameOver {
    [self setHighScore];
    
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    SKScene * gameOverScene = [[WTGameOverScene alloc] initWithSize:self.size];
    [self.view presentScene:gameOverScene transition: reveal];
}

@end
