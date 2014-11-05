/* Mines - Cannon.h
 __  __
|  \/  | __  ____  ___  ____
|      |(__)|    |/ -_)(__ <
|__\/__||__||__|_|\___//___/
Copyright © 2013-2014 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "Laser.h"
@class Cannon;

@protocol CannonDelegate <NSObject>

	- (void) cannonWantsToShoot:   (Cannon *) cannon;
	- (void) cannonLaserWillStart: (Cannon *) cannon;
	- (void) cannonLaserDidEnd:    (Cannon *) cannon;
	- (void) cannonDidEnd:	       (Cannon *) cannon;

@end

@interface Cannon : NSView {
	id <CannonDelegate> _delegate;
	NSImage*	    _ballImage;
	NSBezierPath*	    _tubePath;
	NSGradient*	    _tubeGradient;
	NSBezierPath*	    _muzzlePath;
	NSShadow*	    _muzzleInnerShadow;
	Laser*		    _laser;
	CGFloat		    _rotationVelocity;
	CGFloat		    _beamVelocity;
	CGFloat		    _blazeDuration;
	CGFloat		    _blazeRadius;
	CGFloat		    _laserWidth;
	CGFloat		    _tubeAngle;
	CGFloat		    _tubeTargetAngle;
	NSTimer*	    _timer;
	NSPoint		    _laserStartPoint;
	NSPoint		    _laserEndPoint;
	CGFloat		    _rotationDuration;
	CGFloat		    _elapsed;
	BOOL		    _isPressed;
	BOOL		    _isBusy;
}
	@property (nonatomic, assign) id <CannonDelegate> delegate;
	@property (nonatomic, assign) CGFloat rotationVelocity;
	@property (nonatomic, assign) CGFloat beamVelocity;
	@property (nonatomic, assign) CGFloat blazeDuration;
	@property (nonatomic, assign) CGFloat blazeRadius;
	@property (nonatomic, assign) CGFloat laserWidth;

	- (void) shootToPoint: (NSPoint) point;
@end

// EOF
