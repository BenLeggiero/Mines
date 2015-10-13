/* Betty Lab's Cocoa Extensions - NSWindow+BL.m
   ____        ___  ___		  ____	      ___ 
  /  _ ) ____ /  /_/  /_ __ __	 /   / _____ /	/
 /  _  \/  -_)	__/  __/  /  /	/   /_/  _ //  _ \
/______/\___/\__/ \__/ \__  /  /_____/\__,_/_____/
© 2011-2015 Betty Lab. /___/
Released under the terms of the GNU Lesser General Public License v3. */

#import "NSWindow+BL.h"


@implementation NSWindow (BL)


	- (CGFloat) toolbarHeight
		{
		NSToolbar *toolbar = self.toolbar;

		return toolbar && [toolbar isVisible]
			? [NSWindow contentRectForFrameRect: self.frame styleMask: self.styleMask].size.height -
			  ((NSView *)self.contentView).frame.size.height
			: 0.0;
		}


	- (void) replaceContentViewWithView: (NSView *) view
		 animate:		     (BOOL    ) animate
		{
		if (view != self.contentView)
			{
			NSRect frame = self.frame;;
			NSRect contentFrame = ((NSView *)self.contentView).frame;
			NSRect viewFrame = view.frame;

			viewFrame.origin.y = 0.0;
			view.frame = viewFrame;
			[self setContentView: view];

			frame.origin.y = frame.origin.y + contentFrame.size.height - viewFrame.size.height;
			frame.size = viewFrame.size;

			[self setContentView: view];

			[self	setFrame: [self frameRectForContentRect: frame]
				display:  YES
				animate:  self.isVisible ? animate : NO];
			}
		}


	- (void) animateIntoScreenFrame: (NSRect) screenFrame
		 fromTopCenterToSize:	 (NSSize) size
		{
		NSRect oldFrame = self.frame;

		NSRect newFrame = NSMakeRect
			(oldFrame.origin.x + oldFrame.size.width / 2.0 - size.width / 2.0,
			 oldFrame.origin.y + oldFrame.size.height      - size.height,
			 size.width, size.height);

		if (!NSContainsRect(screenFrame, newFrame))
			{
			if (newFrame.origin.x < screenFrame.origin.x)
				newFrame.origin.x = screenFrame.origin.x;

			else if (NSMaxX(newFrame) > NSMaxX(screenFrame))
				newFrame.origin.x = screenFrame.origin.x + screenFrame.size.width - size.width;

			if (newFrame.origin.y < screenFrame.origin.y)
				newFrame.origin.y = screenFrame.origin.y;

			else if (NSMaxY(newFrame) > NSMaxY(screenFrame))
				newFrame.origin.y = screenFrame.origin.y + screenFrame.size.height - size.height;
			}

		BOOL visible = self.isVisible;
		[self setFrame: newFrame display: visible animate: visible];
		}


	- (NSPoint) convertPointToScreen: (NSPoint) point
		{
		return [self respondsToSelector: @selector(convertRectToScreen:)]
			? [self convertRectToScreen: NSMakeRect(point.x, point.y, 0.0, 0.0)].origin
			: [self convertBaseToScreen: point];
		}


@end

// EOF
