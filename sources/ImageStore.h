/* Mines - ImageStore.h
 __  __
|  \/  | __  ____  ___	___
|      |(__)|    |/ -_)/_  \
|__\/__||__||__|_|\___/ /__/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Foundation/Foundation.h>

NSMutableArray* ImageStoreLoad		  (NSError**       error);

BOOL		ImageStoreSave		  (NSMutableArray* imageStore,
					   NSError**       error);

BOOL		ImageStoreKeepImage	  (NSMutableArray* imageStore,
					   NSString*       path,
					   NSImage**       loadedImage,
					   NSError**       error);

BOOL		ImageStoreRemoveImage	  (NSMutableArray* imageStore,
					   NSUInteger      index,
					   NSError**       error);

NSString*	ImageStoreFileNameAtIndex (NSMutableArray* imageStore,
					   NSUInteger	   index);

// EOF
