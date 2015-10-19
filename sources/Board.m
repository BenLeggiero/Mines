/* Mines - Board.m
   __  __
  /  \/  \  __ ___  ____   ____
 /	  \(__)   \/  -_)_/  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Betty Lab.
Released under the terms of the GNU General Public License v3. */

#import "Board.h"
#import "geometry.h"
#import <Z/functions/base/Z2DValue.h>

//@interface NSFont (PrivateGlyph)
//	- (NSGlyph) _defaultGlyphForChar: (unichar) theChar;
//@end

#define kTextureIndexFlag	 8
#define kTextureIndexGoodFlag	 9
#define kTextureIndexMine	10
#define kTextureIndexExplosion	11
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


void GameSnapshotValues(void *snapshot, size_t snapshotSize, GameValues *values)
	{
	Z2DUInt size;
	zuint mineCount;

	minesweeper_snapshot_values(snapshot, &snapshotSize, &size, &mineCount, NULL);

	values->width	  = size.x;
	values->height	  = size.y;
	values->mineCount = mineCount;
	}


#pragma mark - Board Class


@implementation Board


	# pragma mark - Helpers


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


	- (void) createTextureForImageAtIndex: (NSUInteger) index
		{
		NSColor *color;
		NSImage *image = [_themeImages objectAtIndex: index];
		NSRect frame = NSMakeRect(0.0, 0.0, _textureSize, _textureSize);

		[[NSColor clearColor] setFill];
		NSRectFill(frame);

		if ([image isKindOfClass: [NSImage class]])
			{
			frame = RectangleFitInCenter(frame, image.size);

			if ([(color = [_theme.imageColors objectAtIndex: index]) isEqualTo: [NSNull null]])
				{
				CGFloat components[4];

				[[color colorUsingColorSpace: [NSColorSpace deviceRGBColorSpace]] getComponents: components];
				//[color getComponents: components];

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

		_textures[8 + index] = [self createTextureFromBlock: [_bitmap bitmapData]];
		}


	- (void) createTextureForNumber: (NSUInteger) number
		{
		CGGlyph glyph;
		NSRect frame;
		NSBezierPath *path;
		NSAffineTransform *transform;

		NSFont *font = [NSFont
			fontWithName: _theme.numberFontName
			size:	      floor(_textureSize * _theme.numberFontScale)];

		CTFontGetGlyphsForCharacters((CTFontRef)font, &numbers_[number], &glyph, 1);
		//NSLog(@"%@", [font _defaultGlyphForChar: numbers[number]] == glyph ? @"YES" : @"NO");

#		ifdef DEBUG_GEOMETRY
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

#		ifdef DEBUG_GEOMETRY
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

		[[[_theme.numberColors objectAtIndex: number]
			colorUsingColorSpace: [NSColorSpace deviceRGBColorSpace]] setFill];

		[path fill];
		_textures[number] = [self createTextureFromBlock: [_bitmap bitmapData]];
		}


	- (void) createNumberTextures
		{
		NSUInteger c = 8;

		while (c) [self createTextureForNumber: --c];
		}


	- (void) createImageTextures
		{
		NSUInteger c = 4;

		while (c) [self createTextureForImageAtIndex: --c];
		}


	- (void) updateCellColorAtIndex: (NSUInteger) index
		{
		CGFloat  components[4];

		[[[_theme.cellColors objectAtIndex: index]
			colorUsingColorSpace: [NSColorSpace deviceRGBColorSpace]]
				getComponents: components];

		_cellColors[index][0] = components[0];
		_cellColors[index][1] = components[1];
		_cellColors[index][2] = components[2];
		}


	- (void) updateCellColors
		{
		NSUInteger c = _theme.cellColors.count;

		while (c) [self updateCellColorAtIndex: --c];
		}


	- (void) updateAlternateCellColorAtIndex: (NSUInteger) index
		{
		CGFloat delta = _theme.cellBrightnessDelta;
		GLfloat* color1 = _cellColors[index];
		GLfloat* color2 = _alternateCellColors[index];

		color2[0] = z_type_clamp_01(FLOAT)(color1[0] + delta);
		color2[1] = z_type_clamp_01(FLOAT)(color1[1] + delta);
		color2[2] = z_type_clamp_01(FLOAT)(color1[2] + delta);
		}


	- (void) updateAlternateCellColors
		{
		NSUInteger c = 7;

		while (c) [self updateAlternateCellColorAtIndex: --c];
		}


	- (Z2DUInt) cellCoordinatesOfEvent: (NSEvent *) event
		{
		NSPoint point = [self convertPoint: [event locationInWindow] fromView: nil];
		NSSize size   = self.bounds.size;

		return z_2d_type(UINT)
			((zuint)(point.x / (size.width  / (CGFloat)_values.width )),
			 (zuint)(point.y / (size.height / (CGFloat)_values.height)));
		}


	- (void) discloseCell
		{
		MinesweeperResult result = minesweeper_disclose(&_game, _coordinates);

		switch (result)
			{
			case 0:
			if (delegate) [delegate boardDidDiscloseCells: self];
			self.needsDisplay = YES;
			return;

			case MINESWEEPER_RESULT_SOLVED:
			_state = kBoardStateResolved;
			minesweeper_flag_all_mines(&_game);
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
		if (	_game.state == MINESWEEPER_STATE_PLAYING &&
			!MINESWEEPER_CELL_DISCLOSED
				(_game.matrix[_game.size.x * _coordinates.y + _coordinates.x])
		)
			{
			minesweeper_toggle_flag(&_game, _coordinates, NULL);
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


	- (zuint) width		{return _values.width;}
	- (zuint) height	{return _values.height;}
	- (zuint) mineCount	{return _values.mineCount;}
	- (zuint) flagCount	{return _game.flag_count;}
	- (zuint) clearedCount	{return minesweeper_disclosed_count(&_game);}
	- (BOOL)  showMines	{return _flags.showMines;}
	- (BOOL)  showGoodFlags	{return _flags.showGoodFlags;}


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


#	pragma mark - Overwritten


	- (id) initWithCoder: (NSCoder *) coder
		{
		if ((self = [super initWithCoder: coder]))
			{
			minesweeper_initialize(&_game);

			if ([self respondsToSelector: @selector(setWantsBestResolutionOpenGLSurface:)])
				[self setWantsBestResolutionOpenGLSurface: YES];
			}

		return self;
		}


	- (void) dealloc
		{
		if (_flags.texturesCreated) glDeleteTextures(12, _textures);
		minesweeper_finalize(&_game);

		[_theme	      release];
		[_themeImages release];
		[super	      dealloc];
		}


#	define SET_COLOR(color) glColor3fv(&_cellColors1[kThemeColorKey##color * 3])

	static GLdouble const cellVertices[4 * 2] = {0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0};

	static GLdouble const cellEdgeVertices[4][4 * 2] = {
		{0.0,	0.0,   1.0,   0.0,   0.875, 0.125, 0.125, 0.125}, // Bottom
		{0.875, 0.125, 1.0,   0.0,   1.0,   1.0,   0.875, 0.875}, // Right
		{0.125, 0.875, 0.875, 0.875, 1.0,   1.0,   0.0,   1.0  }, // Top
		{0.0,	0.0,   0.125, 0.125, 0.125, 0.875, 0.0,	  1.0  }, // Left
	};

	- (void) drawRect: (NSRect) frame
		{
		if (_game.state == MINESWEEPER_STATE_INITIALIZED)
			{
			glClearColor(0.0, 0.0, 0.0, 1.0);
			glClear(GL_COLOR_BUFFER_BIT);
			}

		else	{
			MinesweeperCell cell;

			glEnable(GL_BLEND);
			glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
			glEnable(GL_TEXTURE_2D);
			glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

#			ifdef DEBUG_GEOMETRY
				glClearColor
					(palette[paletteIndex][kThemeColorKeyClean * 3],
					 palette[paletteIndex][kThemeColorKeyClean * 3 + 1],
					 palette[paletteIndex][kThemeColorKeyClean * 3 + 2],
					 1);

				glClear(GL_COLOR_BUFFER_BIT);
#			endif

			GLdouble cellX;
			GLdouble cellY;
			GLint	 x, y;
			NSUInteger textureIndex = NSNotFound;
			BOOL	 showMines     = _flags.showMines;
			BOOL	 showGoodFlags = _flags.showGoodFlags;
			GLdouble cellWidth     = _surfaceSize.width  / (GLdouble)_values.width;
			GLdouble cellHeight    = _surfaceSize.height / (GLdouble)_values.height;
			zuint	 colorIndex;

			glEnableClientState(GL_VERTEX_ARRAY);
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();

			/*if (_theme.cellBorder) for (y = 0; y < _values.height; y++) for (x = 0; x < _values.width; x++)
				{
				cell = minesweeper_cell(&_game, z_2d_type(SIZE)(x, y));

				if (CELL_IS(DISCLOSED))
					{
					if (CELL_IS(EXPLODED))
						{
						colorIndex = kThemeIndexMine;
						textureIndex = kTextureIndexExplosion;
						}

					else if (CELL_IS(WARNING))
						{
						colorIndex = kThemeIndexWarning;
						textureIndex = CELL_WARNING - 1;
						}

					else colorIndex = kThemeIndexClean;
					}

				else	{
					if (CELL_IS(FLAG))
						{
						colorIndex = (_state != kBoardStateGame && CELL_IS(MINE) && showGoodFlags)
							? kThemeIndexGoodFlag
							: kThemeIndexFlag;

						textureIndex = kTextureIndexFlag;
						}

					else	{
						if (showMines && CELL_IS(MINE))
							textureIndex = kTextureIndexMine;

						colorIndex = kThemeColorKeyCovered;
						}
					}

				glColor3fv(_cellColors1[colorIndex]);

				glPushMatrix();
				glTranslated(cellX = cellWidth * (GLdouble)x, cellY = cellHeight * (GLdouble)y, 0.0);
				glScaled(cellWidth, cellHeight, 1.0);
				glBindTexture(GL_TEXTURE_2D, 0);
				glVertexPointer(2, GL_DOUBLE, 0, cellVertices);
				glDrawArrays(GL_QUADS, 0, 4);

				if (!CELL_IS(DISCLOSED)) for (zuint edgeIndex = 0; edgeIndex < 4; edgeIndex++)
					{
					glColor3fv(_cellColors2[colorIndex][edgeIndex]);
					glVertexPointer(2, GL_DOUBLE, 0, &cellEdgeVertices[edgeIndex][0]);
					glDrawArrays(GL_QUADS, 0, 4);
					}

				glPopMatrix();

				if (textureIndex != NSNotFound)
					{
					//SET_COLOR(Warning);
					glPushMatrix();
					glTranslated(ceil(cellX), ceil(cellY), 0.0);
					glScaled(_textureSize, _textureSize, 1.0);
					glBindTexture(GL_TEXTURE_2D, _textures[textureIndex]);
					glBegin(GL_QUADS);
						glTexCoord2d(0.0, 0.0); glVertex2d(0.0,	1.0);
						glTexCoord2d(1.0, 0.0); glVertex2d(1.0, 1.0);
						glTexCoord2d(1.0, 1.0); glVertex2d(1.0, 0.0);
						glTexCoord2d(0.0, 1.0); glVertex2d(0.0, 0.0);
					glEnd();
					glPopMatrix();
					textureIndex = NSNotFound;
					}
				}

			else	{*/
				GLfloat *palette[2] = {_cellColors[0], _alternateCellColors[0]};
				NSInteger paletteIndex = 0;

				for (y = 0; y < _values.height; y++)
					{
					for (x = 0; x < _values.width; x++, paletteIndex = !paletteIndex)
						{
						cell = _game.matrix[_game.size.x * y + x];

						if (CELL_IS(DISCLOSED))
							{
							if (CELL_IS(EXPLODED))
								{
								colorIndex = kThemeIndexMine;
								textureIndex = kTextureIndexExplosion;
								}

							else if (CELL_IS(WARNING))
								{
								colorIndex = kThemeIndexWarning;
								textureIndex = CELL_WARNING - 1;
								}

							else colorIndex = kThemeIndexClean;

							glColor3fv(_cellColors[colorIndex]);
							}

						else	{
							if (CELL_IS(FLAG))
								{
								colorIndex = (_state != kBoardStateGame && CELL_IS(MINE) && showGoodFlags)
									 ? kThemeIndexGoodFlag
									 : kThemeIndexFlag;

								textureIndex = kTextureIndexFlag;
								}

							else	{
								if (showMines && CELL_IS(MINE))
									{
									colorIndex = kThemeIndexMine;
									textureIndex = kTextureIndexMine;
									}
								
								else colorIndex = kThemeIndexUnknown;

								glColor3fv(&palette[paletteIndex][colorIndex * 3]);
								}
							}

						glPushMatrix();
						glTranslated(cellX = cellWidth * (GLdouble)x, cellY = cellHeight * (GLdouble)y, 0.0);
						glScaled(cellWidth, cellHeight, 1.0);
						glBindTexture(GL_TEXTURE_2D, 0);
						glVertexPointer(2, GL_DOUBLE, 0, cellVertices);
						glDrawArrays(GL_QUADS, 0, 4);
						glPopMatrix();

						if (textureIndex != NSNotFound)
							{
							//SET_COLOR(Warning);
							glPushMatrix();
							glTranslated(ceil(cellX), ceil(cellY), 0.0);
							glScaled(_textureSize, _textureSize, 1.0);
							glBindTexture(GL_TEXTURE_2D, _textures[textureIndex]);
							glBegin(GL_QUADS);
								glTexCoord2d(0.0, 0.0); glVertex2d(0.0,	1.0);
								glTexCoord2d(1.0, 0.0); glVertex2d(1.0, 1.0);
								glTexCoord2d(1.0, 1.0); glVertex2d(1.0, 0.0);
								glTexCoord2d(0.0, 1.0); glVertex2d(0.0, 0.0);
							glEnd();
							glPopMatrix();
							textureIndex = NSNotFound;
							}
						}

					if (!(_values.width & 1)) paletteIndex = !paletteIndex;
					}
				//}

			glDisable(GL_TEXTURE_2D);
			glDisable(GL_BLEND);
			}

		[[self openGLContext] flushBuffer];
		}


	- (void) reshape
		{
		if (_game.state > MINESWEEPER_STATE_INITIALIZED)
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
			if (_flags.texturesCreated) glDeleteTextures(12, _textures);

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
			z_2d_type_are_equal(UINT)(_coordinates, [self cellCoordinatesOfEvent: event])
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
			z_2d_type_are_equal(UINT)(_coordinates, [self cellCoordinatesOfEvent: event])
		)
			[self toggleFlag];
		}


#	pragma mark - Public


	- (void) setTheme: (Theme	   *) theme
		 images:   (NSMutableArray *) images
		{
		[_theme release];
		_theme = [theme retain];
		[self updateCellColors];

		if (_theme.alternateCoveredCells || _theme.alternateUncoveredCells)
			[self updateAlternateCellColors];

		if (images && images != _themeImages)
			{
			[_themeImages release];
			_themeImages = [images retain];

			if (_game.state > MINESWEEPER_STATE_INITIALIZED)
				{
				if (_flags.texturesCreated) glDeleteTextures(12, _textures);
				[self setTextureGraphicContext];
				[self createNumberTextures];
				[self createImageTextures];
				[NSGraphicsContext restoreGraphicsState];
				self.needsDisplay = YES;
				}
			}
		}


	- (void) didChangeThemeProperty: (uint8_t) property
		 valueAtIndex:		 (uint8_t) index
		{
		switch (property)
			{
			case kThemePropertyGrid:
			case kThemePropertyGridColor:
			case kThemePropertyCellBorder:
			for (NSUInteger i = 7; i < 7 + 4 * 3; i++) [self updateCellColorAtIndex: i];
			break;

			case kThemePropertyCellBorderSize:

			case kThemePropertyAlternateCoveredCells:
			if (_theme.alternateCoveredCells) [self updateAlternateCellColors];
			break;

			case kThemePropertyAlternateUncoveredCells:
			if (_theme.alternateUncoveredCells) [self updateAlternateCellColors];
			break;

			case kThemePropertyCellBrightnessDelta:
			[self updateAlternateCellColors];
			break;

			case kThemePropertyCellColor:
			[self updateCellColorAtIndex: index];
			if (index < 7) [self updateAlternateCellColorAtIndex: index];
			break;

			case kThemePropertyNumberColor:
			if (_flags.texturesCreated) glDeleteTextures(1, &_textures[index]);
			[self setTextureGraphicContext];
			[self createTextureForNumber: index + 1];
			[NSGraphicsContext restoreGraphicsState];
			break;

			case kThemePropertyNumberFontName:
			case kThemePropertyNumberFontScale:
			if (_flags.texturesCreated) glDeleteTextures(8, _textures);
			[self setTextureGraphicContext];
			[self createNumberTextures];
			[NSGraphicsContext restoreGraphicsState];
			break;

			case kThemePropertyImage:
			case kThemePropertyImageColor:
			if (_flags.texturesCreated) glDeleteTextures(1, &_textures[8 + index]);
			[self setTextureGraphicContext];
			[self createTextureForImageAtIndex: index];
			[NSGraphicsContext restoreGraphicsState];
			break;

			default: break;
			}

		self.needsDisplay = YES;
		}


	- (void) newGameWithValues: (GameValues) values
		{
		GameValues oldValues = _values;

		minesweeper_prepare(&_game, z_2d_type(UINT)(values.width, values.height), values.mineCount);
		_values = values;
		_state = kBoardStateGame;

		if (values.width != oldValues.width || values.height != oldValues.height)
			self.bounds = self.bounds;

		self.needsDisplay = YES;
		}


	- (void) restart
		{
		minesweeper_prepare
			(&_game, z_2d_type(UINT)((zuint)_values.width, (zuint)_values.height),
			 _game.mine_count);

		_state = kBoardStateGame;
		self.needsDisplay = YES;
		}


	- (BOOL) hintCoordinates: (Z2DUInt *) coordinates
		{return minesweeper_hint(&_game, coordinates);}


	- (void) discloseHintCoordinates: (Z2DUInt) coordinates
		{
		minesweeper_disclose(&_game, coordinates);

		if (_game.state == MINESWEEPER_STATE_SOLVED)
			{
			_state = kBoardStateResolved;
			minesweeper_flag_all_mines(&_game);
			}

		self.needsDisplay = YES;
		}


	- (size_t) snapshotSize
		{return (size_t)minesweeper_snapshot_size(&_game);}


	- (void) snapshot: (void *) output
		{minesweeper_snapshot(&_game, output);}


	- (void) setSnapshot: (void *) snapshot
		 ofSize:      (size_t) snapshotSize
		{
		minesweeper_set_snapshot(&_game, snapshot, snapshotSize);

		_values.width	  = _game.size.x;
		_values.height	  = _game.size.y;
		_values.mineCount = _game.mine_count;

		if ((_state = _game.state) == MINESWEEPER_STATE_PRISTINE)
			_state = kBoardStateGame;

		self.bounds	  = self.bounds;
		self.needsDisplay = YES;
		}


	- (NSRect) frameForCoordinates: (Z2DUInt) coordinates
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
