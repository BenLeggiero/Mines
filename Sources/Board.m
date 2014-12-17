/* Mines - Board.m
 __  __
|  \/  | __  ____  ___  ____
|      |(__)|    |/ -_)(__ <
|__\/__||__||__|_|\___//___/
Copyright © 2013-2014 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "Board.h"
#import "geometry.h"
#import <Q/functions/base/Q2D.h>

//@interface NSFont (PrivateGlyph)
//	- (NSGlyph) _defaultGlyphForChar: (unichar) theChar;
//@end

#define kTextureIndexFlag	 8
#define kTextureIndexMine	 9
#define kTextureIndexExplosion	10
#define CELL_WARNING		MINESWEEPER_CELL_WARNING(cell)
#define CELL_IS(what)		MINESWEEPER_CELL_##what(cell)

static const unichar numbers_[8] = {L'1', L'2', L'3', L'4', L'5', L'6', L'7', L'8'};


/*static inline NSColor *DeviceColorFromGLColor(GLfloat *color)
	{
	return [NSColor
		colorWithDeviceRed: color[0]
		green:		    color[1]
		blue:		    color[2]
		alpha:		    1.0];
	}*/


#pragma mark - Snapshot


BOOL GameSnapshotTest(void *snapshot, size_t snapshotSize)
	{return (BOOL)!minesweeper_snapshot_test(snapshot, snapshotSize);}


BOOL GameSnapshotValues(void *snapshot, size_t snapshotSize, GameValues *values)
	{
	Q2DSize size;
	qsize mineCount;

	if (minesweeper_snapshot_values(snapshot, snapshotSize, &size, &mineCount, NULL))
		return NO;

	values->width	  = (NSUInteger)size.x;
	values->height	  = (NSUInteger)size.y;
	values->mineCount = (NSUInteger)mineCount;

	return YES;
	}


#pragma mark - Board Class


@implementation Board


	# pragma mark - Helpers


	- (void) ensureGameIsCreated
		{
		if (_game == NULL)
			{
			_game = (Minesweeper *)malloc(sizeof(Minesweeper));
			minesweeper_initialize(_game);
			}
		}


	- (void) setTextureGraphicContext
		{
		[NSGraphicsContext saveGraphicsState];

		_bitmap = [[NSBitmapImageRep alloc]
			initWithBitmapDataPlanes: NULL
			pixelsWide:		  (NSInteger)_textureSize
			pixelsHigh:		  (NSInteger)_textureSize
			bitsPerSample:		  8
			samplesPerPixel:	  4
			hasAlpha:		  YES
			isPlanar:		  NO
			colorSpaceName:		  NSDeviceRGBColorSpace
			bytesPerRow:		  4 * (NSInteger)_textureSize
			bitsPerPixel:		  32];

		NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep: _bitmap];

		[_bitmap release];
		[NSGraphicsContext setCurrentContext: context];
		}


	- (GLuint) createTextureFromBlock: (GLubyte *) data
		{
		GLuint name;

		glEnable(GL_TEXTURE_2D);
		//glEnable(GL_COLOR_MATERIAL);

		glGenTextures(1, &name);
		glBindTexture(GL_TEXTURE_2D, name);
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

		// Esto peta según el profiles de OpenGL
		//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BORDER,     0);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,     GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,     GL_CLAMP_TO_EDGE);

		glTexImage2D
			(GL_TEXTURE_2D, 0, GL_RGBA,
			 (GLsizei)_textureSize, (GLsizei)_textureSize,
			 0, GL_RGBA, GL_UNSIGNED_BYTE, data);

		glDisable(GL_TEXTURE_2D);
		//glDisable(GL_COLOR_MATERIAL);

		return name;
		}


	- (void) createTextureForImageWithKey: (NSUInteger) key
		{
		NSColor *color;
		NSImage *image = [_themeImages objectAtIndex: key];
		NSRect frame = NSMakeRect(0.0, 0.0, _textureSize, _textureSize);

		[[NSColor clearColor] setFill];
		NSRectFill(frame);

		if ([image isKindOfClass: [NSImage class]])
			{
			frame = RectangleFitInCenter(frame, image.size);

			if ((color = [_theme imageColorForKey: key]))
				{
				CGFloat components[4];

				[[color colorUsingColorSpace: [NSColorSpace deviceRGBColorSpace]] getComponents: components];

				[image	drawInRect: frame
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
				drawInRect: frame
				fromRect:   NSZeroRect
				operation:  NSCompositeSourceOver
				fraction:   1.0];
			}

		_textureNames[8 + key] = [self createTextureFromBlock: [_bitmap bitmapData]];
		}


	- (void) createTextureForNumber: (NSUInteger) number
		{
		CGGlyph glyph;
		NSRect frame;
		NSBezierPath *path;
		NSAffineTransform *transform;
		NSString *fontName = _theme.fontName;

		NSFont *font = [NSFont
			fontWithName: fontName ? fontName : @"Lucida Grande Bold"
			size:	      floor(_textureSize * _theme.fontScaling)];

		CTFontGetGlyphsForCharacters((CTFontRef)font, &numbers_[number - 1], &glyph, 1);
		//NSLog(@"%@", [font _defaultGlyphForChar: numbers[number]] == glyph ? @"YES" : @"NO");

#		if DEBUG_GEOMETRY
			[[NSColor grayColor] setFill];
#		else
			[[NSColor clearColor] setFill];
//			[backgroundColor setFill];
#		endif

		NSRectFill(NSMakeRect(0.0, 0.0, _textureSize, _textureSize));

		path = [NSBezierPath bezierPath];
		[path moveToPoint: NSZeroPoint];
		[path appendBezierPathWithGlyph: glyph inFont: font];
		frame = path.controlPointBounds;

#		if DEBUG_GEOMETRY
			[[NSColor yellowColor] setFill];

			NSRectFill(NSMakeRect
				(_textureSize / 2.0 - frame.size.width  / 2.0,
				 _textureSize / 2.0 - frame.size.height / 2.0,
				 frame.size.width, frame.size.height));
#		endif

		transform = [NSAffineTransform transform];

		[transform
			translateXBy: round(-frame.origin.x + _textureSize / 2.0 - frame.size.width  / 2.0)
			yBy:	      round(-frame.origin.y + _textureSize / 2.0 - frame.size.height / 2.0)];

		[path transformUsingAffineTransform: transform];
		[[[_theme colorForNumber: number] colorUsingColorSpace: [NSColorSpace deviceRGBColorSpace]] setFill];
		[path fill];

		_textureNames[number - 1] = [self createTextureFromBlock: [_bitmap bitmapData]];
		}


	- (void) createNumberTextures
		{
		[self createTextureForNumber: 1];
		[self createTextureForNumber: 2];
		[self createTextureForNumber: 3];
		[self createTextureForNumber: 4];
		[self createTextureForNumber: 5];
		[self createTextureForNumber: 6];
		[self createTextureForNumber: 7];
		[self createTextureForNumber: 8];
		}


	- (void) createImageTextures
		{
		[self createTextureForImageWithKey: kThemeImageKeyFlag	   ];
		[self createTextureForImageWithKey: kThemeImageKeyMine	   ];
		[self createTextureForImageWithKey: kThemeImageKeyExplosion];
		}


	- (void) updateCellColorsForKey: (NSUInteger) key
		{
		CGFloat  brightnessDelta = _theme.cellBrightnessDelta;
		GLfloat* color1		 = &_cellColors1[key * 3];
		GLfloat* color2		 = &_cellColors2[key * 3];
		CGFloat  components[4];

		[[[_theme colorForKey: key] colorUsingColorSpace: [NSColorSpace deviceRGBColorSpace]]
			getComponents: components];

		color2[0] = (color1[0] = components[0]) + brightnessDelta;
		color2[1] = (color1[1] = components[1]) + brightnessDelta;
		color2[2] = (color1[2] = components[2]) + brightnessDelta;

		if (color2[0] > 1.0) color2[0] = 1.0; else if (color2[0] < 0.0) color2[0] = 0.0;
		if (color2[1] > 1.0) color2[1] = 1.0; else if (color2[1] < 0.0) color2[1] = 0.0;
		if (color2[2] > 1.0) color2[2] = 1.0; else if (color2[2] < 0.0) color2[2] = 0.0;
		}


	- (void) updateCellColor2ForKey: (NSUInteger) key
		{
		GLfloat *color1 = &_cellColors1[key * 3],
			*color2 = &_cellColors2[key * 3];

		color2[0] = color1[0] + _cellBrightnessDelta;
		color2[1] = color1[1] + _cellBrightnessDelta;
		color2[2] = color1[2] + _cellBrightnessDelta;

		if (color2[0] > 1.0) color2[0] = 1.0; else if (color2[0] < 0.0) color2[0] = 0.0;
		if (color2[1] > 1.0) color2[1] = 1.0; else if (color2[1] < 0.0) color2[1] = 0.0;
		if (color2[2] > 1.0) color2[2] = 1.0; else if (color2[2] < 0.0) color2[2] = 0.0;
		}


	- (Q2DSize) cellCoordinatesOfEvent: (NSEvent *) event
		{
		NSPoint point = [self convertPoint: [event locationInWindow] fromView: nil];
		NSSize size   = self.bounds.size;

		return q_2d_value(SIZE)
			((qsize)(point.x / (size.width  / (CGFloat)_values.width )),
			 (qsize)(point.y / (size.height / (CGFloat)_values.height)));
		}


	- (void) discloseCell
		{
		MinesweeperResult result = minesweeper_disclose(_game, _coordinates);

		switch (result)
			{
			case 0:
			if (delegate) [delegate boardDidDiscloseCells: self];
			self.needsDisplay = YES;
			return;

			case MINESWEEPER_RESULT_SOLVED:
			_state = kBoardStateResolved;
			minesweeper_flag_all_mines(_game);
			if (delegate) [delegate boardDidWin: self];
			self.needsDisplay = YES;
			return;

			case MINESWEEPER_RESULT_MINE_FOUND:
			//minesweeper_disclose_all_mines(_game);
			_state = kBoardStateGameOver;

			if (delegate) [delegate board: self didDiscloseMineAtCoordinates: _coordinates];
			self.needsDisplay = YES;
			return;
			}
		}


	- (void) toggleFlag
		{
		if (	minesweeper_state(_game) == MINESWEEPER_STATE_PLAYING &&
			!MINESWEEPER_CELL_DISCLOSED(minesweeper_cell(_game, _coordinates))
		)
			{
			minesweeper_toggle_flag(_game, _coordinates, NULL);
			[delegate boardDidChangeFlags: self];
			self.needsDisplay = YES;
			}
		}


	- (void) revealRemaining
		{
		}


#	pragma mark - Accessors


	@synthesize state	     = _state;
	@synthesize values	     = _values;
	@synthesize leftButtonAction = _leftButtonAction;
	@synthesize theme	     = _theme;
	@synthesize themeImages      = _themeImages;


	- (NSUInteger)	width		{return _values.width;}
	- (NSUInteger)	height		{return _values.height;}
	- (NSUInteger)	mineCount	{return _values.mineCount;}
	- (NSUInteger)	flagCount	{return (NSUInteger)minesweeper_flag_count     (_game);}
	- (NSUInteger)	clearedCount	{return (NSUInteger)minesweeper_disclosed_count(_game);}
	- (BOOL)	alternateCells	{return _flags.alternateCells;}
	- (BOOL)	showMines	{return _flags.showMines;}
	- (BOOL)	showGoodFlags	{return _flags.showGoodFlags;}


	- (void) setAlternateCells: (BOOL) value
		{
		_flags.alternateCells = value;
		self.needsDisplay = YES;
		}


	- (void) setShowMines: (BOOL) value
		{
		_flags.showMines = value;
		self.needsDisplay = YES;
		}


	- (void) setShowGoodFlags: (BOOL) value
		{
		_flags.showGoodFlags = value;
		self.needsDisplay = YES;
		}


#	pragma mark - ThemeOwner Protocol


	- (void) updateNumbers
		{
		if (_game)
			{
			if (_flags.texturesCreated) glDeleteTextures(8, _textureNames);
			[self setTextureGraphicContext];
			[self createNumberTextures];
			[NSGraphicsContext restoreGraphicsState];
			self.needsDisplay = YES;
			}
		}


	- (void) updateNumber: (NSUInteger) number
		{
		if (_game)
			{
			if (_flags.texturesCreated) glDeleteTextures(1, &_textureNames[number - 1]);
			[self setTextureGraphicContext];
			[self createTextureForNumber: number];
			[NSGraphicsContext restoreGraphicsState];
			self.needsDisplay = YES;
			}

		}


	- (void) updateImageWithKey: (NSUInteger) key
		{
		if (_game != NULL)
			{
			if (_flags.texturesCreated) glDeleteTextures(1, &_textureNames[8 + key]);
			[self setTextureGraphicContext];
			[self createTextureForImageWithKey: key];
			[NSGraphicsContext restoreGraphicsState];
			self.needsDisplay = YES;
			}
		}


	- (void) updateColorWithKey: (NSUInteger) key
		{
		[self updateCellColorsForKey: key];
		self.needsDisplay = YES;
		}


	- (void) updateAlternateColors
		{
		CGFloat delta = _theme.cellBrightnessDelta;

		if (_cellBrightnessDelta != delta)
			{
			_cellBrightnessDelta = delta;

			[self updateCellColor2ForKey: kThemeColorKeyCovered      ];
			[self updateCellColor2ForKey: kThemeColorKeyClean	 ];
			[self updateCellColor2ForKey: kThemeColorKeyFlag	 ];
			[self updateCellColor2ForKey: kThemeColorKeyConfirmedFlag];
			[self updateCellColor2ForKey: kThemeColorKeyMine	 ];
			[self updateCellColor2ForKey: kThemeColorKeyWarning      ];
			}

		if (_game) self.needsDisplay = YES;
		}


#	pragma mark - Overwritten


	- (id) initWithCoder: (NSCoder *) coder
		{
		if ((self = [super initWithCoder: coder]))
			if ([self respondsToSelector: @selector(setWantsBestResolutionOpenGLSurface:)])
				[self setWantsBestResolutionOpenGLSurface: YES];

		return self;
		}


	- (void) dealloc
		{
		if (_flags.texturesCreated) glDeleteTextures(11, _textureNames);

		if (_game != NULL)
			{
			minesweeper_finalize(_game);
			free(_game);
			}

		[_theme	      release];
		[_themeImages release];
		[super	      dealloc];
		}


#	define SET_COLOR(color) glColor3fv(&palette[paletteIndex][kThemeColorKey##color * 3])


	- (void) drawRect: (NSRect) frame
		{
		if (_game == NULL)
			{
			glClearColor(0.0, 0.0, 0.0, 1.0);
			glClear(GL_COLOR_BUFFER_BIT);
			}

		else	{
			MinesweeperCell cell;
			GLfloat *palette[2] = {_cellColors1, _cellColors2};
			NSInteger paletteIndex = 0;
			BOOL alternate = _flags.alternateCells && _cellBrightnessDelta != 0.0;

			glEnable(GL_BLEND);
			glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
			glEnable(GL_TEXTURE_2D);
			glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

#			if DEBUG_GEOMETRY
				glClearColor
					(palette[paletteIndex][kThemeColorKeyClean * 3],
					 palette[paletteIndex][kThemeColorKeyClean * 3 + 1],
					 palette[paletteIndex][kThemeColorKeyClean * 3 + 2],
					 1);

				glClear(GL_COLOR_BUFFER_BIT);
#			endif

			NSPoint	 origin;
			GLint	 x, y;
			GLdouble tx, ty;
			GLuint*	 textureName   = NULL;
			BOOL	 showMines     = _flags.showMines;
			BOOL	 showGoodFlags = _flags.showGoodFlags;

			NSSize size = NSMakeSize
				(_surfaceSize.width  / (CGFloat)_values.width,
				 _surfaceSize.height / (CGFloat)_values.height);

			if (_game != NULL) for (y = 0; y < _values.height; y++)
				{
				for (x = 0; x < _values.width; x++)
					{
					cell = minesweeper_cell(_game, q_2d_value(SIZE)(x, y));
					origin.x = size.width  * (CGFloat)x;
					origin.y = size.height * (CGFloat)y;

					if (CELL_IS(DISCLOSED))
						{
						if (CELL_IS(EXPLODED))
							{
							SET_COLOR(Mine);
							textureName = &_textureNames[kTextureIndexExplosion];
							}

						else if (CELL_IS(WARNING))
							{
							SET_COLOR(Warning);
							textureName = &_textureNames[CELL_WARNING - 1];
							}

						else SET_COLOR(Clean);
						}

					else	{
						if (CELL_IS(FLAG))
							{
							if (_state != kBoardStateGame && CELL_IS(MINE) && showGoodFlags)
								SET_COLOR(ConfirmedFlag);

							else SET_COLOR(Flag);

							textureName = &_textureNames[kTextureIndexFlag];
							}

						else	{
							if (showMines && CELL_IS(MINE))
								textureName = &_textureNames[kTextureIndexMine];

							SET_COLOR(Covered);
							}
						}

					glBindTexture(GL_TEXTURE_2D, 0); 
					glBegin(GL_QUADS);
						glVertex2d(origin.x,		  origin.y		);
						glVertex2d(origin.x + size.width, origin.y		);
						glVertex2d(origin.x + size.width, origin.y + size.height);
						glVertex2d(origin.x,		  origin.y + size.height);
					glEnd();

					if (textureName != NULL)
						{
						//SET_COLOR(Warning);
						tx = ceil(origin.x);
						ty = ceil(origin.y);

						glBindTexture(GL_TEXTURE_2D, *textureName);
						glBegin(GL_QUADS);
							glTexCoord2d(0.0, 0.0); glVertex2d(tx,		      ty + _textureSize);
							glTexCoord2d(1.0, 0.0); glVertex2d(tx + _textureSize, ty + _textureSize);
							glTexCoord2d(1.0, 1.0); glVertex2d(tx + _textureSize, ty);
							glTexCoord2d(0.0, 1.0); glVertex2d(tx,		      ty);
						glEnd();
						textureName = NULL;
						}

					if (alternate) paletteIndex = !paletteIndex;
					}

				if (alternate && !(_values.width & 1)) paletteIndex = !paletteIndex;
				}

//			if (_flags.isInWinAnimation) [self drawFireworks];
			glDisable(GL_TEXTURE_2D);
			glDisable(GL_BLEND);
			}

		[[self openGLContext] flushBuffer];
		}


	- (void) reshape
		{
		if (_game != NULL)
			{
			[[self openGLContext] makeCurrentContext];
			/*CGLError error = 0;
			CGLContextObj context = CGLGetCurrentContext();*/
 
/*			// Enable the multi-threading
			error = CGLEnable(context, kCGLCEMPEngine);
 
			if (error != kCGLNoError)
				{
				NSLog(@"OpenGL mutithreading not available");
				// Multi-threaded execution is possibly not available
				// Insert your code to take appropriate action
				}*/

			_surfaceSize = [self respondsToSelector: @selector(convertSizeToBacking:)]
				? [self convertSizeToBacking: self.bounds.size]
				: self.bounds.size;

			_textureSize = floor(_surfaceSize.width / (CGFloat)_values.width);

			//----------------------------------------------.
			// Destruimos las texturas actuales si existen. |
			//----------------------------------------------'
			if (_flags.texturesCreated) glDeleteTextures(11, _textureNames);

			//------------------------------------------------.
			// Avisamos de que las texturas han sido creadas. |
			//------------------------------------------------'
			_flags.texturesCreated = YES;

			//------------------------------------------------.
			// Creamos nuevas texturas para el tamaño actual. |
			//------------------------------------------------'
			[self setTextureGraphicContext];
			[self createNumberTextures];
			[self createImageTextures];
			[NSGraphicsContext restoreGraphicsState];

			//---------------------------------------.
			// Configuramos la proyección de OpenGL. |
			//---------------------------------------'
			/*glViewport(0, 0, size.width, size.height);
			glLoadIdentity();
			glOrtho(0, size.width, 0, size.height, -1, 1);*/
			glViewport(0, 0, _surfaceSize.width, _surfaceSize.height);
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			glOrtho(0.0, _surfaceSize.width, 0.0, _surfaceSize.height, -1.0, 1.0);
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			}
		}


	- (void) mouseDown: (NSEvent *) event
		{_coordinates = [self cellCoordinatesOfEvent: event];}


	- (void) rightMouseDown: (NSEvent *) event
		{_coordinates = [self cellCoordinatesOfEvent: event];}


	- (void) mouseUp: (NSEvent *) event
		{
		if (	_state == kBoardStateGame &&
			q_2d_value_are_equal(SIZE)(_coordinates, [self cellCoordinatesOfEvent: event])
		)
			{
			if ([event clickCount] > 1 || _leftButtonAction == kBoardButtonActionReveal)
				[self revealRemaining];

			else if (_leftButtonAction == kBoardButtonActionFlag) [self toggleFlag];

			else [self discloseCell];
			}
		}


	- (void) rightMouseUp: (NSEvent *) event
		{
		if (	_state == kBoardStateGame &&
			q_2d_value_are_equal(SIZE)(_coordinates, [self cellCoordinatesOfEvent: event])
		)
			[self toggleFlag];
		}


#	pragma mark - Public


	- (void) setTheme: (Theme	   *) theme
		 images:   (NSMutableArray *) images
		{
		_theme.owner = nil;
		[_theme release];
		(_theme = [theme retain]).owner = self;
		_flags.alternateCells = theme.alternateCells;
		_cellBrightnessDelta  = theme.cellBrightnessDelta;
		for (NSUInteger key = 0; key < 6; key++) [self updateCellColorsForKey: key];

		if (images && images != _themeImages)
			{
			[_themeImages release];
			_themeImages = [images retain];

			if (_game)
				{
				if (_flags.texturesCreated) glDeleteTextures(11, _textureNames);
				[self setTextureGraphicContext];
				[self createNumberTextures];
				[self createImageTextures];
				[NSGraphicsContext restoreGraphicsState];
				self.needsDisplay = YES;
				}
			}
		}


	- (void) newGameWithValues: (GameValues) values
		{
		GameValues oldValues = _values;

		_values = values;
		_state = kBoardStateGame;
		[self ensureGameIsCreated];
		minesweeper_prepare(_game, q_2d_value(SIZE)(values.width, values.height), values.mineCount);

		if (values.width != oldValues.width || values.height != oldValues.height)
			self.bounds = self.bounds;

		self.needsDisplay = YES;
		}


	- (void) restart
		{
		_state = kBoardStateGame;

		minesweeper_prepare
			(_game, q_2d_value(SIZE)(_values.width, _values.height),
			 minesweeper_mine_count(_game));

		self.needsDisplay = YES;
		}


	- (BOOL) hintCoordinates: (Q2DSize *) coordinates
		{return minesweeper_hint(_game, coordinates);}


	- (void) discloseHintCoordinates: (Q2DSize) coordinates
		{
		minesweeper_disclose(_game, coordinates);

		if (minesweeper_state(_game) == MINESWEEPER_STATE_SOLVED)
			{
			_state = kBoardStateResolved;
			minesweeper_flag_all_mines(_game);
			}

		self.needsDisplay = YES;
		}


	- (size_t) snapshotSize
		{return (size_t)minesweeper_snapshot_size(_game);}


	- (void) snapshot: (void *) output
		{minesweeper_snapshot(_game, output);}


	- (void) setSnapshot: (void *) snapshot
		 ofSize:      (size_t) snapshotSize
		{
		[self ensureGameIsCreated];
		minesweeper_set_snapshot(_game, snapshot, snapshotSize);

		Q2DSize size = minesweeper_size(_game);
		_values.width	  = size.x;
		_values.height	  = size.y;
		_values.mineCount = minesweeper_mine_count(_game);

		if ((_state = minesweeper_state(_game)) == MINESWEEPER_STATE_PRISTINE)
			_state = kBoardStateGame;

		self.bounds	  = self.bounds;
		self.needsDisplay = YES;
		}


	- (NSRect) frameForCoordinates: (Q2DSize) coordinates
		{
		NSSize size = self.bounds.size;

		NSSize cellSize = NSMakeSize
			(size.width  / (CGFloat)_values.width,
			 size.height / (CGFloat)_values.height);

		return NSMakeRect
			(cellSize.width	 * (CGFloat)coordinates.x,
			 cellSize.height * (CGFloat)coordinates.y,
			 cellSize.width, cellSize.height);
		}


@end

// EOF
