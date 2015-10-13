/* Betty Lab's Cocoa Extensions - NSBezierPath+BL.m
   ____        ___  ___		  ____	      ___ 
  /  _ ) ____ /  /_/  /_ __ __	 /   / _____ /	/
 /  _  \/  -_)	__/  __/  /  /	/   /_/  _ //  _ \
/______/\___/\__/ \__/ \__  /  /_____/\__,_/_____/
© 2011-2015 Betty Lab. /___/
Released under the terms of the GNU Lesser General Public License v3. */

#import "NSBezierPath+BL.m"


@implementation NSBezierPath (BL)


	+ (NSBezierPath *) bezierPathWithString: (NSString *) string
			   inFont:		 (NSFont   *) font
		{
		NSBezierPath *path = [self bezierPath];
		[path appendBezierPathWithString: string inFont: font];
		return path;
		}


	- (void) appendBezierPathWithString: (NSString *) string
		 inFont:		     (NSFont   *) font
		{
		if ([self isEmpty]) [self moveToPoint: NSZeroPoint];

		NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, nil];
		NSTextStorage *storage	 = [[NSTextStorage alloc] initWithString: string attributes: attributes];

		[attributes release];

		NSLayoutManager *manager   = [[NSLayoutManager alloc] init];
		NSTextContainer *container = [[NSTextContainer alloc] init];

		[storage addLayoutManager: manager];
		[manager addTextContainer: container];

		NSRange glyphRange = [manager glyphRangeForTextContainer: container];
		NSGlyph glyphArray[glyphRange.length];
		NSUInteger glyphCount = [manager getGlyphs: glyphArray range: glyphRange];

		[manager getGlyphs: glyphArray range: glyphRange];

		[self appendBezierPathWithGlyphs: glyphArray count: glyphCount inFont: font];
		[container release];
		[manager release];
		[storage release];
		}


	- (void) drawInnerShadow: (NSShadow *) shadow
		{
		CGFloat radius	      = shadow.shadowBlurRadius;
		NSSize offset	      = shadow.shadowOffset;
		NSSize originalOffset = offset;
		NSRect bounds	      = NSInsetRect(self.bounds, -(ABS(offset.width) + radius), -(ABS(offset.height) + radius));

		offset.height += bounds.size.height;
		shadow.shadowOffset = offset;

		NSAffineTransform* transform = [[NSAffineTransform alloc] init];

		if ([[NSGraphicsContext currentContext] isFlipped])
			[transform translateXBy: 0 yBy: bounds.size.height];

		else [transform translateXBy: 0 yBy: -bounds.size.height];

		NSBezierPath *drawingPath = [NSBezierPath bezierPathWithRect: bounds];
		[drawingPath setWindingRule: NSEvenOddWindingRule];
		[drawingPath appendBezierPath: self];
		[drawingPath transformUsingAffineTransform: transform];
		[transform release];

		[NSGraphicsContext saveGraphicsState];
			[self addClip];
			[shadow set];
			[[NSColor blackColor] set];
			[drawingPath fill];
		[NSGraphicsContext restoreGraphicsState];

		shadow.shadowOffset = originalOffset;
		}


	- (void) strokeInside
		{
		CGFloat lineWidth = self.lineWidth;

		[NSGraphicsContext saveGraphicsState];
			self.lineWidth = lineWidth * 2.0;
			[self setClip];
			[self stroke];
		[NSGraphicsContext restoreGraphicsState];

		self.lineWidth = lineWidth;
		}


	- (void) strokeOutside
		{
		CGFloat lineWidth = self.lineWidth;

		NSBezierPath *clip = [NSBezierPath bezierPathWithRect:
			NSInsetRect(self.bounds, -lineWidth * 2.0, -lineWidth * 2.0)];

		[clip setWindingRule: NSEvenOddWindingRule];
		[clip appendBezierPath: self];

		[NSGraphicsContext saveGraphicsState];
			self.lineWidth = lineWidth * 2.0;
			[clip setClip];
			[self stroke];
		[NSGraphicsContext restoreGraphicsState];

		self.lineWidth = lineWidth;
		}


@end

// EOF
