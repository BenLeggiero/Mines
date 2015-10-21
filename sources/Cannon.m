/* Mines - Cannon.m
   __  __
  /  \/  \  __ ___  ____   ____
 /	  \(__)   \/  -_)_/  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Betty Lab.
Released under the terms of the GNU General Public License v3. */

#import "Cannon.h"
#import "NSBezierPath+BL.h"
#import "NSWindow+BL.h"
#import "geometry.h"

#define kStepDuration	(1.0 / 60.0)
#define kTubeWidth	8.0
#define kTubeRadius	(kTubeWidth / 2.0)
#define kTubeHeight	15.0

#define kBallGradientStartRadius 0.0
#define kBallGradientEndRadius	 32.0
#define kBallGradientStartPoint	 CGPointMake(16.0, 24.0)
#define kBallGradientEndPoint	 CGPointMake(16.0, 16.0)

typedef struct {
	struct {CGFloat*   locations;
		CGFloat*   colors;
		NSUInteger colorCount;
	} ball;

	CGFloat tubeColors[2];
} GradientData;

static const GradientData yosemiteGradientData = {
	{(CGFloat[ 3]){0.0, 0.3, 1.0},
	 (CGFloat[12]){1.0, 1.0, 1.0, 1.0, 0.75, 0.75, 0.75, 1.0, 0.45, 0.45, 0.45, 1.0}, 3},
//	 (CGFloat[12]){1.0, 0.0, 0.0, 1.0, 0.75, 0.75, 0.75, 1.0, 0.45, 0.45, 0.45, 1.0}, 3},
	{0.68, 0.9}
};

static const GradientData lionGradientData = {
	{(CGFloat[ 3]){0.0, 0.3, 1.0},
	 (CGFloat[12]){1.0, 1.0, 1.0, 1.0, 0.7, 0.7, 0.7, 1.0, 0.25, 0.25, 0.25, 1.0}, 3},
//	 (CGFloat[12]){0.0, 1.0, 0.0, 1.0, 0.7, 0.7, 0.7, 1.0, 0.25, 0.25, 0.25, 1.0}, 3},
	{0.555, 0.888}
};

static const GradientData leopardGradientData = {
	{(CGFloat[ 3]){0.0, 0.3, 1.0},
	 (CGFloat[12]){1.0, 1.0, 1.0, 1.0, 0.6, 0.6, 0.6, 1.0, 0.0, 0.0, 0.0, 1.0}, 3},
//	 (CGFloat[12]){0.0, 0.0, 1.0, 1.0, 0.6, 0.6, 0.6, 1.0, 0.0, 0.0, 0.0, 1.0}, 3},
	{0.444, 0.777}
};


@implementation Cannon

#	pragma mark - Helpers


	- (void) moveTubeToTargetStep: (NSTimer *) timer
		{
		if ((_elapsed += kStepDuration) >= _rotationDuration)
			{
			[_timer invalidate];
			_timer = nil;
			_elapsed = _rotationDuration;

			if ([_delegate respondsToSelector: @selector(cannonLaserWillStart:)])
				[_delegate cannonLaserWillStart: self];

			[_laser	shootFromPoint: _laserStartPoint
				toPoint:	_laserEndPoint
				beamVelocity:	_beamVelocity
				blazeDuration:	_blazeDuration
				blazeRadius:	_blazeRadius
				lineWidth:	_laserWidth
				parentWindow:	self.window
				didEndTarget:	self
				action:		@selector(laserDidEnd:)];
			}

		else _tubeAngle = (_elapsed * _tubeTargetAngle) / _rotationDuration;

		[self setNeedsDisplay: YES];
		}


	- (void) moveTubeToInitialPositionStep: (NSTimer *) timer
		{
		if ((_elapsed -= kStepDuration) <= 0.0)
			{
			[_timer invalidate];
			_timer = nil;
			_tubeAngle = 0.0;
			_isBusy = NO;

			if ([_delegate respondsToSelector: @selector(cannonDidEnd:)])
				[_delegate cannonDidEnd: self];
			}

		else _tubeAngle = (_elapsed * _tubeTargetAngle) / _rotationDuration;

		[self setNeedsDisplay: YES];
		}


	- (void) laserDidEnd: (Laser *) sender
		{
		if ([_delegate respondsToSelector: @selector(cannonLaserDidEnd:)])
			[_delegate cannonLaserDidEnd: self];

		_timer = [NSTimer
			scheduledTimerWithTimeInterval: 1.0 / 60.0
			target:				self
			selector:			@selector(moveTubeToInitialPositionStep:)
			userInfo:			nil
			repeats:			YES];
		}


#	pragma mark - Overwritten


	- (id) initWithFrame: (NSRect) frame
		{
		if ((self = [super initWithFrame: frame]))
			{
			const GradientData *gradientData = IS_YOSEMITE_OR_HIGHER
				? &yosemiteGradientData
				: (IS_LION_OR_HIGHER ? &lionGradientData : &leopardGradientData);

			_laser		  = [[Laser alloc] init];
			_rotationVelocity = 180.0;
			_beamVelocity	  = 2500.0;
			_blazeDuration	  = 0.3;

			[_ballImage = [[NSImage alloc] initWithSize: self.bounds.size] lockFocus];

	#		ifdef DEBUG_GEOMETRY
				[[NSColor greenColor] setFill];
				NSRectFill(self.bounds);
	#		endif

			CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
			NSSize size = self.bounds.size;
			NSColor *white = [NSColor whiteColor];

			//----------------------.
			// Creamos la bola base |
			//----------------------'
			NSBezierPath *ball = [NSBezierPath bezierPathWithOvalInRect:
				NSMakeRect(4.0, 4.0, size.width - 8.0, size.height - 8.0)];

			ball.lineWidth = 0.5;

			//-----------------------------------------------------------------.
			// Creamos el brillo de la parte inferior del contorno de la bola. |
			//-----------------------------------------------------------------'
			//NSBezierPath *ballBottomBrightness = [NSBezierPath bezierPathWithOvalInRect:
			//	NSMakeRect(4.0, 3.0, size.width - 8.0, size.height - 8.0)];

			NSBezierPath *ballBottomBrightness = [NSBezierPath bezierPath];

			[ballBottomBrightness
				appendBezierPathWithArcWithCenter: NSMakePoint
					(4.0 + (size.width  - 8.0) / 2.0,
					 3.0 + (size.height - 8.0) / 2.0)
				radius:	    (size.width  - 8.0) / 2.0
				startAngle: 0.0
				endAngle:   180.0
				clockwise:  YES];

			ballBottomBrightness.lineWidth = 0.5;

			//-----------------------------.
			// Dibujamos la bola de fondo. |
			//-----------------------------'
			CGContextBeginTransparencyLayer(context, NULL);

				[ball fill];
				CGContextSetBlendMode(context, kCGBlendModeSourceIn);
				CGGradientRef gradient;
				CGColorSpaceRef colorSpace;
				colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

				gradient = CGGradientCreateWithColorComponents
					(colorSpace, gradientData->ball.colors,
					 gradientData->ball.locations, gradientData->ball.colorCount);

				CGContextDrawRadialGradient
					(context, gradient, kBallGradientStartPoint, kBallGradientStartRadius,
					 kBallGradientEndPoint, kBallGradientEndRadius, 0);

				CGGradientRelease(gradient);
				CGColorSpaceRelease(colorSpace);

			CGContextEndTransparencyLayer(context);

			//-----------------------------------------.
			// Bibujamos el brillo inferior de la bola |
			// en blanco y su contorno en negro.	   |
			//-----------------------------------------'
			[white setStroke];
			[ballBottomBrightness stroke];
			[[NSColor colorWithCalibratedWhite: 0.10 alpha: 1.0] setStroke];
			[ball stroke];

			//------------------------------------------------------.
			// Dibujamos la sombra del contorno interno de la bola. |
			//------------------------------------------------------'
			NSShadow * shadow = [[NSShadow alloc] init];

			[shadow setShadowColor: [NSColor blackColor]];
			[shadow setShadowBlurRadius: 2.0];
			[ball drawInnerShadow: shadow];
			[shadow release];

			[_ballImage unlockFocus];

			//----------------------------.
			// Creamos el tubo del cañón. |
			//----------------------------'
			NSPoint center = NSMakePoint(size.width / 2.0, size.height / 2.0);

			_tubePath = [[NSBezierPath alloc] init];

			_tubePath.lineWidth = 1.0;
			[_tubePath moveToPoint: NSMakePoint(center.x - kTubeRadius, 5.0)];
			[_tubePath lineToPoint: NSMakePoint(center.x - kTubeRadius, 11.0)];

			[_tubePath
				appendBezierPathWithArcWithCenter: NSMakePoint(center.x, 11.0)
				radius:				   kTubeRadius
				startAngle:			   180.0
				endAngle:			   0.0
				clockwise:			   YES];

			[_tubePath lineToPoint: NSMakePoint(center.x + kTubeRadius, center.y - kTubeHeight + kTubeRadius)];

			[_tubePath
				appendBezierPathWithArcWithCenter: NSMakePoint(center.x, 5.0)
				radius:				   kTubeRadius
				startAngle:			   0.0
				endAngle:			   180.0
				clockwise:			   NO];

			[_tubePath
				appendBezierPathWithArcWithCenter: NSMakePoint(center.x, 5.0)
				radius:				   kTubeRadius
				startAngle:			   180.0
				endAngle:			   360.0
				clockwise:			   NO];

			_tubeGradient = [[NSGradient alloc] initWithColorsAndLocations:
				[NSColor colorWithCalibratedWhite: gradientData->tubeColors[0] alpha: 1.0], 0.0,
				[NSColor colorWithCalibratedWhite: gradientData->tubeColors[1] alpha: 1.0], 0.5,
				[NSColor colorWithCalibratedWhite: gradientData->tubeColors[0] alpha: 1.0], 1.0,
				nil];

			//----------------------------.
			// Creamos la boca del cañón. |
			//----------------------------'
			_muzzlePath = [[NSBezierPath bezierPathWithOvalInRect: NSMakeRect
				(center.x - kTubeRadius, center.y - kTubeHeight, kTubeWidth, kTubeWidth)]
					retain];

			_muzzlePath.lineWidth = 0.5;

			_muzzleInnerShadow = [[NSShadow alloc] init];
			[_muzzleInnerShadow setShadowColor: white];
			[_muzzleInnerShadow setShadowOffset: NSMakeSize(0.0, 1.0)];
			[_muzzleInnerShadow setShadowBlurRadius: 2.5];
			}

		return self;
		}


	- (void) dealloc
		{
		[_timer		 invalidate];
		[_laser		    release];
		[_ballImage	    release];
		[_tubePath	    release];
		[_tubeGradient	    release];
		[_muzzlePath	    release];
		[_muzzleInnerShadow release];
		[super		    dealloc];
		}


	- (void) drawRect: (NSRect) frame
		{
		NSSize size = self.bounds.size;
		NSPoint center = NSMakePoint(size.width / 2.0, size.height / 2.0);
		NSBezierPath *tubePath, *muzzlePath;

		//-----------------------------------.
		// Dibujamos la bola base del cañón. |
		//-----------------------------------'
		[_ballImage drawInRect: self.bounds fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];

		//--------------------------------------.
		// Si es necesario, rotamos las piezas. |
		//--------------------------------------'
		if (_tubeAngle != 0.0)
			{
			NSAffineTransform *transform = [NSAffineTransform transform];
			NSAffineTransform *move1     = [NSAffineTransform transform];
			NSAffineTransform *rotate    = [NSAffineTransform transform];
			NSAffineTransform *move2     = [NSAffineTransform transform];

			[move1 translateXBy: -center.x yBy: -center.y];
			[move2 translateXBy:  center.x yBy:  center.y];
			[rotate rotateByDegrees: _tubeAngle];

			[transform appendTransform: move1];
			[transform appendTransform: rotate];
			[transform appendTransform: move2];

			[(tubePath   = [[_tubePath   copy] autorelease]) transformUsingAffineTransform: transform];
			[(muzzlePath = [[_muzzlePath copy] autorelease]) transformUsingAffineTransform: transform];
			}

		else	{
			tubePath = _tubePath;
			muzzlePath = _muzzlePath;
			}

		//------------------------------.
		// Dibujamos el tubo del cañón. |
		//------------------------------'
		[[NSColor colorWithCalibratedWhite: 0.0 alpha: 0.81] setStroke];
		[tubePath stroke];

		[_tubeGradient drawInBezierPath: tubePath angle: _tubeAngle];

		//------------------------------.
		// Dibujamos la boca del cañón. |
		//------------------------------'
		[[NSColor whiteColor] setStroke];
		[[NSColor blackColor] setFill];
		[muzzlePath stroke];
		[muzzlePath fill];
		[muzzlePath drawInnerShadow: _muzzleInnerShadow];
		}


	- (BOOL) mouseDownCanMoveWindow
		{return NO;}


	- (void) mouseDown: (NSEvent *) event
		{if (!_isBusy) _isPressed = YES;}


	- (void) mouseDragged: (NSEvent *) event
		{
		if (!_isBusy)
			{
			BOOL isPressed = NSPointInRect
				([event locationInWindow], [self convertRect: self.bounds toView: nil]);

			if (isPressed != _isPressed) _isPressed = isPressed;
			}
		}


	- (void) mouseUp: (NSEvent *) event
		{
		if (!_isBusy && _isPressed)
			{
			_isPressed = NO;
			[_delegate cannonWantsToShoot: self];
			}
		}


#	pragma mark - Public

	@synthesize delegate		= _delegate;
	@synthesize rotationVelocity	= _rotationVelocity;
	@synthesize beamVelocity	= _beamVelocity;
	@synthesize blazeDuration	= _blazeDuration;
	@synthesize blazeRadius		= _blazeRadius;
	@synthesize laserWidth		= _laserWidth;


	- (void) shootToPoint: (NSPoint) point
		{
		NSSize size = self.bounds.size;

		NSPoint center = [self.window convertPointToScreen: [self
			convertPoint: NSMakePoint(size.width / 2.0, size.height / 2.0)
			toView:	      nil]];

		_rotationDuration =
			(_tubeTargetAngle = PointAngle(center, point) * (180.0 / M_PI) - 270.0)
			/ _rotationVelocity;

		if (_rotationDuration < 0.0) _rotationDuration = -_rotationDuration;

		_isBusy		 = YES;
		_elapsed	 = 0.0;
		_laserStartPoint = PointByVectorAtDistance(center, point, 11.0);
		_laserEndPoint	 = point;

		[_timer invalidate];

		_timer = [NSTimer
			scheduledTimerWithTimeInterval: kStepDuration
			target:				self
			selector:			@selector(moveTubeToTargetStep:)
			userInfo:			nil
			repeats:			YES];
		}


@end

// EOF
