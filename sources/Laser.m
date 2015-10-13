/* Mines - Laser.m
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Betty Lab.
Released under the terms of the GNU General Public License v3. */

#import "Laser.h"
#import "geometry.h"
#define kStepDuration (1.0 / 60.0)

@interface LaserView : NSView {
	@public
	NSPoint _a;
	NSPoint _b;
	BOOL	_radius;
	CGFloat	_lineWidth;
}
@end


@implementation LaserView

	- (void) drawRect: (NSRect) frame
		{
		[self lockFocus];

		/*[[NSColor yellowColor] setFill];
		NSRectFill(self.bounds);*/

		NSBezierPath *path;

		if (_radius == 0.0)
			{
			path = [NSBezierPath bezierPath];
			path.lineJoinStyle = NSRoundLineJoinStyle;
			path.lineCapStyle  = NSRoundLineCapStyle;
			[path moveToPoint: _a];
			[path lineToPoint: _b];
			}

		else path = [NSBezierPath bezierPathWithOvalInRect:
			NSMakeRect(_b.x - _radius, _b.y - _radius, _radius * 2.0, _radius * 2.0)];

		[[NSColor redColor] setStroke];
		path.lineWidth = _lineWidth;
		[path stroke];

		[self unlockFocus];
		}

@end


@implementation Laser


	- (void) dealloc
		{
		[_timer invalidate];
		[_window release];
		[super dealloc];
		}


	- (void) blazeStep: (NSTimer *) timer
		{
		if ((_elapsed += kStepDuration) > _blazeDuration)
			{
			[_timer invalidate];
			_timer = nil;
			[_window.parentWindow removeChildWindow: _window];
			[_window orderOut: self];
			[_window release];
			_window = nil;
			[_target performSelector: _action withObject: self];
			}

		else	{
			LaserView *view = (LaserView *)_window.contentView;

			view->_radius = _elapsed * _blazeRadius / _blazeDuration;
			view.needsDisplay = YES;
			}
		}


	- (void) laserStep: (NSTimer *) timer
		{
		LaserView *view = (LaserView *)_window.contentView;

		if ((_elapsed += kStepDuration) > _beamDuration)
			{
			_elapsed = 0.0;
			view->_b = _b;
			view->_radius = 0.0;
			[timer invalidate];

			_timer = [NSTimer
				scheduledTimerWithTimeInterval: kStepDuration
				target:				self
				selector:			@selector(blazeStep:)
				userInfo:			nil
				repeats:			YES];
			}

		else	{
			if ((_elapsed * _distance) / _beamDuration - 50.0 > 0.0)
				view->_a = PointByVectorOfKnownMagnitideAtDistance
					(_a, _b, _distance, (_elapsed * _distance) / _beamDuration - 50.0);

			view->_b = PointByVectorOfKnownMagnitideAtDistance
					(_a, _b, _distance, (_elapsed * _distance) / _beamDuration);

			view.needsDisplay = YES;
			}
		}


	- (void) shootFromPoint: (NSPoint   ) a
		 toPoint:	 (NSPoint   ) b
		 beamVelocity:	 (CGFloat   ) beamVelocity
		 blazeDuration:	 (CGFloat   ) blazeDuration
		 blazeRadius:	 (CGFloat   ) blazeRadius
		 lineWidth:	 (CGFloat   ) lineWidth
		 parentWindow:	 (NSWindow *) parentWindow
		 didEndTarget:	 (id	    ) target
		 action:	 (SEL	    ) action
		{
		CGFloat padding = blazeRadius + lineWidth + 5.0;
		NSPoint minimum = NSMakePoint(MIN(a.x, b.x), MIN(a.y, b.y));
		NSPoint maximum = NSMakePoint(MAX(a.x, b.x), MAX(a.y, b.y));

		NSRect frame = NSMakeRect
			(minimum.x, minimum.y,
			 maximum.x - minimum.x, maximum.y - minimum.y);

		_window = [[NSWindow alloc]
			initWithContentRect: NSMakeRect
				(frame.origin.x - padding, frame.origin.y - padding,
				 frame.size.width + padding * 2.0, frame.size.height + padding * 2.0)
			styleMask: NSBorderlessWindowMask
			backing:   NSBackingStoreBuffered
			defer:     YES];

#		ifdef DEBUG_GEOMETRY
			_window.backgroundColor = [NSColor
				colorWithCalibratedRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.5];

			beamVelocity  /= 7.0;
			blazeDuration *= 7.0;
#		else
			_window.backgroundColor = [NSColor clearColor];
#		endif

		_window.hasShadow	   = NO;
		_window.opaque		   = NO;
		_window.level		   = parentWindow.level + 1;
		_window.ignoresMouseEvents = YES;

		NSView *view = [[LaserView alloc] initWithFrame: NSZeroRect];

		_window.contentView = view;
		[view release];

		_target	       = target;
		_action        = action;
		_beamDuration  = PointDistance(a, b) / beamVelocity;
		_blazeDuration = blazeDuration;
		_blazeRadius   = blazeRadius;
		_elapsed       = 0.0;
		_a	       = NSMakePoint(a.x - frame.origin.x + padding, a.y - frame.origin.y + padding);
		_b	       = NSMakePoint(b.x - frame.origin.x + padding, b.y - frame.origin.y + padding);
		_distance      = PointDistance(_a, _b);

		LaserView *beam = _window.contentView;

		beam.frame = NSMakeRect
			(0.0, 0.0,
			 frame.size.width + padding * 2.0,
			 frame.size.height + padding * 2.0);

		beam->_radius = 0.0;
		beam->_a = _a;
		beam->_b = _a;
		beam->_lineWidth = lineWidth;

		if (parentWindow) [parentWindow addChildWindow: _window ordered: NSWindowAbove];
		[_window makeKeyAndOrderFront: nil];

		_timer = [NSTimer
			scheduledTimerWithTimeInterval: kStepDuration
			target:				self
			selector:			@selector(laserStep:)
			userInfo:			nil
			repeats:			YES];
		}


@end

// EOF
