/* Mines - SeparatorCell.m
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "SeparatorCell.h"


@implementation SeparatorCell


	- (void) drawWithFrame: (NSRect	 ) cellFrame
		 inView:	(NSView *) controlView
		{
		[[NSColor lightGrayColor] setFill];

		NSRectFill(NSMakeRect
			(cellFrame.origin.x + 2.0,
			 cellFrame.origin.y + cellFrame.size.height / 2.0 + 0.5,
			 cellFrame.size.width -= 4.0, 1.0));
		}


@end

// EOF
