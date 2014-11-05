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
		NSColor *color = nil;

		if (string && [string isKindOfClass: [NSString class]])
			{
			NSArray *channels = [string componentsSeparatedByString: @":"];

			if ([channels count] == 3) color = [NSColor
				colorWithCalibratedRed: [[channels objectAtIndex: 0] floatValue]
				green:			[[channels objectAtIndex: 1] floatValue]
				blue:			[[channels objectAtIndex: 2] floatValue]
				alpha:			1.0];

			else if ([channels count] == 4) color = [NSColor
				colorWithCalibratedRed: [[channels objectAtIndex: 0] floatValue]
				green:			[[channels objectAtIndex: 1] floatValue]
				blue:			[[channels objectAtIndex: 2] floatValue]
				alpha:			[[channels objectAtIndex: 3] floatValue]];
			}

		return color;
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
		CGFloat red, green, blue, alpha;

		[[self colorUsingColorSpaceName: NSCalibratedRGBColorSpace]
			getRed: &red green: &green blue: &blue alpha: &alpha];

		return [NSColor colorWithCalibratedRed: red green: green blue: blue alpha: 1.0];
		}


@end

// EOF
