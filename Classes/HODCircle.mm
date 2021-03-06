//
//  HODCircle.m
//  Cocos2dLesson1
//
//  Created by Max Wittek on 3/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HODCircle.h"
#import "osu-import.h.mm"
#import "GameScene.h"
#import "Scoreboard.h"

@implementation HODCircle
@synthesize ring;

//static NSMutableArray *HODCircleTextures = nil;

// on "init" you need to initialize your instance

- (id) initWithHitObject:(HitObject*)hitObject_ red:(int)r green:(int)g blue:(int)b initialScale: (double)s
{
	if( (self = [super initWithHitObject:hitObject_ red:r green:g blue:b initialScale: s]) ) {
		self.visible = false;
		
		size = CGSizeMake(120, 120);
		
		CCRenderTexture * buttonTex;
		buttonTex = [[self createHODCircleTexture:r :g :b] retain];

		
		ring = [CCSprite spriteWithFile:@"button.ring.png"];		 
		ring.position = ccp(hitObject->x, hitObject->y);
		ccColor3B color = {r, g, b};
		ring.color = color;
		
		button = [CCSprite spriteWithTexture: [[buttonTex sprite] texture]];
		button.position = ccp(hitObject->x, hitObject->y);
		button.flipY = YES;
		
		///////// Number thang
		
		// 0 = repeat
		if(hitObject->number == 0) { 
			/*
			 // Do something special if the number is 0.
			 numberDisplay = 
			 [CCLabelTTF labelWithString:[NSString stringWithFormat:@"*"] 
			 fontName:@"Helvetica Neue" fontSize:48];
			 */
			numberDisplay = 
			[CCSprite spriteWithFile:@"return.png"];
		} 
		else if(hitObject->number == -1) {
			numberDisplay = 
			[CCLabelBMFont labelWithString:[NSString stringWithFormat:@""] 
								   fntFile:@"zerofourbee-48.fnt"];
			//numberDisplay.scale = 2;
		} else {
			/*
			 numberDisplay = 
			 [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", hitObject->number] 
			 fontName:@"Helvetica Neue" fontSize:48];
			 */
			numberDisplay = 
			[CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", hitObject->number] 
								   fntFile:@"zerofourbee-48.fnt"];
			//numberDisplay.scale = 2;
		}
		
		numberDisplay.position = ccp(hitObject->x, hitObject->y);
		
		/////// end number thang
		
		[self addChild: button];
		[self addChild:ring];
		[self addChild: numberDisplay];
		
		button.scale = initialScale;
		ring.scale = initialScale;
		numberDisplay.scale = initialScale;
		
		[self setOpacity:0];
		
		[buttonTex release];
		
		// TODO: gotta eventually release everything in HODCircleTextures
	}
	return self;
}

- (CCRenderTexture*) createHODCircleTexture: (int)red_ :(int)green_ :(int)blue_ {
	return [self createHODCircleTexture: red_ :green_ :blue_ :true];
}


// I should make a HODCircle texture bank. (colorgroup -> (number -> texture) ) and 0 for no-number

// TODO: potential memory leak here???
- (CCRenderTexture*) createHODCircleTexture: (int)red_ :(int)green_ :(int)blue_ :(BOOL)doNumber
{
	/* NOTE: Should be Retina Display-ified */
	CCRenderTexture * target = 
	[CCRenderTexture renderTextureWithWidth:size.width height:size.height];
	target.position = ccp(0,0);
	
	CCSprite * underlayTex = [CCSprite spriteWithFile:@"button.underlay.png"];
	CCSprite * buttonTex = [CCSprite spriteWithFile:@"button.button.png"];
	CCSprite * overlayTex = [CCSprite spriteWithFile:@"button.overlay.png"];
	
	/*
	ccTexParams texParams = { GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE };	
	[[underlayTex texture] generateMipmap];
	[[underlayTex texture] setTexParameters:&texParams];
	
	[[buttonTex texture] generateMipmap];
	[[buttonTex texture] setTexParameters:&texParams];
	
	[[overlayTex texture] generateMipmap];
	[[overlayTex texture] setTexParameters:&texParams];
	 */
	
	underlayTex.position = ccp(size.width/2,size.height/2);
	buttonTex.position = ccp(size.width/2,size.height/2);
	overlayTex.position = ccp(size.width/2,size.height/2);
	
	buttonTex.color = ccc3(red_, green_, blue_);
	
	[target begin];
	[underlayTex visit];
	[buttonTex visit];
	[overlayTex visit];
	
	[target end];
	
	return target;
}


- (void) appearWithDuration: (double)duration
{
	//self.position = CGPointMake(hitObject.x, hitObject.y);
	
	self.visible = true;
	ring.visible = true ;
	[ring setScale:initialScale];
	
	id actionFadeIn = [CCFadeIn actionWithDuration:duration];
	id actionScaleHalf = [CCEaseIn actionWithAction:[CCScaleBy actionWithDuration:duration scale: 0.5] rate: 2];
	
	[self runAction:actionFadeIn];
	[ring runAction: actionScaleHalf];
}

- (void) justDisplay {
	ring.visible = false;
	self.visible = true;
	[self setOpacity:255];
	//[ring setOpacity: 0];
}

- (void) dealloc {
	//[button release];
	//[ring release];
	// do NOT release before super dealloc
	[super dealloc];
	
	[[CCTextureCache sharedTextureCache] removeTexture: [button texture] ];
	
	//[button release];
	//[ring release];
}

- (BOOL) wasHit:(CGPoint)location atTime:(NSTimeInterval)time {
	if([super wasHit:location atTime:time]) {
		// spawn a "300!" or whatever
		[(GameScene*)[self parent] spawnReaction:300 pos:ccp(hitObject->x, hitObject->y)];
		[(GameScene*)[self parent] removeHitObjectDisplay:self];
		
		return true;
	} else {
		return false;
	}
}

- (int) disappearTime {
	if(disappearTimeMs == -1)
		disappearTimeMs = hitObject->startTimeMs + [[self gsParent] timeAllowanceMs] + [[self gsParent] durationMs];
	return disappearTimeMs;
}

- (void) regenTexture {
	//NSLog(@"I am being regenerated.");
	[numberDisplay setString:[NSString stringWithFormat:@"%d", hitObject->number] ];
}


@end
