/* Mines - ImagePicker.h
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Betty Lab.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>

typedef struct {
	NSImage*  image;
	NSString* fileName;
	BOOL	  isInternal;
} ImagePickerResultData;

@interface ImagePickerItem : NSCollectionViewItem @end

@protocol ImagePickerDelegate

	- (void) imagePickerDidEndWithResult: (BOOL		      ) result
		 resultData:		      (ImagePickerResultData *) resultData;

	- (void) imagePickerDidRemoveUserImageNamed: (NSString *) imageName
		 replaceWithBundleImages:	     (NSArray  *) bundleImages
		 named:				     (NSArray  *) bundleImageFileNames;

@end

@interface ImagePicker : NSWindowController <NSCollectionViewDelegate> {
	IBOutlet NSCollectionView*   collectionView;
	IBOutlet NSButton*	     OKButton;
	IBOutlet NSButton*	     cancelButton;
	IBOutlet NSSegmentedControl* actionSegmentedControl;
	IBOutlet NSArrayController*  imagesController;

	id <ImagePickerDelegate> _delegate;
	NSString*		 _initialSelectedImageFileName;
	NSMutableArray*		 _images;
	NSMutableArray*		 _bundleImageFileNames;
	NSMutableArray*		 _imageStore;
	NSUInteger		 _bundleImageCount;
	NSUInteger		 _selectedIndex;
	BOOL			 _imageStoreUnsaved;
}
	- (id) initWithDelegate:      (id <ImagePickerDelegate>) delegate
	       preloadedImages:	      (NSDictionary	      *) images
	       selectedImageFileName: (NSString		      *) selectedImageFileName;

	- (void) runModalForWindow: (NSWindow *) window;

	- (IBAction) cancel:	 (id) sender;
	- (IBAction) OK:	 (id) sender;
	- (IBAction) itemAction: (id) sender;
@end

// EOF
