// CocoPlus - NSImage+CocoPlus.h
//   ___	       , __
//  / (_)	      /|/  \ |\
// |	  __   __  __  |___/ | |	__
// |	 / (\_/   / (\_|     |/  |  |  / _\_
//  \___/\__/ \__/\__/ | ___/|__/|_/|_/  \/
// Copyright © 2013 Manuel Sainz de Baranda y Goñi.
// Released under the terms of the GNU Lesser General Public License v3.

#import <AppKit/AppKit.h>

@interface NSImage (CocoPlus)

	+ (NSImage *) imageFromFile: (NSString *) filePath
		      error:	     (NSError **) error;

@end

// EOF
