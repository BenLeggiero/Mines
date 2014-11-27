/* Mines - MainController.h
 __  __
|  \/  | __  ____  ___  ____
|      |(__)|    |/ -_)(__ <
|__\/__||__||__|_|\___//___/
Copyright © 2013-2014 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>
#import "AboutController.h"
#import "PreferencesController.h"
#import "Board.h"
#import "Cannon.h"
#import "Explosion.h"
#import "Fireworks.h"
#import "GameOverView.h"
#import "ALSound.h"

@interface MainController : NSWindowController
	<NSApplicationDelegate, NSWindowDelegate, NSTextFieldDelegate,
	 CannonDelegate, BoardDelegate> {

	IBOutlet NSUserDefaultsController* defaultsController;

	//-----------.
	// Main menu |
	//-----------'
	IBOutlet NSMenuItem* minesShownMenuItem;

	//---------.
	// Toolbar |
	//---------'
	IBOutlet NSToolbarItem*	hintToolbarItem;
	IBOutlet NSView*	leftCounterView;
	IBOutlet NSToolbarItem*	leftCounterToolbarItem;
	IBOutlet NSTextField*	leftCounterTitleTextField;
	IBOutlet NSTextField*	leftCounterValueTextField;
	IBOutlet NSView*	rightCounterView;
	IBOutlet NSToolbarItem* rightCounterToolbarItem;
	IBOutlet NSTextField*	rightCounterTitleTextField;
	IBOutlet NSTextField*	rightCounterValueTextField;

	//------------.
	// Status bar |
	//------------'
	IBOutlet NSButton*    totalMinesSymbolButton;
	IBOutlet NSTextField* totalMinesValueTextField;
	IBOutlet NSButton*    currentFlagsSymbolButton;
	IBOutlet NSTextField* currentFlagsValueTextField;
	IBOutlet NSTextField* timeElapsedValueTextField;

	//-----------------.
	// New game window |
	//-----------------'
	IBOutlet NSButton*	playButton;
	IBOutlet NSTabView*	gameTypeTabView;
	IBOutlet NSTabViewItem*	typicalGameTabViewItem;
	IBOutlet NSMatrix*	typicalGameMatrix;
	IBOutlet NSTextField*	boardWidthATextField;
	IBOutlet NSTextField*	boardWidthBTextField;
	IBOutlet NSTextField*	boardHeightATextField;
	IBOutlet NSTextField*	boardHeightBTextField;
	IBOutlet NSTextField*	boardMineCountTextField;
	IBOutlet NSTextField*	boardCustomWidthTextField;
	IBOutlet NSTextField*	boardCustomHeightTextField;
	IBOutlet NSTextField*	boardCustomMineCountTextField;
	IBOutlet NSButton*	timeLimitButton;
	IBOutlet NSTextField*	timeLimitTextField;
	IBOutlet NSTextField*	timeLimitUnitTextField;

	//---------------.
	// Main controls |
	//---------------'
	IBOutlet GameOverView* gameOverView;
	IBOutlet NSWindow*     newGameWindow;
	IBOutlet Board*        board;

	//-------------------.
	// Private variables |
	//-------------------'
	Cannon*		       _cannon;
	Explosion*	       _explosion;
	Fireworks*	       _fireworks;
	ALSound*	       _discloseSound;
	ALSound*	       _explosionSound;
	ALSound*	       _laserBeamSound;
	ALSound*	       _taDahSound;
	Q2DSize		       _hintCoordinates;
	NSUInteger	       _allowedTime;
	NSUInteger	       _timeLeft;
	NSTimer*	       _gameOverTimer;
	NSString*	       _snapshotPath;
	AboutController*       _aboutController;
	PreferencesController* _preferencesController;
	BOOL		       _busy;
	BOOL		       _toolbarWasVisibleBeforeResize;
	CGFloat		       _defaultCellSize;

	struct {BOOL showMines			 :1;
		BOOL toolbarHidden		 :1;
		BOOL busy			 :1;
		BOOL maintainCellAspectRatio	 :1;
		BOOL rememberGameSettings	 :1;
		BOOL resumeLastGameOnLaunch	 :1;
		BOOL playSoundOnCellsDisclosed	 :1;
		BOOL playSoundOnGameSolved	 :1;
		BOOL playSoundOnMineFound	 :1;
		BOOL playSoundOnHint		 :1;
		BOOL viewAnimationOnGameSolved	 :1;
		BOOL viewAnimationOnMineFound	 :1;
		BOOL viewAnimationOnHint	 :1;
		BOOL userDoesntCareSmallCellSize :1;
	} _flags;
}
	//-------------------.
	// Main menu actions |
	//-------------------'
	- (IBAction) about:		      (id) sender;
	- (IBAction) preferences:	      (id) sender;
	- (IBAction) new:		      (id) sender;
	- (IBAction) restart:		      (id) sender;
	- (IBAction) open:		      (id) sender;
	- (IBAction) save:		      (id) sender;
	- (IBAction) saveAs:		      (id) sender;
	- (IBAction) toggleShowMines:	      (id) sender;
	- (IBAction) toggleInputIsAlwaysFlag: (id) sender;

	//-------------------------.
	// New game dialog actions |
	//-------------------------'
	- (IBAction) changeDifficulty: (id) sender;
	- (IBAction) toggleTimeLimit:  (id) sender;
	- (IBAction) playNewGame:      (id) sender;
	- (IBAction) cancelNewGame:    (id) sender;
@end

// EOF
