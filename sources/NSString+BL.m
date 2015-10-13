/* Betty Lab's Foundation Extensions - NSString+BL.m
   ____        ___  ___		  ____	      ___ 
  /  _ ) ____ /  /_/  /_ __ __	 /   / _____ /	/
 /  _  \/  -_)	__/  __/  /  /	/   /_/  _ //  _ \
/______/\___/\__/ \__/ \__  /  /_____/\__,_/_____/
© 2011-2015 Betty Lab. /___/
Released under the terms of the GNU Lesser General Public License v3. */

#import "NSString+BL.h"

#define VFS_BAD_CHARACTER_SET [NSCharacterSet characterSetWithCharactersInString: @"/\\?:%*|\"<>"]


@implementation NSString (BL)


	- (NSString *) VFSSafeString
		{
		return [[self componentsSeparatedByCharactersInSet: VFS_BAD_CHARACTER_SET]
			componentsJoinedByString: @""];
		}


@end

// EOF
