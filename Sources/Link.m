/* Link.m
	      __	   __
  _______ ___/ /______ ___/ /__
 / __/ -_) _  / __/ _ \ _  / -_)
/_/  \__/\_,_/\__/\___/_,_/\__/
Copyright © 2014 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU Lesser General Public License v3. */

#import "Link.h"


@implementation Link


	- (void) setStringValue: (NSString *) string
		{
		[super setStringValue: string];
		[self updateTrackingAreas];
		}


	- (void) updateTrackingAreas
		{
		NSArray *areas = self.trackingAreas;

		if (areas.count) [self removeTrackingArea: [areas objectAtIndex: 0]];

		NSTrackingArea *area = [[NSTrackingArea alloc]
			initWithRect: self.bounds
			options:      NSTrackingActiveAlways | NSTrackingInVisibleRect | NSTrackingMouseEnteredAndExited
			owner:	      self
			userInfo:     nil];

		[self addTrackingArea: area];
		[area release];
		}


	- (void) resetCursorRects
		{
		[self discardCursorRects];
		[self addCursorRect: self.bounds cursor: [NSCursor pointingHandCursor]];
		}


	- (void) mouseEntered: (NSEvent *) event
		{
		NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
			initWithAttributedString: self.attributedStringValue];

		[string	addAttribute: NSUnderlineStyleAttributeName
			value:	      [NSNumber numberWithUnsignedInteger: 1]
			range:	      NSMakeRange(0, string.length)];

		self.attributedStringValue = string;
		[string release];
		}


	- (void) mouseExited: (NSEvent *) event
		{
		NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
			initWithAttributedString: self.attributedStringValue];

		[string	removeAttribute: NSUnderlineStyleAttributeName range: NSMakeRange(0, string.length)];
		self.attributedStringValue = string;
		[string release];
		}


	- (void) mouseUp: (NSEvent *) event
		{
		if (NSPointInRect([self convertPoint: event.locationInWindow fromView: nil], self.bounds))
			[super.target performSelector: super.action withObject: self];
		}


@end

// EOF
