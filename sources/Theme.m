/* Mines - Theme.m
 __  __
|  \/  | __  ____  ___	___
|      |(__)|    |/ -_)/_  \
|__\/__||__||__|_|\___/ /__/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "Theme.h"
#import "NSColor+CocoPlus.h"
#import "NSImage+CocoPlus.h"
#import "NSString+CocoPlus.h"
#import "helpers.h"
#import "geometry.h"


@implementation Theme


#	pragma mark - Accessors

	@synthesize owner		= _owner;
	@synthesize name		= _name;
	@synthesize imageFileNames	= _imageFileNames;

	- (BOOL	     ) flat		   {return _flat;}
	- (CGFloat   ) cellBrightnessDelta {return _cellBrightnessDelta;}
	- (CGFloat   ) fontScaling	   {return _fontScaling;}
	- (NSString *) fontName		   {return _fontName;}
	- (BOOL	    *) imageInclusions	   {return _imageInclusions;}


	- (void) setFlat: (BOOL) flat
		{
		_flat = flat;
		if (_owner) [_owner updateAlternateColors];
		}


	- (void) setCellBrightnessDelta: (CGFloat) delta
		{
		_cellBrightnessDelta = delta;
		if (_owner) [_owner updateAlternateColors];
		}


	- (void) setFontScaling: (CGFloat) scaling
		{
		_fontScaling = scaling;
		if (_owner) [_owner updateNumbers];
		}


	- (void) setFontName: (NSString *) name
		{
		[_fontName release];
		_fontName = [name retain];
		if (_owner) [_owner updateNumbers];
		}


#	pragma mark - Overwritten


	- (void) dealloc
		{
		[_cellColors	 release];
		[_numberColors	 release];
		[_imageColors	 release];
		[_imageFileNames release];
		[super dealloc];
		}


#	pragma mark - Public


	+ (NSArray *) internalDictionaries
		{
		return [NSArray arrayWithContentsOfFile:
			[[NSBundle mainBundle] pathForResource: @"Themes" ofType: @"plist"]];
		}


	+ (BOOL) validateDictionary: (NSDictionary *) dictionary
		{
		Class stringClass     = [NSString     class];
		Class arrayClass      = [NSArray      class];
		Class numberClass     = [NSNumber     class];
		Class dictionaryClass = [NSDictionary class];
		id value;
		NSArray *cellColors, *numberColors, *images;

		if (	![dictionary isKindOfClass: dictionaryClass]		     ||
			!(value = [dictionary objectForKey: @"Name"])		     ||
			![value isKindOfClass: stringClass]			     ||
			!(cellColors = [dictionary objectForKey: @"CellColors"])     ||
			![cellColors isKindOfClass: arrayClass]			     ||
			cellColors.count != 6					     ||
			!(numberColors = [dictionary objectForKey: @"NumberColors"]) ||
			![numberColors isKindOfClass: arrayClass]		     ||
			numberColors.count != 8					     ||
			!(value = [dictionary objectForKey: @"NumberFontScaling"])   ||
			![value isKindOfClass: numberClass]			     ||
			!(images = [dictionary objectForKey: @"Images"])	     ||
			![images isKindOfClass: arrayClass]			     ||
			images.count != 3					     ||
			((value = [dictionary objectForKey: @"NumberFontName"]) &&
			 ![value isKindOfClass: stringClass])			     ||
			((value = [dictionary objectForKey: @"Flat"]) &&
			 ![value isKindOfClass: numberClass])
		)
			return NO;

		for (id item in cellColors)
			if (![item isKindOfClass: stringClass]) return NO;

		for (id item in numberColors)
			if (![item isKindOfClass: stringClass]) return NO;

		for (NSDictionary *item in images) if (
			![item isKindOfClass: dictionaryClass]	    ||
			!(value = [item objectForKey: @"Included"]) ||
			![value isKindOfClass: numberClass]	    ||
			!(value = [item objectForKey: @"FileName"]) ||
			![value isKindOfClass: stringClass]	    ||
			((value = [item objectForKey: @"Color"]) && ![value isKindOfClass: stringClass])
		)
			return NO;

		return YES;
		}


	- (id) initWithDictionary: (NSDictionary *) dictionary
		{
		if ((self = [super init]))
			{
			NSUInteger index = 0;
			id value;

			_cellColors	= [[NSMutableArray alloc] init];
			_numberColors	= [[NSMutableArray alloc] init];
			_imageFileNames = [[NSMutableArray alloc] init];
			_imageColors    = [[NSMutableArray alloc] init];
			_name		= [[dictionary objectForKey: @"Name"] retain];

			for (NSDictionary *imageDictionary in [dictionary objectForKey: @"Images"])
				{
				_imageInclusions[index++] = [(NSNumber *)[imageDictionary objectForKey: @"Included"] boolValue];
				[_imageFileNames addObject: [imageDictionary objectForKey: @"FileName"]];

				[_imageColors addObject: (value = [NSColor sRGBColorFromFloatString: [imageDictionary objectForKey: @"Color"]])
					? value
					: [NSNull null]];
				}

			if ((value = [dictionary objectForKey: @"CellBrightnessDelta"]))
				_cellBrightnessDelta = [(NSNumber *)value doubleValue];

			if ((value = [dictionary objectForKey: @"Flat"]))
				_flat = [(NSNumber *)value boolValue];

			for (NSString *color in [dictionary objectForKey: @"CellColors"])
				[_cellColors addObject: [NSColor sRGBColorFromFloatString: color]];

			for (NSString *color in [dictionary objectForKey: @"NumberColors"])
				[_numberColors addObject: [NSColor sRGBColorFromFloatString: color]];

			_fontName = (
				(value = [dictionary objectForKey: @"NumberFontName"]) &&
				![value isEqualToString: @""]
			)
				? [value retain]
				: nil;

			if ((value = [dictionary objectForKey: @"NumberFontScaling"]))
				_fontScaling = [(NSNumber *)value doubleValue];
			}

		return self;
		}


	- (NSDictionary *) dictionary
		{
		NSNull*		     null	  = [NSNull null];
		NSMutableArray*	     cellColors	  = [[NSMutableArray alloc] init];
		NSMutableArray*	     numberColors = [[NSMutableArray alloc] init];
		NSMutableArray*	     images	  = [[NSMutableArray alloc] init];
		NSMutableDictionary* image;
		NSUInteger	     i;

		for (NSColor *color in _cellColors  ) [cellColors   addObject: [color floatRGBAString]];
		for (NSColor *color in _numberColors) [numberColors addObject: [color floatRGBAString]];

		for (i = 0; i < 3;)
			{
			image = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
				[NSNumber numberWithBool: _imageInclusions[i]], @"Included",
				[_imageFileNames objectAtIndex: i],		@"FileName",
				nil];

			NSColor *color = [_imageColors objectAtIndex: i++];

			if (![color isEqual: null])
				[image setObject: [color floatRGBAString] forKey: @"Color"];

			[images addObject: image];
			[image release];
			}

		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
			_name,					   @"Name",
			cellColors,				   @"CellColors",
			numberColors,				   @"NumberColors",
			[NSNumber numberWithDouble: _fontScaling], @"NumberFontScaling",
			(_fontName ? _fontName : @""),		   @"NumberFontName",
			images,					   @"Images",
			nil];

		[cellColors   release];
		[numberColors release];
		[images	      release];

		if (_cellBrightnessDelta != 0.0) [dictionary
			setObject: [NSNumber numberWithDouble: _cellBrightnessDelta]
			forKey:	   @"CellBrightnessDelta"];

		return [dictionary autorelease];
		}


	- (id) copyWithName: (NSString *) name
		{
		Theme *theme = [[Theme alloc] init];

		if (theme)
			{
			theme->_name		    = [name	 retain];
			theme->_fontName	    = [_fontName retain];
			theme->_flat		    = _flat;
			theme->_cellBrightnessDelta = _cellBrightnessDelta;
			theme->_fontScaling	    = _fontScaling;
			theme->_cellColors	    = [[NSMutableArray alloc] initWithArray: _cellColors];
			theme->_numberColors	    = [[NSMutableArray alloc] initWithArray: _numberColors];
			theme->_imageColors	    = [[NSMutableArray alloc] initWithArray: _imageColors];
			theme->_imageFileNames	    = [[NSMutableArray alloc] initWithArray: _imageFileNames];
			theme->_imageInclusions[0]  = _imageInclusions[0];
			theme->_imageInclusions[1]  = _imageInclusions[1];
			theme->_imageInclusions[2]  = _imageInclusions[2];
			}

		return theme;
		}


	- (NSColor  *) colorForKey: (NSUInteger) key
		{return [_cellColors objectAtIndex: key];}


	- (void) setColor: (NSColor  *) color
		 forKey:   (NSUInteger)	key
		{
		[_cellColors replaceObjectAtIndex: key withObject: color];
		if (_owner) [_owner updateColorWithKey: key];
		}


	- (NSColor  *) colorForNumber: (NSUInteger) number
		{return [_numberColors objectAtIndex: number - 1];}


	- (void) setColor:  (NSColor  *) color
		 forNumber: (NSUInteger) number
		{
		[_numberColors replaceObjectAtIndex: number - 1 withObject: color];
		if (_owner) [_owner updateNumber: number];
		}


	- (NSColor *) imageColorForKey: (NSUInteger) key
		{
		NSColor *color = [_imageColors objectAtIndex: key];

		return [color isEqual: [NSNull null]] ? nil : color;
		}

	- (void) setImageColor: (NSColor  *) color
		 forKey:	(NSUInteger) key
		{
		[_imageColors replaceObjectAtIndex: key withObject: color ? color : [NSNull null]];
		if (_owner) [_owner updateImageWithKey: key];
		}


	- (void) setImageColor: (NSColor  *) color
		 fileName:	(NSString *) fileName
		 included:	(BOOL      ) included
		 forKey:	(NSUInteger) key
		{
		[_imageColors	 replaceObjectAtIndex: key withObject: color ? color : [NSNull null]];
		[_imageFileNames replaceObjectAtIndex: key withObject: fileName];
		_imageInclusions[key] = included;
		if (_owner) [_owner updateImageWithKey: key];
		}


	- (BOOL) hasExternalImages
		{return !(_imageInclusions[0] && _imageInclusions[1] && _imageInclusions[2]);}


	- (NSMutableArray *) loadImages: (inout BOOL *) errors
		{
		NSMutableArray *images = [[NSMutableArray alloc] init];
		NSImage*       image;
		NSString*      fileName;
		NSString*      storagePath     = nil;
		NSString*      filePath	       = nil;
		NSFileManager* fileManager     = nil;
		NSError*       error	       = nil;
		NSNull*	       null	       = [NSNull null];
		NSSize	       maximumCellSize = MaximumCellSizeInCurrentDisplays();
		BOOL	       createErrors    = *errors;

		*errors = NO;

		for (NSUInteger i = 0; i < 3; i++)
			{
			if (_imageInclusions[i]) [images addObject:
				(image = [NSImage imageNamed: filePath = [_imageFileNames objectAtIndex: i]])
					? image
					: (createErrors ? ErrorForFile(_("Error.UnableToLoadFile"), filePath) : null)];

			else	{
				fileName = [_imageFileNames objectAtIndex: i];

				if (!storagePath && !(storagePath = BundleSupportSubdirectory(@"Custom Images", NO, NULL)))
					{
					[images addObject: createErrors ? ErrorForFile(_("Error.FileDoesNotExist"), fileName) : null];
					*errors = YES;
					continue;
					}

				filePath = [storagePath stringByAppendingPathComponent: [_imageFileNames objectAtIndex: i]];
				if (!fileManager) fileManager = [NSFileManager defaultManager];

				if (![fileManager fileExistsAtPath: filePath])
					{
					[images addObject: createErrors ? ErrorForFile(_("Error.FileDoesNotExist"), fileName) : null];
					*errors = YES;
					continue;
					}

				if (!(image = [NSImage imageFromFile: filePath error: createErrors ? &error : NULL]))
					{
					[images addObject: createErrors ? ErrorForBadImageFormatInFile(fileName) : null];
					*errors = YES;
					continue;
					}

				image.size = SizeFit(image.size, maximumCellSize);
				[images addObject: image];
				}
			}

		return [images autorelease];
		}


	- (BOOL) save: (NSError **) error
		{
		NSString *path = BundleSupportSubdirectory(@"Themes", YES, error);

		return path

			? [[NSPropertyListSerialization

			dataFromPropertyList: [self dictionary]
			format:		      NSPropertyListXMLFormat_v1_0
			errorDescription:     NULL]
				writeToFile: STRING(@"%@/%@.MinesTheme", path, [_name VFSSafeString])
				options:     NSDataWritingAtomic
				error:	     error]

			: NO;
		}


	- (BOOL) remove: (NSError **) error
		{
		NSString *path = BundleSupportSubdirectory(@"Themes", NO, error);

		if (!path) return NO;

		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSString *imagePath;

		for (NSUInteger i = 0; i < 3; i++) if (
			!_imageInclusions[i] &&
			[fileManager fileExistsAtPath:
				imagePath = [path stringByAppendingPathComponent: [_imageFileNames objectAtIndex: i]]]
		)
			[fileManager removeItemAtPath: imagePath error: NULL];

		return ([fileManager fileExistsAtPath: path = STRING(@"%@/%@.MinesTheme", path, [_name VFSSafeString])])
			? [fileManager removeItemAtPath: path error: error]
			: YES;
		}


@end

// EOF
