/* Mines - Explosion.h
 __  __
|  \/  | __  ____  ___	___
|      |(__)|    |/ -_)/_  \
|__\/__||__||__|_|\___/ /__/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <QuartzCore/QuartzCore.h>

@interface Explosion : NSObject {
	CAEmitterLayer*	_emitter;
	CGImageRef	_particleImage;
	NSTimer*	_timer;
	NSWindow*	_window;
	id		_target;
	SEL		_action;
}
	- (void) explodeAtPoint: (NSPoint) point
		 target:	 (id	 ) target
		 action:	 (SEL	 ) action;

	- (void) cancelExplosion;
@end

// EOF
