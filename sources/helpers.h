/* Mines - helpers.h
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Betty Lab.
Released under the terms of the GNU General Public License v3. */

#import "Board.h"

void	  FatalBundleCorruption		   (void);

NSError*  Error				   (NSString* title,
					    NSString* body);

NSError*  ErrorForFile			   (NSString* body,
					    NSString* filePath);

NSError*  ErrorForBadImageFormatInFile	   (NSString* filePath);

NSString* BundleSupportDirectory	   (BOOL      create,
					    NSError** error);

NSString* BundleSupportSubdirectory	   (NSString* subdirectoryPath,
					    BOOL      create,
					    NSError** error);

NSString* SafeNameForFileInDirectory	   (NSString* fileName,
					    NSString* directoryPath);

NSSize	  MaximumCellSizeInCurrentDisplays (void);

// EOF
