/* Mines - GameOverView.m
 __  __
|  \/  | __  ____  ___	___
|      |(__)|    |/ -_)/_  \
|__\/__||__||__|_|\___/ /__/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "GameOverView.h"
#import "NSBezierPath+CocoPlus.h"
#import "geometry.h"

#define kLine1FontSize		42.0
#define kLine2FontSize		15.0
#define kLineSpacing		5.0
#define kXPadding		20.0
#define kYPadding		10.0
#define kBoxCornerRadius	15.0


@implementation GameOverView


#	pragma mark - Accessors

	@synthesize target = _target;
	@synthesize action = _action;


#	pragma mark - Overwritten


	- (id) initWithFrame: (NSRect) frame
		{
		if ((self = [super initWithFrame: frame]))
			{
			_line1Font = [[NSFont boldSystemFontOfSize: kLine1FontSize] retain];

			_line2Path = [[NSBezierPath
				bezierPathWithString: _("GameOver.ClickHereForANewGame")
				inFont:		      [NSFont boldSystemFontOfSize: kLine2FontSize]]
					retain];
			}

		return self;
		}


	- (void) dealloc
		{
		[_line1Font release];
		[_line1Path release];
		[_line2Path release];
		[super dealloc];
		}


	- (void) drawRect: (NSRect) dirtyRect
		{
		if (_line1Path)
			{
			CGFloat boxCornerRadius = kBoxCornerRadius;
			NSSize size = self.bounds.size;
			NSPoint center = NSMakePoint(size.width / 2.0, size.height / 2.0);
			NSColor *white = [NSColor colorWithCalibratedWhite: 1.0 alpha: 0.90];

			//-----------------------------.
			// Creamos las lineas de texto |
			//-----------------------------'
			NSBezierPath *messagePath = [[NSBezierPath alloc] init];
			NSBezierPath *line1Path   = [[NSBezierPath alloc] init];
			NSBezierPath *line2Path   = [[NSBezierPath alloc] init];

			[line1Path appendBezierPath: _line1Path];
			[line2Path appendBezierPath: _line2Path];

			//-------------------------------------------.
			// Alineamos y centramos el texto a la vista |
			//-------------------------------------------'
			NSRect line1Bounds = line1Path.controlPointBounds;
			NSRect line2Bounds = line2Path.controlPointBounds;
			CGFloat linesY = center.y - (line1Bounds.size.height + line2Bounds.size.height + kLineSpacing) / 2.0;

			NSAffineTransform *transform = [[NSAffineTransform alloc] init];

			[transform
				translateXBy: -line1Bounds.origin.x + center.x - line1Bounds.size.width / 2.0
				yBy:	      -line1Bounds.origin.y + linesY + line2Bounds.size.height + kLineSpacing];

			[line1Path transformUsingAffineTransform: transform];
			[transform release];

			transform = [[NSAffineTransform alloc] init];

			[transform
				translateXBy: -line2Bounds.origin.x + center.x - line2Bounds.size.width / 2.0
				yBy:	      -line2Bounds.origin.y + linesY];

			[line2Path transformUsingAffineTransform: transform];
			[transform release];

			[messagePath appendBezierPath: line1Path];
			[messagePath appendBezierPath: line2Path];

			[line1Path release];
			[line2Path release];

			//------------------------------------------------------------------------.
			// Ajustamos la zona sensible a pulsación al recuadro de la caja de fondo |
			//------------------------------------------------------------------------'
			NSRect messageBounds = messagePath.controlPointBounds;

			_boxFrame = NSInsetRect(messageBounds, -kXPadding, -kYPadding);
			_boxFrame.origin.x = center.x - _boxFrame.size.width  / 2.0;
			_boxFrame.origin.y = center.y - _boxFrame.size.height / 2.0;

			size.width  -= kXPadding;
			size.height -= kYPadding;

			//----------------------------------------------------------.
			// Si la caja no cabe, la redimensionamos proporcionalmente |
			//----------------------------------------------------------'
			if (!SizeContains(size, _boxFrame.size))
				{
				//-------------------------------------------------------------------------.
				// Calculamos el tamaño necesario para que la caja quepa proporcionalmente |
				//-------------------------------------------------------------------------'
				NSSize reducedSize = SizeFit(_boxFrame.size, size);
				CGFloat sizeRatio = reducedSize.width / _boxFrame.size.width;

				//----------------------------------------------------------------------.
				// Reducimos el radio de las esquinas de la caja en la misma proporción |
				//----------------------------------------------------------------------'
				boxCornerRadius *= sizeRatio;

				//----------------------------------------------------------.
				// Ajustamos el frame de la caja tamaño que hemos calculado |
				//----------------------------------------------------------'
				_boxFrame.size = reducedSize;
				_boxFrame.origin.x = center.x - _boxFrame.size.width  / 2.0;
				_boxFrame.origin.y = center.y - _boxFrame.size.height / 2.0;

				transform = [[NSAffineTransform alloc] init];

				[transform translateXBy: center.x  yBy: center.y ];
				[transform scaleXBy:	 sizeRatio yBy: sizeRatio];
				[transform translateXBy: -center.x yBy: -center.y];

				[messagePath transformUsingAffineTransform: transform];
				[transform release];
				}

			_boxFrame = NSMakeRect
				(floor(_boxFrame.origin.x),  floor(_boxFrame.origin.y),
				 ceil (_boxFrame.size.width), ceil(_boxFrame.size.height));

			//--------------------------.
			// Creamos la caja de fondo |
			//--------------------------'
			NSBezierPath *box = [NSBezierPath
				bezierPathWithRoundedRect: _boxFrame
				xRadius:		   boxCornerRadius
				yRadius:		   boxCornerRadius];

			//----------------------------.
			// Dibujamos la caja de fondo |
			//----------------------------'
			box.lineWidth = 2.0;
			[[NSColor colorWithCalibratedWhite: 0.0 alpha: 0.875] setFill];
			[white setStroke];
			[box fill];
			[box strokeInside];
			[[NSColor colorWithCalibratedWhite: 0.0 alpha: 0.3] setStroke];
			box.lineWidth = 1.0;
			[box strokeOutside];

			//--------------------.
			// Dibujamos el texto |
			//--------------------'
			NSShadow *shadow = [[NSShadow alloc] init];

			[white setFill];
			[shadow setShadowOffset: NSMakeSize(0.0, -1.0)];
			[shadow setShadowBlurRadius: 2.0];
			[shadow setShadowColor: [NSColor blackColor]];
			[NSGraphicsContext saveGraphicsState];
			[shadow set];
			[messagePath fill];
			[NSGraphicsContext restoreGraphicsState];
			[shadow release];
			messagePath.lineWidth = 0.5;
			[messagePath strokeOutside];
			[messagePath release];
			}
		}


	- (void) mouseDown: (NSEvent *) event
		{
		if (NSPointInRect([self convertPoint: [event locationInWindow] fromView: nil], _boxFrame))
			_IsPressed = YES;
		}


	- (void) mouseUp: (NSEvent *) event
		{
		if (	_target		&&
			_IsPressed	&&
			NSPointInRect([self convertPoint: [event locationInWindow] fromView: nil], _boxFrame)
		)
			[_target performSelector: _action withObject: self];
		}


#	pragma mark - Public


	- (void) youLose
		{
		[_line1Path release];
		_line1Path = [[NSBezierPath bezierPathWithString: _("GameOver.YouLose") inFont: _line1Font] retain];
		[self setNeedsDisplay: YES];
		[self setHidden: NO];
		}


	- (void) youWin
		{
		[_line1Path release];
		_line1Path = [[NSBezierPath bezierPathWithString: _("GameOver.YouWin") inFont: _line1Font] retain];
		[self setNeedsDisplay: YES];
		[self setHidden: NO];
		}

@end

// EOF
