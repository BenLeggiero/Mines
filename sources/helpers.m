/* Mines - helpers.m
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "helpers.h"
#import "NSColor+CocoPlus.h"
#import "NSImage+CocoPlus.h"
#import "geometry.h"
#import "helpers.h"
#import "constants.h"
#import "NSWindow+CocoPlus.h"


void FatalBundleCorruption(void)
	{
	[[NSAlert alertWithError:
		Error(_("Error.FatalBundleCorruption.Title"), _("Error.FatalBundleCorruption.Body"))]
			runModal];
	exit(1);
	}


NSError *Error(NSString *title, NSString *body)
	{
	return [NSError
		errorWithDomain: @"MinesError"
		code:		 0
		userInfo:	 [NSDictionary dictionaryWithObjectsAndKeys:
			title, NSLocalizedDescriptionKey,
			body,  NSLocalizedRecoverySuggestionErrorKey,
			nil]];
	}


NSError *ErrorForFile(NSString *body, NSString *filePath)
	{
	return [NSError
		errorWithDomain: @"MinesError"
		code:		 0
		userInfo:	 [NSDictionary dictionaryWithObjectsAndKeys:
			_("Error.File"),	NSLocalizedDescriptionKey,
			STRING(body, filePath), NSLocalizedRecoverySuggestionErrorKey,
			nil]];
	}


NSError *ErrorForBadImageFormatInFile(NSString *filePath)
	{
	return [NSError
		errorWithDomain: @"MinesError"
		code:		 0
		userInfo:	 [NSDictionary dictionaryWithObjectsAndKeys:
			_("Error.BadImageFile.Title"),			NSLocalizedDescriptionKey,
			STRING(_("Error.BadImageFile.Body"), filePath), NSLocalizedRecoverySuggestionErrorKey,
			nil]];
	}


static NSString *SupportDirectory(NSString *subpath, BOOL create, NSError **error)
	{
	NSFileManager *fileManager = [NSFileManager defaultManager];

	NSURL *URL = [fileManager
		URLForDirectory:   NSApplicationSupportDirectory
		inDomain:	   NSUserDomainMask
		appropriateForURL: nil
		create:		   create
		error:		   create ? error : NULL];

	if (!URL) return nil;

	NSString *path = [URL.path stringByAppendingPathComponent: subpath];
	BOOL isDirectory;

	if ([fileManager fileExistsAtPath: path isDirectory: &isDirectory])
		{
		if (isDirectory) return path;
		if (!create || ![fileManager removeItemAtPath: path error: error]) return nil;
		}

	return create
		? ([fileManager
			createDirectoryAtPath:	     path
			withIntermediateDirectories: YES
			attributes:		     nil
			error:			     error]
				? path : nil)
		: nil;
	}


NSString *BundleSupportDirectory(BOOL create, NSError **error)
	{return SupportDirectory([[NSBundle mainBundle] bundleIdentifier], create, error);}


NSString *BundleSupportSubdirectory(NSString* subdirectoryPath, BOOL create, NSError **error)
	{
	return SupportDirectory
		([[[NSBundle mainBundle] bundleIdentifier] stringByAppendingPathComponent: subdirectoryPath],
		 create, error);
	}


NSString *SafeNameForFileInDirectory(NSString *fileName, NSString *directoryPath)
	{
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if (![fileManager fileExistsAtPath: [directoryPath stringByAppendingPathComponent: fileName]])
		return fileName;

	NSUInteger c = 0;
	NSString *result = nil, *path = nil;
	NSString *extension = [fileName pathExtension];

	fileName = [fileName stringByDeletingPathExtension];

	do	{
		[path	release];
		[result release];
		result = [[NSString alloc] initWithFormat: @"%@ (%lu).%@", fileName, (unsigned long)++c, extension];
		path   = [[NSString alloc] initWithFormat: @"%@/%@", directoryPath, result];
		}
	while ([fileManager fileExistsAtPath: path]);

	[path release];
	return [result autorelease];
	}


NSSize MaximumCellSizeInCurrentDisplays(void)
	{
	NSSize screenSpace;
	CGFloat size, cellSize = 0.0;

	for (NSScreen *screen in [NSScreen screens])
		{
		screenSpace = [screen respondsToSelector: @selector(backingScaleFactor)]
			? SizeMultiplyByScalar(screen.visibleFrame.size, [screen backingScaleFactor])
			: screen.visibleFrame.size;

		size = MIN(screenSpace.width / kGameMinimumWidth, screenSpace.height / kGameMinimumHeight);
		if (size > cellSize) cellSize = size;
		}

	return NSMakeSize(cellSize, cellSize);
	}


// EOF
