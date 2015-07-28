/* Mines - Explosion.m
 __  __
|  \/  | __  ____  ___	___
|      |(__)|    |/ -_)/_  \
|__\/__||__||__|_|\___/ /__/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "Explosion.h"
#define kSize 250.0

/*@interface ExplosionWindow : NSWindow @end

@implementation ExplosionWindow

	- (id)		retain	{NSLog(@"ExplosionWindow retain" ); return [super retain];}
	- (oneway void) release {NSLog(@"ExplosionWindow release"); [super release];}
	- (void)	dealloc {NSLog(@"ExplosionWindow dealloc"); [super dealloc];}

	- (NSRect) constrainFrameRect: (NSRect	  ) frame
		   toScreen:	       (NSScreen *) screen
		{return frame;}

@end*/


@implementation Explosion


	- (id) init
		{
		if ((self = [super init]))
			{
			CFURLRef URL = (CFURLRef)[[NSBundle mainBundle]
				URLForResource: @"Explosion Particle.png"
				withExtension:	nil];

			CGImageSourceRef source = CGImageSourceCreateWithURL(URL, NULL);

			_particleImage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
			CFRelease(source);
			}

		return self;
		}


	- (void) dealloc
		{
		//NSLog(@"Explosion dealloc");
		[_window release];
		[_timer invalidate];
		CGImageRelease(_particleImage);
		[super dealloc];
		}


	- (void) cancelExplosion
		{
		[_timer invalidate];
		_timer = nil;
		[_emitter removeFromSuperlayer];
		_emitter = nil;
		[_window.contentView setWantsLayer: NO];
		[_window orderOut: self];
		[_window release];
		_window = nil;
		}


	- (void) explosionDidEnd: (NSTimer *) timer
		{
		_timer = nil;
		[_emitter removeFromSuperlayer];
		_emitter = nil;
		[_window.contentView setWantsLayer: NO];
		[_window orderOut: self];
		[_window release];
		_window = nil;
		if (_target) [_target performSelector: _action withObject: self];
		}


	- (void) stopExplosion: (NSTimer *) timer
		{
		_emitter.birthRate = 0.0;

		_timer = [NSTimer
			scheduledTimerWithTimeInterval: 1.25
			target:				self
			selector:			@selector(explosionDidEnd:)
			userInfo:			nil
			repeats:			NO];
		}


	- (void) explodeAtPoint: (NSPoint) point
		 target:	 (id	 ) target
		 action:	 (SEL	 ) action
		{
		_window = [[NSWindow alloc]
			initWithContentRect: NSMakeRect(point.x - kSize / 2.0, point.y - kSize / 2.0, kSize, kSize)
			styleMask:	     NSBorderlessWindowMask
			backing:	     NSBackingStoreBuffered
			defer:		     YES];

#		if DEBUG_GEOMETRY
			_window.backgroundColor = [NSColor
				colorWithCalibratedRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.5];
#		else
			_window.backgroundColor = [NSColor clearColor];
#		endif

		//Create the emitter cell
		CAEmitterCell* particle = [CAEmitterCell emitterCell];
		NSView* contentView = _window.contentView;

		//_window.hasShadow	   = NO;
		_window.oneShot		   = YES;
		_window.hasShadow	   = NO;
		_window.opaque		   = NO;
		_window.level		   = NSMainMenuWindowLevel + 1;
		_window.ignoresMouseEvents = YES;
		contentView.wantsLayer	   = YES;
		_target			   = target;
		_action			   = action;
		_emitter		   = [CAEmitterLayer layer];
		_emitter.emitterPosition   = CGPointMake(kSize / 2.0, kSize / 2.0);
		_emitter.emitterMode	   = kCAEmitterLayerOutline;
		_emitter.emitterShape	   = kCAEmitterLayerCircle;
		_emitter.renderMode	   = kCAEmitterLayerAdditive;
		_emitter.emitterSize	   = CGSizeMake(1.0, 1.0);
		//particle.color	   = [NSColor colorWithCalibratedRed: 1.0 green: 1.0 blue: 0.55 alpha: 1.0].CGColor;
		particle.emissionLongitude = M_PI;
		particle.emissionLatitude  = M_PI;
		particle.birthRate	   = 5500.0;
		particle.lifetime	   = 1.0;
		particle.velocity	   = 100.0;
		particle.velocityRange	   = 0.0;
		particle.emissionRange	   = 1.0;
		particle.alphaSpeed	   = -1.0;
		particle.blueSpeed	   = -1.0;
		particle.redSpeed	   = -0.7;
		particle.greenSpeed	   = -1.0;
		//particle.redRange	   = 0.5;
		//particle.scaleRange	   = 0.5;
		//particle.scaleSpeed	   = 10.0;
		//particle.scale	   = 0.5;
		//particle.yAcceleration   = -200;
		//particle.scaleSpeed	   = 0.0;
		particle.contents	   = (id)_particleImage;
		particle.name		   = @"particle";
		_emitter.emitterCells	   = [NSArray arrayWithObject: particle];

		[_window makeKeyAndOrderFront: self];
		_emitter.beginTime = CACurrentMediaTime();
		[contentView.layer addSublayer: _emitter];

		_timer = [NSTimer
			scheduledTimerWithTimeInterval: 0.40
			target:				self
			selector:			@selector(stopExplosion:)
			userInfo:			nil
			repeats:			NO];
		}


@end

// EOF
