/* Mines - PreferencesWindowController.m
   __  __
  /  \/  \  __ ___  ____   ____
 /	  \(__)   \/  -_)_/  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Betty Lab.
Released under the terms of the GNU General Public License v3. */

#import "PreferencesWindowController.h"
#import "ImagePicker.h"
#import "NSWindow+BL.h"
#import "NSColor+BL.h"
#import "NSImage+BL.h"
#import "NSString+BL.h"
#import "helpers.h"
#import "geometry.h"

#define SELECTED_USER_THEME_ROW      _bundleThemes.count + 1 + [_userThemes indexOfObject: _theme]
#define DEFAULT_TEMPLATE_IMAGE_COLOR [NSColor colorWithDeviceRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.5]


@implementation PreferencesWindowController


#	pragma mark - Helpers


	- (void) sortUserThemes
		{
		[_userThemes sortUsingComparator: ^NSComparisonResult(Theme *a, Theme *b)
			{return [a.name localizedCaseInsensitiveCompare: b.name];}];
		}


	- (NSImage *) imageFromImage: (NSImage *) image
		      tintColor:      (NSColor *) color
		{
		NSBitmapImageRep *bitmap;
		NSImage *output;
		NSRect frame = NSMakeRect(0.0, 0.0, 96.0, 96.0);
		CGFloat scalingFactor = 1.0, factor;

		for (NSScreen *screen in [NSScreen screens])
			if ([screen respondsToSelector: @selector(backingScaleFactor)])
				if ((factor = [screen backingScaleFactor]) > scalingFactor)
					scalingFactor = factor;

		frame.size = SizeMultiplyByScalar(frame.size, scalingFactor);

		bitmap = [[NSBitmapImageRep alloc]
			initWithBitmapDataPlanes: NULL
			pixelsWide:		  frame.size.width
			pixelsHigh:		  frame.size.height
			bitsPerSample:		  8
			samplesPerPixel:	  4
			hasAlpha:		  YES
			isPlanar:		  NO
			colorSpaceName:		  NSDeviceRGBColorSpace
			bytesPerRow:		  4 * (NSInteger)frame.size.width
			bitsPerPixel:		  32];

		[NSGraphicsContext saveGraphicsState];

			NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep: bitmap];

			[NSGraphicsContext setCurrentContext: context];

			if ([image isKindOfClass: [NSImage class]])
				{
				if (color)
					{
					CGFloat components[4];

					[color getComponents: components];

					[image	drawInRect: RectangleFitInCenter(frame, image.size)
						fromRect:   NSZeroRect
						operation:  NSCompositeSourceOver
						fraction:   components[3]];

					[[NSColor
						colorWithDeviceRed: components[0]
						green:		    components[1]
						blue:		    components[2]
						alpha:		    1.0]
							set];

					NSRectFillUsingOperation(frame, NSCompositeSourceAtop);
					}

				else [image
					drawInRect: RectangleFitInCenter(frame, image.size)
					fromRect:   NSZeroRect
					operation:  NSCompositeCopy
					fraction:   1.0];
				}

			[_imageBackgroundColor set];
			NSRectFillUsingOperation(frame, NSCompositeDestinationOver);

		[NSGraphicsContext restoreGraphicsState];

		output = [[NSImage alloc] initWithCGImage: [bitmap CGImage] size: frame.size];
		[bitmap release];
		return [output autorelease];
		}


	- (void) updateThemeControlsContent
		{
		NSColor *color;
		CGFloat value;

		//-------------.
		// Effects box |
		//-------------'
		laserColorWell.color = _theme.laserColor;
		[mineFoundAnimationButton selectItemWithTag: 0]; // Cambiar

		//-----------.
		// Cells box |
		//-----------'
		if ((color = _theme.gridColor))
			{
			gridCheck.state = NSOnState;
			gridColorWell.color = color;
			}

		else	{
			gridCheck.state = NSOffState;
			gridColorWell.color = [NSColor blackColor];
			}

		if ((value = _theme.cellBorderSize) != 0.0)
			{
			cellBorderCheck.state = NSOnState;
			cellBorderSizeSlider.doubleValue = value * 100.0;
			}

		else	{
			cellBorderCheck.state = NSOffState;
			cellBorderSizeSlider.doubleValue = 12.5;
			}

		BOOL alternateCoveredCells   = _theme.alternateCoveredCells;
		BOOL alternateUncoveredCells = _theme.alternateUncoveredCells;

		alternateCoveredCellsCheck.state   = alternateCoveredCells   ? NSOnState : NSOffState;
		alternateUncoveredCellsCheck.state = alternateUncoveredCells ? NSOnState : NSOffState;

		cellBrightnessDeltaSlider.doubleValue = alternateCoveredCells || alternateUncoveredCells
			? _theme.cellBrightnessDelta * 100.0
			: 0.0;

		NSArray* colors = _theme.cellColors;
		NSInteger tag = 100;

		for (color in colors) [[cellsBox viewWithTag: tag++] setColor: color];

		if (tag == 107)
			{
			color = [colors objectAtIndex: 0];
			while (tag < 111) [[cellsBox viewWithTag: tag++] setColor: color];
			color = [colors objectAtIndex: 1];
			while (tag < 115) [[cellsBox viewWithTag: tag++] setColor: color];
			color = [colors objectAtIndex: 2];
			while (tag < 119) [[cellsBox viewWithTag: tag++] setColor: color];
			}

		//---------------------.
		// Warning numbers box |
		//---------------------'
		tag = 0;
		for (color in _theme.numberColors) [[numbersBox viewWithTag: tag++] setColor: color];

		numberFontSizeSlider.doubleValue    = _theme.numberFontScale;
		numberFontNameTextField.stringValue = [NSFont fontWithName: _theme.numberFontName size: 11.0].displayName;

		//------------.
		// Images box |
		//------------'
		NSColor *black = nil;
		NSNull *null = [NSNull null];

		for (tag = 0; tag < 4; tag++)
			{
			NSColorWell* colorWell = [imagesBox viewWithTag: 30 + tag];
			NSButton*    checkBox  = [imagesBox viewWithTag: 20 + tag];

			if ((color = [_theme.imageColors objectAtIndex: tag]) != (id)null)
				{
				checkBox.state	= NSOnState;
				colorWell.color = color;
				}

			else	{
				checkBox.state	= NSOffState;
				colorWell.color = black ? black : (black = [NSColor blackColor]);
				}

			[[imagesBox viewWithTag: tag] setImage:
				[self imageFromImage: [_themeImages objectAtIndex: tag] tintColor: color]];
			}
		}


	- (void) updateThemeControlsState
		{
		//------------------------------------------------------------------------------.
		// First enable or disable all controls according to if the theme is read-only. |
		//------------------------------------------------------------------------------'
		BOOL enabled = ![_bundleThemes containsObject: _theme];
		Class boxClass = [NSBox class];

		for (NSBox *box in themeView.subviews)
			if ([box isKindOfClass: boxClass])
				for (NSControl *control in [box.contentView subviews])
					if ([control respondsToSelector: @selector(setEnabled:)])
						[control setEnabled: enabled];

		[themeActionsSegmentedControl setEnabled: enabled forSegment: 1];

		//----------------------------------------------------------------------.
		// Then, if the theme is not read-only, disable those optional controls |
		// which depend on others to be enabled if needed.			|
		//----------------------------------------------------------------------'
		if (enabled)
			{
			if (!_theme.gridColor) gridColorWell.enabled = NO;

			if (_theme.cellBorderSize == 0.0)
				{
				cellBorderSizeSlider.enabled = NO;

				for (NSUInteger tag = 107; tag < 119; tag++)
					[[cellsBox viewWithTag: tag] setEnabled: NO];
				}

			if (!_theme.alternateCoveredCells && !_theme.alternateUncoveredCells)
				cellBrightnessDeltaSlider.enabled = NO;

			NSNull *null = [NSNull null];
			NSInteger tag = 30;

			for (NSColor *color in _theme.imageColors) if (color == (id)null)
				[[imagesBox viewWithTag: tag++] setEnabled: NO];
			}
		}


	- (void) prepareThemeTab
		{
		BOOL		currentThemeIsFromBundle = NO;
		NSMutableArray* names			 = [[NSMutableArray alloc] init];
		NSString*	themeName		 = (_theme = _board.theme).name;
		NSString*	name;
		Theme*		theme;

		_separatorCell	      = [[SeparatorCell alloc] init];
		_themeImages	      = _board.themeImages;
		_bundleThemes	      = [[NSMutableArray alloc] init];
		_userThemes	      = [[NSMutableArray alloc] init];
		_imageBackgroundColor = [[NSColor colorWithPatternImage: [NSImage imageNamed: @"Image Background.png"]] retain];

		//---------------------------------------------------------------------------------------.
		// Desactivamos la sincronización automática de las preferencias. Solamente se guardarán |
		// los cambios al salir de la pestaña, al cerrar la ventana o al salir de la apliación.	 |
		//---------------------------------------------------------------------------------------'
		//defaultsController.appliesImmediately = NO;

		//-------------------------------------------------------------.
		// Cargamos los temas incluidos en el bundle de la aplicación. |
		//-------------------------------------------------------------'
		for (NSDictionary *entry in [Theme internalDictionaries]) if ([Theme validateDictionary: entry])
			{
			if ([themeName isEqualToString: name = [entry objectForKey: @"Name"]])
				{
				[_bundleThemes addObject: _theme];
				currentThemeIsFromBundle = YES;
				}

			else	{
				[_bundleThemes addObject: theme = [[Theme alloc] initWithDictionary: entry]];
				[theme release];
				}

			[names addObject: name];
			}

		//--------------------------------------------.
		// Cargamos los temas creados por el usuario. |
		//--------------------------------------------'
		NSString *themesPath = BundleSupportSubdirectory(@"Themes", NO, NULL);

		if (themesPath)
			{
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSDictionary *dictionary;

			for (NSString *fileName in [fileManager contentsOfDirectoryAtPath: themesPath error: NULL]) if (
				[fileName hasSuffix: @".MinesTheme"]										  &&
				(dictionary = [NSDictionary dictionaryWithContentsOfFile: [themesPath stringByAppendingPathComponent: fileName]]) &&
				[Theme validateDictionary: dictionary]										  &&
				![names containsObject: name = [dictionary objectForKey: @"Name"]]
			)
				{
				if ([themeName isEqualToString: name]) [_userThemes addObject: theme = _theme];

				else	{
					[_userThemes addObject: theme = [[Theme alloc] initWithDictionary: dictionary]];
					[theme release];
					}

				[names addObject: name];
				}
			}

		[names release];
		[self sortUserThemes];
		themeList.dataSource = self;

		//-------------------------------------------.
		// Seleccionamos en la lista el tema activo. |
		//-------------------------------------------'
		[themeList
			selectRowIndexes: [NSIndexSet indexSetWithIndex: currentThemeIsFromBundle
				? [_bundleThemes indexOfObject: _theme]
				: [_userThemes	 indexOfObject: _theme] + _bundleThemes.count + 1]
			byExtendingSelection: NO];

		themeList.delegate = self;
		[self updateThemeControlsContent];
		[self updateThemeControlsState];
		}


	- (void) finalizeThemeTab
		{
		if (_flags.themeIsUnsaved || _flags.themeHasChanged) [self saveTheme];

		id defaults = [defaultsController values];
		NSString *themeIdentifier = [_theme.name VFSSafeString];

		if (![[defaults valueForKey: @"ThemeIdentifier"] isEqualToString: themeIdentifier])
			{
			[defaults setValue: themeIdentifier forKey: @"ThemeIdentifier"];

			[defaults
				setValue: [NSNumber numberWithBool: [_bundleThemes containsObject: _theme]]
				forKey:   @"ThemeIsInternal"];
			}

		themeList.dataSource = nil;
		themeList.delegate   = nil;

		[_bundleThemes	       release];
		[_userThemes	       release];
		[_imageBackgroundColor release];
		[_separatorCell	       release];

		_separatorCell	      = nil;
		_bundleThemes	      = nil;
		_userThemes	      = nil;
		_imageBackgroundColor = nil;
		}


	- (Theme *) themeForRow: (NSUInteger) row
		{
		return row < _bundleThemes.count
			? [_bundleThemes objectAtIndex: row]
			: [_userThemes	 objectAtIndex: row - 1 - _bundleThemes.count];
		}


	- (void) setTheme: (Theme *) theme
		{
		BOOL errors = YES;

		_theme = theme;
		_themeImages = [theme loadImages: &errors];

		if (errors)
			{
			Class errorClass = [NSError class];
			NSNull *null = [NSNull null];
			id object;

			for (NSUInteger i = 0; i < 4; i++)
				if ([(object = [_themeImages objectAtIndex: i]) isKindOfClass: errorClass])
					{
					[[NSAlert alertWithError: object] runModal];
					[_themeImages replaceObjectAtIndex: i withObject: null];
					}
			}

		[self updateThemeControlsContent];
		[self updateThemeControlsState];
		[_board setTheme: theme images: _themeImages];
		}


	- (BOOL) saveTheme
		{
		NSError *error = nil;

		if ([_theme save: &error]) return YES;
		[[NSAlert alertWithError: error] runModal];
		return NO;
		}


	- (void) willChangeThemeListSelection
		{if (_flags.themeIsUnsaved || _flags.themeHasChanged) [self saveTheme];}


#	pragma mark - NSTableViewDataSource Protocol


	- (NSInteger) numberOfRowsInTableView: (NSTableView *) tableView
		{return _bundleThemes.count + _userThemes.count + 1;}


	- (id) tableView:		  (NSTableView	 *) tableView
	       objectValueForTableColumn: (NSTableColumn *) column
	       row:			  (NSInteger	  ) row
		{
		NSUInteger bundleThemeCount = _bundleThemes.count;

		if (row <  bundleThemeCount) return [[_bundleThemes objectAtIndex: row] name];
		if (row == bundleThemeCount) return nil;
					     return [[_userThemes objectAtIndex: row - bundleThemeCount - 1] name];
		}


	- (void) tableView:	 (NSTableView	*) tableView
		 setObjectValue: (NSString	*) themeName
		 forTableColumn: (NSTableColumn *) tableColumn
		 row:		 (NSInteger	 ) row
		{
		NSString *oldThemeName = [_theme.name retain];

		if (![oldThemeName isEqualToString: themeName = [themeName
			stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]]]
		)
			{
			_theme.name = themeName;

			if ([self saveTheme])
				{
				if (!_flags.themeIsUnsaved)
					{
					NSError*       error = nil;
					NSString*      path = BundleSupportSubdirectory(@"Themes", NO, &error);
					NSFileManager* fileManager;
					NSString*      oldFilePath;

					if (	!path ||
						([fileManager = [NSFileManager defaultManager] fileExistsAtPath: oldFilePath =
							STRING(@"%@/%@.MinesTheme", path, [oldThemeName VFSSafeString])] &&
						 ![fileManager removeItemAtPath: oldFilePath error: &error])
					)
						[[NSAlert alertWithError: error] runModal];
					}

				_flags.themeHasChanged = NO;
				_flags.themeIsUnsaved  = NO;
				}

			else _theme.name = oldThemeName;
			}

		[oldThemeName release];
		}


#	pragma mark - NSTableViewDelegate Protocol


	- (CGFloat) tableView:	 (NSTableView *) tableView
		    heightOfRow: (NSInteger    ) row
		{
		if (row != _bundleThemes.count) return 17.0;
		return 7.0;
		}


	- (NSCell *) tableView:		     (NSTableView   *) tableView
		     dataCellForTableColumn: (NSTableColumn *) tableColumn
		     row:		     (NSInteger	     ) row
		{
		NSTextFieldCell *cell = [tableColumn dataCellForRow: row];

		return (row != _bundleThemes.count) ? cell : _separatorCell;
		}


	- (BOOL) tableView:	  (NSTableView *) tableView
		 shouldSelectRow: (NSInteger	) row
		{
		NSUInteger bundleThemesCount = _bundleThemes.count;

		if (_flags.doNotSelectRow || row == bundleThemesCount) return NO;

		Theme *theme = [self themeForRow: row];

		if (theme != _theme)
			{
			[self willChangeThemeListSelection];
			[self setTheme: theme];
			_flags.themeIsUnsaved  = NO;
			_flags.themeHasChanged = NO;
			}

		return YES;
		}


	- (BOOL) tableView:		(NSTableView   *) tableView
		 shouldEditTableColumn: (NSTableColumn *) tableColumn
		 row:			(NSInteger      ) row
		{
		return row > _bundleThemes.count;
		}


#	pragma mark - TableViewDelegate Protocol


	- (BOOL) tableViewShouldEndEditing: (NSString *) string
		{
		for (Theme *theme in _bundleThemes)
			if (theme != _theme && [theme.name isEqualToString: string])
				{
				NSBeep();
				return NO;
				}

		for (Theme *theme in _userThemes)
			if (theme != _theme && [theme.name isEqualToString: string])
				{
				NSBeep();
				return NO;
				}

		return YES;
		}


	- (void) tableViewDidEndEditing
		{
		[self sortUserThemes];
		[themeList reloadData];

		[themeList
			selectRowIndexes: [NSIndexSet indexSetWithIndex: SELECTED_USER_THEME_ROW]
			byExtendingSelection: NO];
		}


#	pragma mark - ImagePickerDelegate Protocol


	- (void) imagePickerDidEndWithResult: (BOOL		      ) result
		 resultData:		      (ImagePickerResultData *) resultData
		{
		if (result)
			{
			NSImage *oldImage = [_themeImages objectAtIndex: _imageIndex];

			if (oldImage != resultData->image)
				{
				NSColor *color = [_theme.imageColors objectAtIndex: _imageIndex];

				//------------------------------------------------------.
				// Actualizamos la información de la imágen en el tema. |
				//------------------------------------------------------'
				[_themeImages replaceObjectAtIndex: _imageIndex withObject: resultData->image];
				[_theme.imageFileNames replaceObjectAtIndex: _imageIndex withObject: resultData->fileName];
				_theme.imageInclusions[_imageIndex] = resultData->isInternal;
				_flags.themeHasChanged = YES;

				//--------------------------------------------------------.
				// Actualizamos los controles relacionados con la imagen. |
				//--------------------------------------------------------'
				[[imagesBox viewWithTag: _imageIndex] setImage: [self
					imageFromImage:	 resultData->image
					tintColor:	 color == (id)[NSNull null] ? nil : color]];

				[_board didChangeThemeProperty: kThemePropertyImage valueAtIndex: _imageIndex];
				}
			}

		[_imagePicker release];
		_imagePicker = nil;
		}


	- (void) imagePickerDidRemoveUserImageNamed: (NSString *) imageName
		 replaceWithBundleImages:	     (NSArray  *) bundleImages
		 named:				     (NSArray  *) bundleImageFileNames
		{
		for (Theme *theme in _userThemes)
			{
			NSMutableArray* imageFileNames	= theme.imageFileNames;
			BOOL*		imageInclusions = theme.imageInclusions;
			NSError*	error;
			NSColor*	color = DEFAULT_TEMPLATE_IMAGE_COLOR;

			for (NSUInteger i = 0; i < 4; i++)
				if (!imageInclusions[i] && [imageName isEqualToString: [imageFileNames objectAtIndex: i]])
					{
					if (theme == _theme)
						{
						NSImage *image = [bundleImages objectAtIndex: i];

						[[imagesBox viewWithTag: i] setImage: [self imageFromImage: image tintColor: color]];
						[_themeImages replaceObjectAtIndex: i withObject: image];
						}

					theme.imageInclusions[i] = YES;
					[theme.imageColors    replaceObjectAtIndex: i withObject: color];
					[theme.imageFileNames replaceObjectAtIndex: i withObject: [bundleImageFileNames objectAtIndex: i]];
					if (![theme save: &error]) [[NSAlert alertWithError: error] runModal];
					}
			}
		}


#	pragma mark - Public


	- (id) initWithBoard: (Board *) board
		{
		if ((self = [super initWithWindowNibName: @"Preferences"])) _board = [board retain];
		return self;
		}


	- (void) dealloc
		{
		[self.window orderOut: self];

		[_board	      release];
		[_imagePicker release];

		if (self.window.contentView == themeView) [self finalizeThemeTab];

		if ([defaultsController hasUnappliedChanges])
			{
			defaultsController.appliesImmediately = YES;
			[defaultsController save: self];
			}

		[super dealloc];
		}


	- (void) windowDidLoad
		{
		[super windowDidLoad];

		NSWindow *window = self.window;

		if (IS_BELOW_LION)
			{
			//------------------------------------------------------.
			// En Snow Leopard no se centra correctamente la imagen |
			// PDF del botón de selección de la fuente. Lo movemos	|
			// un par de pixels hacia abajo para evitar este fallo.	|
			//------------------------------------------------------'
			NSRect frame = numberFontButton.frame;

			frame.origin.y -= 2.0;
			numberFontButton.frame = frame;
			}

		defaultsController.appliesImmediately = NO;
		window.title = _("Preferences.WindowTitle.General");
		window.toolbar.selectedItemIdentifier =  @"General";
		[window replaceContentViewWithView: generalView animate: NO];
		}


#	pragma mark - IBAction (Tab Control)


	- (IBAction) tab: (NSToolbarItem *) sender
		{
		NSWindow *window = self.window;
		NSView *currentView = window.contentView, *newView;
		NSString *title;

		switch (sender.tag)
			{
			case 0:	newView = generalView;
			title = _("Preferences.WindowTitle.General");
			break;

			case 1:	newView = effectsView;
			title = _("Preferences.WindowTitle.Effects");
			break;

			case 2:	newView = themeView;
			title = _("Preferences.WindowTitle.Theme");
			break;
			}

		if (newView != currentView)
			{
			if (currentView == themeView) [self finalizeThemeTab];
			else if (newView == themeView) [self prepareThemeTab];
			window.title = title;
			[window replaceContentViewWithView: newView animate: YES];
			}
		}


#	pragma mark - IBAction (Theme Tab)


	- (IBAction) cancel: (id) sender
		{
		id responder = self.window.firstResponder;

		if ([responder isKindOfClass: [NSTextView class]]) [themeList abortEditing];
		else [self.window performClose: self];
		}


	- (IBAction) setLaserColor: (NSColorWell *) sender
		{
		NSColor *color = sender.color.opaqueSRGBColor;

		_theme.laserColor = color;
		sender.color = color;
		_flags.themeHasChanged = YES;
		}


	- (IBAction) setMineFoundAnimation: (id) sender
		{
		NSLog(@"setAnimationForMineFound");
		}


	- (IBAction) testMineFoundAnimation: (id) sender
		{
		NSLog(@"testAnimationForMineFound");
		}


	- (IBAction) toggleGrid: (NSButton *) sender
		{
		_theme.grid = sender.state == NSOnState;
		_flags.themeHasChanged = YES;
		[_board didChangeThemeProperty: kThemePropertyGrid valueAtIndex: 0];
		}


	- (IBAction) setGridColor: (NSColorWell *) sender
		{
		NSColor *color = sender.color.opaqueSRGBColor;

		_theme.gridColor = color;
		sender.color = color;
		_flags.themeHasChanged = YES;
		[_board didChangeThemeProperty: kThemePropertyGridColor valueAtIndex: 0];
		}


	- (IBAction) toggleCellBorder: (NSButton *) sender
		{
		_theme.cellBorder = sender.state == NSOnState;
		_flags.themeHasChanged = YES;
		[_board didChangeThemeProperty: kThemePropertyCellBorder valueAtIndex: 0];
		}


	- (IBAction) setBorderSize: (NSSlider *) sender
		{
		_theme.cellBorderSize = sender.doubleValue;
		_flags.themeHasChanged = YES;
		[_board didChangeThemeProperty: kThemePropertyCellBorderSize valueAtIndex: 0];
		}


	- (IBAction) toggleAlternateCoveredCells: (NSButton *) sender
		{
		_theme.alternateCoveredCells = sender.state == NSOnState;
		_flags.themeHasChanged = YES;
		[_board didChangeThemeProperty: kThemePropertyAlternateCoveredCells valueAtIndex: 0];
		}


	- (IBAction) toggleAlternateUncoveredCells: (NSButton *) sender
		{
		_theme.alternateUncoveredCells = sender.state == NSOnState;
		_flags.themeHasChanged = YES;
		[_board didChangeThemeProperty: kThemePropertyAlternateUncoveredCells valueAtIndex: 0];
		}


	- (IBAction) setCellBrightnessDelta: (NSSlider *) sender
		{
		_theme.cellBrightnessDelta = sender.doubleValue;
		_flags.themeHasChanged = YES;
		[_board didChangeThemeProperty: kThemePropertyCellBrightnessDelta valueAtIndex: 0];
		}


	- (IBAction) setCellColor: (NSColorWell *) sender
		{
		NSColor *color = sender.color.opaqueSRGBColor;
		NSUInteger index = sender.tag - 100;

		[_theme.cellColors replaceObjectAtIndex: index withObject: color];
		sender.color = color;
		_flags.themeHasChanged = YES;
		[_board didChangeThemeProperty: kThemePropertyCellColor valueAtIndex: index];
		}


	- (IBAction) setNumberColor: (NSColorWell *) sender
		{
		NSColor *color = sender.color.opaqueSRGBColor;
		NSUInteger index = sender.tag;

		[_theme.numberColors replaceObjectAtIndex: index withObject: color];
		sender.color = color;
		_flags.themeHasChanged = YES;
		[_board didChangeThemeProperty: kThemePropertyNumberColor valueAtIndex: index];
		}


	- (IBAction) setFont: (NSFontManager *) sender
		{
		if (self.window.contentView == themeView && ![_bundleThemes containsObject: _theme])
			{
			NSFont *font = [sender convertFont: [NSFont systemFontOfSize: 11.0]];

			numberFontNameTextField.stringValue = font.displayName;
			_theme.numberFontName = font.fontName;
			_flags.themeHasChanged = YES;
			[_board didChangeThemeProperty: kThemePropertyNumberFontName valueAtIndex: 0];
			}
		}


	- (IBAction) setNumberFontSize: (NSSlider *) sender
		{
		_theme.numberFontScale = sender.doubleValue;
		_flags.themeHasChanged = YES;
		[_board didChangeThemeProperty: kThemePropertyNumberFontScale valueAtIndex: 0];
		}


	- (IBAction) toggleImageColor: (NSButton *) sender
		{
		NSColorWell *colorWell = [imagesBox viewWithTag: sender.tag + 10];
		BOOL enabled = sender.state == NSOnState;
		NSUInteger index = sender.tag;

		[_theme.imageColors
			replaceObjectAtIndex: index
			withObject: enabled
				? [colorWell.color colorUsingColorSpace: [NSColorSpace sRGBColorSpace]]
				: [NSNull null]];

		colorWell.enabled = enabled;
		_flags.themeHasChanged = YES;
		[_board didChangeThemeProperty: kThemePropertyImageColor valueAtIndex: index];
		}


	- (IBAction) setImageColor: (NSColorWell *) sender
		{
		NSColor *color = [sender.color colorUsingColorSpace: [NSColorSpace sRGBColorSpace]];
		NSInteger index = sender.tag - 30;

		[[imagesBox viewWithTag: index] setImage: [self
			imageFromImage: [_themeImages objectAtIndex: index]
			tintColor:	color]];

		[_theme.imageColors replaceObjectAtIndex: index withObject: color];
		_flags.themeHasChanged = YES;
		[_board didChangeThemeProperty: kThemePropertyImageColor valueAtIndex: index];
		}


	- (IBAction) selectImage: (NSButton *) sender
		{
		NSMutableDictionary *preloadedImages = [[NSMutableDictionary alloc] init];
		Class imageClass = [NSImage class];
		NSImage *image;

		_imageIndex = sender.tag - 10;

		for (NSUInteger i = 0; i < 4; i++)
			if ([(image = [_themeImages objectAtIndex: i]) isKindOfClass: imageClass])
				[preloadedImages setObject: image forKey: [_theme.imageFileNames objectAtIndex: i]];

		_imagePicker = [[ImagePicker alloc]
			initWithDelegate:      self
			preloadedImages:       preloadedImages
			selectedImageFileName: [_theme.imageFileNames objectAtIndex: _imageIndex]];

		[preloadedImages release];
		[_imagePicker runModalForWindow: self.window];
		}


	- (IBAction) performThemeListAction: (NSSegmentedControl *) sender
		{
		NSUInteger index;

		[themeList abortEditing];

		if (sender.selectedSegment)
			{
			NSError*   error	     = nil;
			NSUInteger bundleThemesCount = _bundleThemes.count;
			NSUInteger userThemesCount   = _userThemes.count - 1;
			Theme*	   theme	     = [_theme retain];

			index = [_userThemes indexOfObject: _theme];
			[_userThemes removeObject: theme];
			_theme = nil;

			if (_flags.themeIsUnsaved || [theme remove: &error])
				{
				_flags.doNotSelectRow = YES;
				themeList.allowsEmptySelection = YES;
				[themeList reloadData];
				_flags.doNotSelectRow = NO;
			
				if (!userThemesCount)
					{
					[self setTheme: _bundleThemes.lastObject];
					index = bundleThemesCount - 1;
					}

				else if (index == userThemesCount)
					{
					[self setTheme: _userThemes.lastObject];
					index = bundleThemesCount + userThemesCount;
					}

				else	{
					[self setTheme: [_userThemes objectAtIndex: index]];
					index += bundleThemesCount + 1;
					}

				[themeList selectRowIndexes: [NSIndexSet indexSetWithIndex: index] byExtendingSelection: NO];
				themeList.allowsEmptySelection = NO;
				_flags.themeHasChanged = NO;
				_flags.themeIsUnsaved = NO;

				NSString *themesPath;

				if (	!_userThemes.count					      &&
					(themesPath = BundleSupportSubdirectory(@"Themes", NO, NULL)) &&
					![[NSFileManager defaultManager] removeItemAtPath: themesPath error: &error]
				)
					[[NSAlert alertWithError: error] runModal];
				}

			else [[NSAlert alertWithError: error] runModal];

			[theme release];
			}

		else	{
			NSString *newThemeName, *safeNewThemeName;
			unsigned int nameIndex = 1;

			[self willChangeThemeListSelection];

			safeNewThemeName = newThemeName = _("Preferences.NewThemeName");

			find_safe_name: for (Theme *theme in _userThemes)
				if ([theme.name isEqualToString: safeNewThemeName])
					{
					safeNewThemeName = STRING(@"%@ %u", newThemeName, nameIndex++);
					goto find_safe_name;
					}

			Theme *newTheme = [_theme copyWithName: safeNewThemeName];

			_flags.themeIsUnsaved  = YES;
			_flags.themeHasChanged = YES;
			[_userThemes addObject: newTheme];
			[newTheme release];
			_theme = newTheme;
			[self sortUserThemes];
			[_board setTheme: _theme images: nil];
			[themeList reloadData];
			[self updateThemeControlsState];

			[themeList
				selectRowIndexes:     [NSIndexSet indexSetWithIndex: index = SELECTED_USER_THEME_ROW]
				byExtendingSelection: NO];

			[themeList editColumn: 0 row: index withEvent: nil select: YES];
			}
		}



@end

// EOF
