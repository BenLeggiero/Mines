// CocoPlus - NSBezierPath+CocoPlus.h
//   ___	       , __
//  / (_)	      /|/  \ |\
// |	  __   __  __  |___/ | |	__
// |	 / (\_/   / (\_|     |/  |  |  / _\_
//  \___/\__/ \__/\__/ | ___/|__/|_/|_/  \/
// Copyright © 2013 Manuel Sainz de Baranda y Goñi.
// Released under the terms of the GNU Lesser General Public License v3.

#import <AppKit/AppKit.h>

@interface NSBezierPath (CocoPlus)

	+ (NSBezierPath *) bezierPathWithString: (NSString *) text
			   inFont:		 (NSFont   *) font;

	- (void) appendBezierPathWithString: (NSString *) text
		 inFont:		     (NSFont   *) font;

	- (void) drawInnerShadow: (NSShadow *) shadow;

	- (void) strokeInside;

	- (void) strokeOutside;

@end

// EOF
