//
//  GameScene.m
//  PhysicsSpriteKit
//

#import "GameScene.h"

#define USE_BOX2D

#ifdef USE_BOX2D
#include "Box2D.h"
#define PTM_RATIO		32
#endif

#define SIZE (self.size.width)

@implementation GameScene {
#ifdef USE_BOX2D
	b2World *_world;
	b2Body *_groundBody;
	b2Body *_containerBody;
#else
	SKPhysicsBody *_containerBody;
#endif
}

-(void)didMoveToView:(SKView *)view {
	/* Setup your scene here */
	[self setupPhysics];
	[self addContainer];

	for (int i=0; i<3; ++i) {
		for (int j=0; j<3; ++j) {
			[self addBoxesAtPosition:CGPointMake(self.size.width/2+80*(i-1), self.size.height/2+80*(j-1))];
		}
	}
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	/* Called when a touch begins */
	/*
	CGPoint touchLocation = [(UITouch *)touches.anyObject locationInNode:self];

	// start catapult dragging when a touch inside of the catapult arm occurs
	if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation))
	{
		// move the mouseJointNode to the touch position
		_mouseJointNode.position = touchLocation;

		// setup a spring joint between the mouseJointNode and the catapultArm
		_mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
	}
	*/
}

-(void)setupPhysics {
#ifdef USE_BOX2D
	// Define the gravity vector.
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);

	// Construct a world object, which will hold and simulate the rigid bodies.
	_world = new b2World(gravity);

	_world->SetAllowSleeping(true);

	_world->SetContinuousPhysics(true);

	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner

	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	_groundBody = _world->CreateBody(&groundBodyDef);
#endif
}

-(void)addContainer {
	/* Pivot body */
	SKNode *pivotNode = [SKNode node];
	pivotNode.position = CGPointZero;

#ifdef USE_BOX2D
	b2FixtureDef fixtureDef;
	fixtureDef.friction = 0.5;
	b2BodyDef bodyDef;

	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(pivotNode.position.x/PTM_RATIO, pivotNode.position.y/PTM_RATIO);
	bodyDef.angle = 0;
	bodyDef.userData = (__bridge void *)pivotNode;
	b2Body *body = _world->CreateBody(&bodyDef);

	b2CircleShape circle;
	circle.m_radius = 1.0/PTM_RATIO;
	fixtureDef.shape = &circle;
	body->CreateFixture(&fixtureDef);
#else
	SKPhysicsBody *pivotBody = [SKPhysicsBody bodyWithCircleOfRadius:1.0];
	pivotBody.dynamic = NO;
	pivotNode.physicsBody = pivotBody;
#endif

	[self addChild:pivotNode];

	/* Container body */
	SKNode *containerNode = [SKNode node];
	containerNode.position = CGPointMake(self.size.width/2, self.size.height/2);

#ifdef USE_BOX2D
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(containerNode.position.x/PTM_RATIO, containerNode.position.y/PTM_RATIO);
	bodyDef.angle = 0;
	bodyDef.userData = (__bridge void *)containerNode;
	_containerBody = _world->CreateBody(&bodyDef);

	b2PolygonShape block;
	fixtureDef.density = 0.878906;
	fixtureDef.friction = 0.5;

	block.SetAsBox(SIZE/2.0f/PTM_RATIO, 20/2.0f/PTM_RATIO, b2Vec2(0, -(SIZE/2-10)/PTM_RATIO), 0);
	fixtureDef.shape = &block;
	_containerBody->CreateFixture(&fixtureDef);

	block.SetAsBox(SIZE/2.0f/PTM_RATIO, 20/2.0f/PTM_RATIO, b2Vec2(0, (SIZE/2-10)/PTM_RATIO), 0);
	fixtureDef.shape = &block;
	_containerBody->CreateFixture(&fixtureDef);

	block.SetAsBox(20/2.0f/PTM_RATIO, SIZE/2.0f/PTM_RATIO, b2Vec2(-(SIZE/2-10)/PTM_RATIO, 0), 0);
	fixtureDef.shape = &block;
	_containerBody->CreateFixture(&fixtureDef);

	block.SetAsBox(20/2.0f/PTM_RATIO, SIZE/2.0f/PTM_RATIO, b2Vec2((SIZE/2-10)/PTM_RATIO, 0), 0);
	fixtureDef.shape = &block;
	_containerBody->CreateFixture(&fixtureDef);
#else
	_containerBody = [SKPhysicsBody bodyWithBodies:
					  @[[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(SIZE, 20) center:CGPointMake(0, -(SIZE/2-10))],
						[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(SIZE, 20) center:CGPointMake(0, (SIZE/2-10))],
						[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(20, SIZE) center:CGPointMake(-(SIZE/2-10), 0)],
						[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(20, SIZE) center:CGPointMake((SIZE/2-10), 0)]]];
	_containerBody.mass = 1;
	_containerBody.friction = 0.5;
	containerNode.physicsBody = _containerBody;
#endif

	SKSpriteNode *spriteNode1 = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(SIZE, 20)];
	SKSpriteNode *spriteNode2 = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(SIZE, 20)];
	SKSpriteNode *spriteNode3 = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(20, SIZE)];
	SKSpriteNode *spriteNode4 = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(20, SIZE)];
	spriteNode1.position = CGPointMake(0, -(SIZE/2-10));
	spriteNode2.position = CGPointMake(0, (SIZE/2-10));
	spriteNode3.position = CGPointMake(-(SIZE/2-10), 0);
	spriteNode4.position = CGPointMake((SIZE/2-10), 0);
	[containerNode addChild:spriteNode1];
	[containerNode addChild:spriteNode2];
	[containerNode addChild:spriteNode3];
	[containerNode addChild:spriteNode4];

	[self addChild:containerNode];

#ifdef USE_BOX2D
	b2RevoluteJointDef jointDef;
	jointDef.Initialize(_groundBody, _containerBody, b2Vec2(containerNode.position.x/PTM_RATIO, containerNode.position.y/PTM_RATIO));
	_world->CreateJoint(&jointDef);
#else
	SKPhysicsJointPin *joint = [SKPhysicsJointPin jointWithBodyA:_containerBody bodyB:pivotBody anchor:containerNode.position];
	[self.physicsWorld addJoint:joint];
#endif
}

-(void)addBoxesAtPosition:(CGPoint)position {
	for (int i=0; i<4; ++i) {
		for (int j=0; j<4; ++j) {
			SKSpriteNode *boxNode = [SKSpriteNode spriteNodeWithColor:(i+4*j)%2?[SKColor redColor]:[SKColor blueColor] size:CGSizeMake(20, 20)];
			boxNode.position = CGPointMake(position.x+20*(i-1.5), position.y+20*(j-1.5));

#ifdef USE_BOX2D
			b2FixtureDef fixtureDef;
			fixtureDef.density = 0.562500;
			fixtureDef.friction = 0.5;
			b2BodyDef bodyDef;

			bodyDef.type = b2_dynamicBody;
			bodyDef.position.Set(boxNode.position.x/PTM_RATIO, boxNode.position.y/PTM_RATIO);
			bodyDef.angle = 0;
			bodyDef.userData = (__bridge void *)boxNode;
			b2Body *body = _world->CreateBody(&bodyDef);

			b2PolygonShape block;
			block.SetAsBox(20/2.0f/PTM_RATIO, 20/2.0f/PTM_RATIO);
			fixtureDef.shape = &block;
			body->CreateFixture(&fixtureDef);
#else
			SKPhysicsBody * boxBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(20, 20)];
			boxBody.mass = 0.01;
			boxBody.friction = 0.5;
			boxNode.physicsBody = boxBody;
#endif

			[self addChild:boxNode];
		}
	}
}

-(void)update:(CFTimeInterval)currentTime {
	/* Called before each frame is rendered */
#ifdef USE_BOX2D
	_containerBody->SetAngularVelocity(-4*M_PI/60);
	_world->Step(1.0/30, 3, 2);

	for (b2Body* b = _world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			SKNode *sprite = (__bridge SKNode *)b->GetUserData();
			sprite.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			sprite.zRotation = b->GetAngle();
		}
	}
#else
	[_containerBody setAngularVelocity:-4*M_PI/60];
#endif
}

-(void)dealloc {
#ifdef USE_BOX2D
	delete _world;
	_world = NULL;
#endif
}

@end
