/* Betty Lab's Cocoa Extensions - NSImage+BL.m
   ____        ___  ___		  ____	      ___ 
  /  _ ) ____ /  /_/  /_ __ __	 /   / _____ /	/
 /  _  \/  -_)	__/  __/  /  /	/   /_/  _ //  _ \
/______/\___/\__/ \__/ \__  /  /_____/\__,_/_____/
© 2011-2015 Betty Lab. /___/
Released under the terms of the GNU Lesser General Public License v3. */

#import "NSImage+BL.h"


@implementation NSImage (BL)


	+ (NSImage *) imageFromFile: (NSString *) filePath
		      error:	     (NSError **) error
		{
		NSError *e;
		NSData *data = [NSData dataWithContentsOfFile: filePath options: 0 error: &e];

		if (data) return [[[NSImage alloc] initWithData: data] autorelease];
		if (error != NULL) *error = e;
		return nil;
		}


@end

// EOF
