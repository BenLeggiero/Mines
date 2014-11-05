/* Mines - Laser.h
 __  __
|  \/  | __  ____  ___  ____
|      |(__)|    |/ -_)(__ <
|__\/__||__||__|_|\___//___/
Copyright © 2013-2014 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <AppKit/AppKit.h>

@interface Laser : NSObject {
	NSWindow* _window;
	CGFloat   _beamDuration;
	CGFloat   _blazeDuration;
	CGFloat   _blazeRadius;
	CGFloat   _elapsed;
	NSPoint   _a;
	NSPoint   _b;
	CGFloat   _distance;
	id	  _target;
	SEL	  _action;
	NSTimer*  _timer;
}
	- (void) shootFromPoint: (NSPoint   ) a
		 toPoint:	 (NSPoint   ) b
		 beamVelocity:	 (CGFloat   ) beamVelocity // pixels per second
		 blazeDuration:	 (CGFloat   ) blazeDuration
		 blazeRadius:	 (CGFloat   ) blazeRadius
		 lineWidth:	 (CGFloat   ) lineWidth
		 parentWindow:	 (NSWindow *) parentWindow
		 didEndTarget:	 (id	    ) target
		 action:	 (SEL	    ) action;
@end

// EOF
