// CocoPlus - NSString+CocoPlus.m
//   ___	       , __
//  / (_)	      /|/  \ |\
// |	  __   __  __  |___/ | |	__
// |	 / (\_/   / (\_|     |/  |  |  / _\_
//  \___/\__/ \__/\__/ | ___/|__/|_/|_/  \/
// Copyright © 2013 Manuel Sainz de Baranda y Goñi.
// Released under the terms of the GNU Lesser General Public License v3.

#import "NSString+CocoPlus.h"

#define VFS_BAD_CHARACTER_SET [NSCharacterSet characterSetWithCharactersInString: @"/\\?:%*|\"<>"]


@implementation NSString (CocoPlus)


	- (NSString *) VFSSafeString
		{
		return [[self componentsSeparatedByCharactersInSet: VFS_BAD_CHARACTER_SET]
			componentsJoinedByString: @""];
		}


@end

// EOF
