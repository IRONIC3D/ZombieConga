//
//  GameScene.m
//  Zombie Conga
//
//  Created by Iyad Horani on 2/05/2015.
//  Copyright (c) 2015 IRONIC3D. All rights reserved.
//

#import "GameScene.h"

static const float ZOMBIE_MOVE_POINTS_PER_SEC = 120.0;

@implementation GameScene {
    SKSpriteNode *_zombie;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    CGPoint _velocity;
}

-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:bg];
        
        _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
        _zombie.position = CGPointMake(100, 100);
        [self addChild:_zombie];
    }
    return self;
}

-(void)update:(NSTimeInterval)currentTime {
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    _lastUpdateTime = currentTime;
    [self moveSprite:_zombie velocity:_velocity];
    [self rotateSprite:_zombie toFace:_velocity];
    [self boundsCheckPlayer];
}

#pragma mark USER METHODS
#pragma mark ----------------------------

-(void)moveSprite:(SKSpriteNode *)sprite
         velocity:(CGPoint)velocity {
    
    CGPoint amountToMove = CGPointMake(velocity.x * _dt,
                                       velocity.y * _dt);
    
    sprite.position = CGPointMake(sprite.position.x + amountToMove.x,
                                  sprite.position.y + amountToMove.y);
}

-(void)moveZombieToward:(CGPoint)location {
    CGPoint offset = CGPointMake(location.x - _zombie.position.x,
                                 location.y - _zombie.position.y);
    
    CGFloat length = sqrtf(offset.x * offset.x + offset.y * offset.y);
    
    CGPoint direction = CGPointMake(offset.x / length,
                                    offset.y / length);
    
    _velocity = CGPointMake(direction.x * ZOMBIE_MOVE_POINTS_PER_SEC,
                            direction.y * ZOMBIE_MOVE_POINTS_PER_SEC);
}

-(void)rotateSprite:(SKSpriteNode *)sprite
             toFace:(CGPoint)direction {
    sprite.zRotation = atan2f(direction.y, direction.x);
}

-(void)boundsCheckPlayer {
    CGPoint newPosition = _zombie.position;
    CGPoint newVelocity = _velocity;
    
    CGPoint bottomLeft = CGPointZero;
    CGPoint topRight = CGPointMake(self.size.width, self.size.height);
    
    if (newPosition.x <= bottomLeft.x) {
        newPosition.x = bottomLeft.x;
        newVelocity.x = -newVelocity.x;
    }
    if (newPosition.x >= topRight.x) {
        newPosition.x = topRight.x;
        newVelocity.x = -newVelocity.x;
    }
    if (newPosition.y <= bottomLeft.y) {
        newPosition.y = bottomLeft.y;
        newVelocity.y = -newVelocity.y;
    }
    if (newPosition.y >= topRight.y) {
        newPosition.y = topRight.y;
        newVelocity.y = -newVelocity.y;
    }
    
    _zombie.position = newPosition;
    _velocity = newVelocity;
}

#pragma mark TOUCH CONTROLS
#pragma mark ----------------------------

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    [self moveZombieToward:touchLocation];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    [self moveZombieToward:touchLocation];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    [self moveZombieToward:touchLocation];
}


@end
