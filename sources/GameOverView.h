/* Mines - GameOverView.h
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>

@interface GameOverView : NSView {
	NSFont*       _line1Font;
	NSBezierPath* _line1Path;
	NSBezierPath* _line2Path;
	id	      _target;
	SEL	      _action;
	NSRect	      _boxFrame;
	BOOL	      _IsPressed;
}
	@property (nonatomic, assign) id  target;
	@property (nonatomic, assign) SEL action;

	- (void) youLose;
	- (void) youWin;
@end

// EOF
