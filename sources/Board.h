/* Mines - Board.h
 __  __
|  \/  | __  ____  ___	___
|      |(__)|    |/ -_)/_  \
|__\/__||__||__|_|\___/ /__/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <AppKit/AppKit.h>
#import <OpenGL/gl.h>
#import "Minesweeper.h"
#import "Theme.h"

@class Board;

typedef struct {
	NSUInteger width;
	NSUInteger height;
	NSUInteger mineCount;
} GameValues;

typedef uint8_t BoardState;

#define kBoardStateNone     MINESWEEPER_STATE_INITIALIZED
#define kBoardStatePristine MINESWEEPER_STATE_PRISTINE
#define kBoardStateGame     MINESWEEPER_STATE_PLAYING
#define kBoardStateResolved MINESWEEPER_STATE_SOLVED
#define kBoardStateGameOver MINESWEEPER_STATE_EXPLODED

typedef uint8_t BoardButtonAction;

#define kBoardButtonActionNormal 0
#define kBoardButtonActionFlag	 1
#define kBoardButtonActionReveal 2

#define kBoardFireworkCount	 15
#define kBoardColorPaletteSize	 6


NS_INLINE BOOL GameValuesAreEqual(GameValues *a, const GameValues *b)
	{
	return	a->width     == b->width  &&
		a->height    == b->height &&
		a->mineCount == b->mineCount;
	}


BOOL GameSnapshotTest	(void*	     snapshot,
			 size_t	     snapshotSize);

BOOL GameSnapshotValues	(void*	     snapshot,
			 size_t	     snapshotSize,
			 GameValues* values);

@protocol BoardDelegate

	- (void) boardDidDiscloseCells: (Board *) board;

	- (void) boardDidChangeFlags: (Board *) board;

	- (void) boardDidWin: (Board *) board;

	- (void) board:			       (Board *) board
		 didDiscloseMineAtCoordinates: (Z2DSize) coordinates;

@end

@interface Board : NSOpenGLView {
	IBOutlet id <BoardDelegate> delegate;

	Minesweeper	  _game;
	GameValues	  _values;;
	NSSize		  _surfaceSize;
	CGFloat		  _textureSize;
	GLuint		  _textures[12];
	NSBitmapImageRep* _bitmap;
	Theme*		  _theme;
	NSMutableArray*	  _themeImages;
	GLfloat		  _gridColor[3];
	GLfloat		  _cellColors[23][3];
	GLfloat		  _alternateCellColors[7][3];
	BoardState	  _state;
	Z2DSize		  _coordinates;
	BoardButtonAction _leftButtonAction;

	struct {BOOL flat	     :1;
		BOOL showMines	     :1;
		BOOL showGoodFlags   :1;
		BOOL texturesCreated :1;
	} _flags;
}
	@property (nonatomic, readonly ) BoardState	   state;
	@property (nonatomic, readonly ) NSUInteger	   width;
	@property (nonatomic, readonly ) NSUInteger	   height;
	@property (nonatomic, readonly ) NSUInteger	   mineCount;
	@property (nonatomic, readonly ) NSUInteger	   flagCount;
	@property (nonatomic, readonly ) NSUInteger	   clearedCount;
	@property (nonatomic, readwrite) BOOL		   showMines;
	@property (nonatomic, readwrite) BOOL		   showGoodFlags;
	@property (nonatomic, readwrite) BoardButtonAction leftButtonAction;
	@property (nonatomic, readonly ) GameValues	   values;
	@property (nonatomic, readonly ) Theme*		   theme;
	@property (nonatomic, readonly ) NSMutableArray*   themeImages;

	- (void) setTheme: (Theme	   *) theme
		 images:   (NSMutableArray *) images;

	- (void) didChangeThemeProperty: (uint8_t) property
		 valueAtIndex:		 (uint8_t) index;

	- (void) newGameWithValues: (GameValues) values;

	- (void) restart;

	- (BOOL) hintCoordinates: (Z2DSize *) coordinates;

	- (void) discloseHintCoordinates: (Z2DSize) coordinates;

	- (size_t) snapshotSize;

	- (void) snapshot: (void *) output;

	- (void) setSnapshot: (void *) snapshot
		 ofSize:      (size_t) snapshotSize;

	- (NSRect) frameForCoordinates: (Z2DSize) coordinates;
@end

// EOF
