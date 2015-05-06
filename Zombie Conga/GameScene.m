//
//  GameScene.m
//  Zombie Conga
//
//  Created by Iyad Horani on 2/05/2015.
//  Copyright (c) 2015 IRONIC3D. All rights reserved.
//

#import "GameScene.h"

static const float ZOMBIE_MOVE_POINTS_PER_SEC = 120.0;
static const float ZOMBIE_ROTATE_RADIANS_PER_SEC = 4 * M_PI;

static inline CGPoint CGPointAdd(const CGPoint a,
                                const CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointSubtract(const CGPoint a,
                                     const CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a,
                                            const CGFloat b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline CGFloat CGPointLength(const CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint CGPointNormalize(const CGPoint a) {
    CGFloat length = CGPointLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat CGPointToAngle(const CGPoint a) {
    return atan2f(a.y, a.x);
}

static inline CGFloat ScalarSign(CGFloat a) {
    return a >= 0 ? 1 : -1;
}

static inline CGFloat ScalarShortestAngleBetween(const CGFloat a,
                                                 const CGFloat b) {
    CGFloat difference = b - a;
    CGFloat angle = fmodf(difference, M_PI * 2);
    
    if (angle >= M_PI) {
        angle -= M_PI * 2;
    } else if (angle <= -M_PI) {
        angle += M_PI * 2;
    }
    return angle;
}

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
    [self rotateSprite:_zombie toFace:_velocity rotateRadiansPerSec:ZOMBIE_ROTATE_RADIANS_PER_SEC];
    [self boundsCheckPlayer];
}

#pragma mark USER METHODS
#pragma mark ----------------------------

-(void)moveSprite:(SKSpriteNode *)sprite
         velocity:(CGPoint)velocity {
    
    CGPoint amountToMove = CGPointMultiplyScalar(velocity, _dt);
    
    sprite.position = CGPointAdd(sprite.position, amountToMove);
}

-(void)moveZombieToward:(CGPoint)location {
    CGPoint offset = CGPointSubtract(location, _zombie.position);
    
    CGPoint direction = CGPointNormalize(offset);
    
    _velocity = CGPointMultiplyScalar(direction, ZOMBIE_MOVE_POINTS_PER_SEC);
}

-(void)rotateSprite:(SKSpriteNode *)sprite
             toFace:(CGPoint)direction
rotateRadiansPerSec:(CGFloat)rotateRadiansPerSec {
    float targetAngle = CGPointToAngle(direction);
    float shortest = ScalarShortestAngleBetween(sprite.zRotation, targetAngle);
    float amtToRotate = rotateRadiansPerSec * _dt;
    if (ABS(shortest) < amtToRotate) {
        amtToRotate = ABS(shortest);
    }
    sprite.zRotation += ScalarSign(shortest) * amtToRotate;
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
