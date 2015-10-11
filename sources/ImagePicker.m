/* Mines - ImagePicker.m
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "ImagePicker.h"
#import "helpers.h"
#import "geometry.h"
#import "ImageStore.h"
#import <CommonCrypto/CommonDigest.h>


@interface ImageView : NSImageView {BOOL _isSelected;} @end


@implementation ImageView


	- (void) drawRect: (NSRect) frame
		{
		if (_isSelected)
			{
			[[NSColor selectedTextBackgroundColor] set];
			NSRectFill(frame);
			[super drawRect: frame];
			[NSBezierPath setDefaultLineWidth: 2.0];
			[[NSColor colorWithCalibratedRed: 0.1 green: 0.2 blue: 1.0 alpha: 0.35] set];
			[NSBezierPath strokeRect: NSInsetRect(frame, 1.0, 1.0)];
			}

		else [super drawRect: frame];
		}


	- (void) setSelected: (BOOL) flag
		{
		_isSelected = flag;
		self.needsDisplay = YES;
		}


@end


@implementation ImagePickerItem


	- (void) setSelected: (BOOL) flag
		{
		[super setSelected: flag];
		[((ImageView *)self.view) setSelected: flag];
		}


@end


@implementation ImagePicker


#	pragma mark - Listeners


	- (void) observeValueForKeyPath: (NSString     *) keyPath
		 ofObject:		 (id		) object
		 change:		 (NSDictionary *) change
		 context:		 (void	       *) context
		{
		NSIndexSet *indexes = collectionView.selectionIndexes;
		[OKButton setEnabled: !!indexes.count];
		[actionSegmentedControl setEnabled: indexes.firstIndex >= _bundleImageCount forSegment: 1];
		}


#	pragma mark - NSCollectionViewDelegate Protocol


	- (BOOL) collectionView:	(NSCollectionView *) collectionView
		 canDragItemsAtIndexes: (NSIndexSet	  *) indexes
		 withEvent:		(NSEvent	  *) event
		{
		return indexes.firstIndex >= _bundleImageCount;
		}


	- (BOOL) collectionView:      (NSCollectionView *) collectionView
		 writeItemsAtIndexes: (NSIndexSet	*) indexes
		 toPasteboard:	      (NSPasteboard	*) pasteboard
		{
		[pasteboard writeObjects: [NSArray arrayWithObject: STRING(@"%lu", (unsigned long)indexes.firstIndex)]];
		return YES;
		}


	- (BOOL) collectionView: (NSCollectionView	      *) collectionView
		 acceptDrop:	 (id <NSDraggingInfo>	       ) draggingInfo
		 index:		 (NSInteger		       ) index
		 dropOperation:	 (NSCollectionViewDropOperation) dropOperation
		{
		NSUInteger draggedIndex;

		if (	[draggingInfo draggingSource] == self->collectionView &&
			index >= _bundleImageCount			      &&
			index != (draggedIndex = [(NSString *)[draggingInfo.draggingPasteboard
				stringForType: NSPasteboardTypeString] integerValue])
		)
			{
			if (index > draggedIndex) index--;

			id object = [[_images objectAtIndex: draggedIndex] retain];

			[imagesController removeObjectAtArrangedObjectIndex: draggedIndex];
			[imagesController insertObject: object atArrangedObjectIndex: index];
			[object release];

			draggedIndex -= _bundleImageCount;
			object = [[_imageStore objectAtIndex: draggedIndex] retain];
			[_imageStore removeObjectAtIndex: draggedIndex];
			[_imageStore insertObject: object atIndex: index - _bundleImageCount];
			[object release];

			_imageStoreUnsaved = YES;
			return YES;
			}

		return NO;
		}


	- (NSDragOperation) collectionView: (NSCollectionView		   *) collectionView
			    validateDrop:   (id <NSDraggingInfo>	    ) draggingInfo
			    proposedIndex:  (NSInteger			   *) proposedDropIndex
			    dropOperation:  (NSCollectionViewDropOperation *) proposedDropOperation
		{
		if (*proposedDropOperation == NSCollectionViewDropOn)
			*proposedDropOperation = NSCollectionViewDropBefore;

		if (*proposedDropIndex < _bundleImageCount) *proposedDropIndex = _bundleImageCount;
		return NSDragOperationMove;
		}


#	pragma mark - Public


	- (id) initWithDelegate:      (id <ImagePickerDelegate>) delegate
	       preloadedImages:	      (NSDictionary	      *) images
	       selectedImageFileName: (NSString		      *) selectedImageFileName
		{
		if ((self = [super initWithWindowNibName: @"ImagePicker"]))
			{
			NSImage *image;
			NSSize maximumCellSize = MaximumCellSizeInCurrentDisplays();

			_delegate = delegate;
			_initialSelectedImageFileName = [selectedImageFileName retain];

			_bundleImageFileNames = [[NSMutableArray arrayWithContentsOfFile: [[NSBundle mainBundle]
				pathForResource: @"Included Textures" ofType: @"plist"]]
					retain];

			_images = [[NSMutableArray alloc] init];
			_selectedIndex = NSNotFound;
			_bundleImageCount = 0;

			for (NSString *name in _bundleImageFileNames)
				{
				if ((image = [images objectForKey: name]))
					{
					if (_selectedIndex == NSNotFound && [name isEqualToString: selectedImageFileName])
						_selectedIndex = _bundleImageCount;
					}

				else image = [NSImage imageNamed: name];

				[_images addObject: image];
				_bundleImageCount++;
				}

			NSError*  error = nil;
			NSString* userImagesPath;

			if (	(_imageStore = ImageStoreLoad(&error)) &&
				(userImagesPath = BundleSupportSubdirectory(@"Custom Images", NO, NULL))
			)
				{
				NSString*  fileName;
				NSString*  MD5Key    = @"MD5";
				NSString*  formatKey = @"Format";
				NSUInteger index     = _bundleImageCount;

				for (NSDictionary *entry in _imageStore)
					{
					if ((image = [images objectForKey: fileName = [(NSString *)[entry objectForKey: MD5Key]
						stringByAppendingPathExtension: [entry objectForKey: formatKey]]]
					))
						{
						if (_selectedIndex == NSNotFound && [fileName isEqualToString: selectedImageFileName])
							_selectedIndex = index;

						[_images addObject: image];
						}

					else	{
						image = [[NSImage alloc] initWithContentsOfFile:
							[userImagesPath stringByAppendingPathComponent: fileName]];

						image.size = SizeFit(image.size, maximumCellSize);
						[_images addObject: image];
						[image release];
						}

					index++;
					}
				}

			else	{
				_imageStore = [[NSMutableArray alloc] init];
				if (error) [[NSAlert alertWithError: error] runModal];
				}
			}

		return self;
		}


	- (void) dealloc
		{
		[collectionView removeObserver: self forKeyPath: @"selectionIndexes"];

		[_images		       release];
		[_bundleImageFileNames	       release];
		[_imageStore		       release];
		[_initialSelectedImageFileName release];
		[super			       dealloc];
		}


	- (void) windowDidLoad
		{
		[super windowDidLoad];

		[collectionView
			addObserver: self
			forKeyPath:  @"selectionIndexes"
			options:     0
			context:     nil];

		[collectionView setSelectionIndexes: _selectedIndex != NSNotFound
			? [NSIndexSet indexSetWithIndex: _selectedIndex]
			: [NSIndexSet indexSet]];

		[collectionView setValue:			[NSNumber numberWithUnsignedInteger: 0] forKey: @"_animationDuration"];
		[collectionView registerForDraggedTypes:	[NSArray arrayWithObject: NSStringPboardType]];
		[collectionView setDraggingSourceOperationMask: NSDragOperationMove forLocal: YES];
		}


	- (void) runModalForWindow: (NSWindow *) window
		{
		[NSApp	beginSheet:	self.window
			modalForWindow: window
			modalDelegate:	nil
			didEndSelector:	nil
			contextInfo:	NULL];
		}


	- (IBAction) cancel: (id) sender
		{
		if (![cancelButton isEnabled]) NSBeep();
		
		else	{
			NSWindow *window = [self window];
			NSError *error;

			if (_imageStoreUnsaved && !ImageStoreSave(_imageStore, &error))
				[[NSAlert alertWithError: error] runModal];

			[window orderOut: self];
			[NSApp endSheet: window];
			[_delegate imagePickerDidEndWithResult: NO resultData: nil];
			}
		}


	- (IBAction) OK: (id) sender
		{
		NSWindow *window = [self window];
		NSUInteger selectedIndex = collectionView.selectionIndexes.firstIndex;
		NSError *error;
		ImagePickerResultData resultData;

		if (_imageStoreUnsaved && !ImageStoreSave(_imageStore, &error))
			[[NSAlert alertWithError: error] runModal];

		resultData.image = [_images objectAtIndex: selectedIndex];

		if (selectedIndex < _bundleImageCount)
			{
			resultData.fileName = [_bundleImageFileNames objectAtIndex: selectedIndex];
			resultData.isInternal = YES;
			}

		else	{
			NSDictionary *entry = [_imageStore objectAtIndex: selectedIndex - _bundleImageCount];

			resultData.fileName = [(NSString *)[entry objectForKey: @"MD5"]
				stringByAppendingPathExtension: [entry objectForKey: @"Format"]];

			resultData.isInternal = NO;
			}

		[window orderOut: self];
		[NSApp endSheet: window];
		[_delegate imagePickerDidEndWithResult: YES resultData: &resultData];
		}


	- (IBAction) itemAction: (NSSegmentedControl *) sender
		{
		NSError *error = nil;

		if (sender.selectedSegment)
			{
			NSUInteger index = collectionView.selectionIndexes.firstIndex;
			NSUInteger imageStoreIndex = index - _bundleImageCount;
			NSString *imageFileName = ImageStoreFileNameAtIndex(_imageStore, imageStoreIndex);

			if (ImageStoreRemoveImage(_imageStore, imageStoreIndex, &error))
				{
				[imagesController removeObjectAtArrangedObjectIndex: index];

				if ([imageFileName isEqualTo: _initialSelectedImageFileName])
					[cancelButton setEnabled: NO];

				[_delegate
					imagePickerDidRemoveUserImageNamed: imageFileName
					replaceWithBundleImages:	    _images
					named:				    _bundleImageFileNames];
				}
			}

		else	{
			NSOpenPanel *panel = [NSOpenPanel openPanel];

			panel.allowedFileTypes = [NSImage imageFileTypes];

			if ([panel runModal] == NSFileHandlingPanelOKButton)
				{
				NSImage *image;

				if (ImageStoreKeepImage(_imageStore, panel.URL.path, &image, &error))
					[imagesController addObject: image];
				}
			}

		if (error) [[NSAlert alertWithError: error] runModal];
		}


@end

// EOF
