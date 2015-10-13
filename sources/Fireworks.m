/* Mines - Fireworks.m
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Betty Lab.
Released under the terms of the GNU General Public License v3. */

#import "Fireworks.h"


@implementation Fireworks


	- (id) initWithFrame: (NSRect) frame
		{
		if ((self = [super initWithFrame: frame]))
			{
			[self setWantsLayer: YES];

			CGColorRef color = CGColorCreateGenericRGB(0.5, 0.5, 0.5, 1.0);

			//Load the spark image for the particle
			CGDataProviderRef dataProvider = CGDataProviderCreateWithFilename
				([[[NSBundle mainBundle]
					pathForResource: @"Fireworks Particle"
					ofType:		 @"png"]
				UTF8String]);

			CGImageRef image = CGImageCreateWithPNGDataProvider(dataProvider, NULL, NO, kCGRenderingIntentDefault);
			CGDataProviderRelease(dataProvider);

			(_emitter = [CAEmitterLayer layer]).autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
			_emitter.needsDisplayOnBoundsChange = YES;
			_emitter.frame = NSRectToCGRect(self.bounds);
			_emitter.emitterPosition = CGPointMake(self.bounds.size.width / 2.0, 0.0);
			_emitter.renderMode = kCAEmitterLayerAdditive;

			//Invisible particle representing the rocket before the explosion
			_rocket				= [CAEmitterCell emitterCell];
			_rocket.emissionLongitude	= M_PI / 2.0;
			_rocket.emissionLatitude	= 0.0;
			_rocket.lifetime		= 1.6;
			_rocket.birthRate		= 1.0;
			_rocket.velocity		= frame.size.height * 0.35;
			_rocket.velocityRange		= frame.size.height * 0.15;
//			_rocket.yAcceleration		= -150.0;
			_rocket.emissionRange		= M_PI / 3.0;
			_rocket.color			= color;

			CGColorRelease(color);

			_rocket.redRange		= 1.0;
			_rocket.greenRange		= 1.0;
			_rocket.blueRange		= 1.0;

			//Flare particles emitted from the rocket as it flys
			_flare				= [CAEmitterCell emitterCell];
			_flare.contents			= (id)image;
			_flare.scale			= 0.2;
			_flare.velocity			= 0.0;
			_flare.birthRate		= 150.0;
			_flare.lifetime			= 0.5;
			_flare.alphaSpeed		= -0.7;
			_flare.scaleSpeed		= -0.1;
			_flare.scaleRange		= 0.1;
			_flare.emissionRange		= M_PI / 10.0;
			_flare.scaleSpeed		= -0.5;

			//The particles that make up the explosion
			_explosion			= [CAEmitterCell emitterCell];
			_explosion.contents		= (id)image;
			_explosion.birthRate		= 19999.0;
			_explosion.scale		= 0.3;
			_explosion.velocity		= frame.size.height * 0.3;
			_explosion.lifetime		= 2.0;
			_explosion.alphaSpeed		= -0.2;
			_explosion.duration		= 1.0;
			_explosion.beginTime		= 1.5;
			_explosion.emissionRange	= M_PI * 2.0;
			_explosion.scaleSpeed		= -0.1;

			_rocket.emitterCells		= [NSArray arrayWithObjects: _flare, _explosion, nil];
			_emitter.emitterCells		= [NSArray arrayWithObjects: _rocket, nil];
			_emitter.beginTime		= CACurrentMediaTime();

			CGImageRelease(image);
			[self.layer addSublayer: _emitter];
			}

		return self;
		}


	- (void) dealloc
		{
		[_emitter removeFromSuperlayer];
		self.wantsLayer = NO;
		[super dealloc];
		}


	- (void) setFrame: (NSRect) frame
		{
		[super setFrame: frame];
		_emitter.emitterPosition = CGPointMake(self.bounds.size.width / 2.0, 0.0);
		_rocket.velocity = frame.size.height * 0.35;
		_rocket.velocityRange = frame.size.height * 0.15;
		_flare.velocity = 0.0;
		_explosion.velocity = frame.size.height * 0.3;
		}


@end

// EOF
