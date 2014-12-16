// CocoPlus - NSColor+CocoPlus.m
//   ___	       , __
//  / (_)	      /|/  \ |\
// |	  __   __  __  |___/ | |	__
// |	 / (\_/   / (\_|     |/  |  |  / _\_
//  \___/\__/ \__/\__/ | ___/|__/|_/|_/  \/
// Copyright © 2013 Manuel Sainz de Baranda y Goñi.
// Released under the terms of the GNU Lesser General Public License v3.

#import "NSColor+CocoPlus.h"


@implementation NSColor (CocoPlus)


	+ (NSColor *) colorFromFloatString: (NSString *) string
		{
		if (string && [string isKindOfClass: [NSString class]])
			{
			NSArray *channels = [string componentsSeparatedByString: @":"];

			CGFloat components[4] = {
				[[channels objectAtIndex: 0] doubleValue],
				[[channels objectAtIndex: 1] doubleValue],
				[[channels objectAtIndex: 2] doubleValue],
				[channels count] == 3 ? 1.0 : [[channels objectAtIndex: 3] doubleValue]
			};

			return [NSColor
				colorWithColorSpace: [NSColorSpace genericRGBColorSpace]
				components:	     components
				count:		     4];
			}

		return nil;
		}


	- (NSString *) floatRGBString
		{
		return [NSString stringWithFormat:
			@"%f:%f:%f",
			[self redComponent],
			[self greenComponent],
			[self blueComponent]];
		}


	- (NSString *) floatRGBAString
		{
		return [NSString stringWithFormat:
			@"%f:%f:%f:%f",
			[self redComponent],
			[self greenComponent],
			[self blueComponent],
			[self alphaComponent]];
		}


	- (NSColor *) opaqueGenericRGBColor
		{
		NSColorSpace *colorSpace = [NSColorSpace genericRGBColorSpace];
		CGFloat components[4];

		[[self colorUsingColorSpace: colorSpace]
			getRed: &components[0]
			green:	&components[1]
			blue:	&components[2]
			alpha:	&components[3]];

		return [NSColor colorWithColorSpace: colorSpace components: components count: 4];
		}


@end

// EOF
