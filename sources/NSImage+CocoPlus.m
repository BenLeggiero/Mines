// CocoPlus - NSImage+CocoPlus.m
//   ___	       , __
//  / (_)	      /|/  \ |\
// |	  __   __  __  |___/ | |	__
// |	 / (\_/   / (\_|     |/  |  |  / _\_
//  \___/\__/ \__/\__/ | ___/|__/|_/|_/  \/
// Copyright © 2013 Manuel Sainz de Baranda y Goñi.
// Released under the terms of the GNU Lesser General Public License v3.

#import "NSImage+CocoPlus.h"


@implementation NSImage (CocoPlus)


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
