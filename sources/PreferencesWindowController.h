/* Mines - PreferencesWindowController.h
   __  __
  /  \/  \  __ ___  ____   ____
 /	  \(__)   \/  -_)_/  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Betty Lab.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>
#import "Board.h"
#import "TableView.h"
#import "SeparatorCell.h"
#import "ImagePicker.h"

@interface PreferencesWindowController : NSWindowController
	<NSTableViewDataSource, TableViewDelegate, ImagePickerDelegate> {

	IBOutlet NSUserDefaultsController* defaultsController;

	//---------------.
	// Content Views |
	//---------------'
	IBOutlet NSView* generalView;
	IBOutlet NSView* effectsView;
	IBOutlet NSView* themeView;

	//-----------.
	// Theme Tab |
	//-----------'
	IBOutlet TableView*	     themeList;
	IBOutlet NSSegmentedControl* themeActionsSegmentedControl;
	IBOutlet NSColorWell*	     laserColorWell;
	IBOutlet NSPopUpButton*	     mineFoundAnimationButton;
	IBOutlet NSBox*		     cellsBox;
	IBOutlet NSButton*	     gridCheck;
	IBOutlet NSColorWell*	     gridColorWell;
	IBOutlet NSButton*	     cellBorderCheck;
	IBOutlet NSButton*	     mineCellBorderCheck;
	IBOutlet NSSlider*	     cellBorderSizeSlider;
	IBOutlet NSButton*	     alternateCoveredCellsCheck;
	IBOutlet NSButton*	     alternateUncoveredCellsCheck;
	IBOutlet NSSlider*	     cellBrightnessDeltaSlider;
	IBOutlet NSBox*		     numbersBox;
	IBOutlet NSTextField*	     numberFontNameTextField;
	IBOutlet NSButton*	     numberFontButton;
	IBOutlet NSSlider*	     numberFontSizeSlider;
	IBOutlet NSBox*		     imagesBox;

	SeparatorCell*	_separatorCell;
	Board*		_board;
	NSMutableArray* _bundleThemes;
	NSMutableArray*	_userThemes;
	Theme*		_theme;
	NSMutableArray* _themeImages;
	NSView*		_currentView;
	NSUInteger	_imageIndex;
	NSColor*	_imageBackgroundColor;
	ImagePicker*	_imagePicker;

	struct {BOOL doNotSelectRow  :1;
		BOOL themeIsUnsaved  :1;
		BOOL themeHasChanged :1;
	} _flags;
}
	- (id) initWithBoard: (Board *) board;

	- (IBAction) tab:			    (id) sender;
	- (IBAction) setLaserColor:		    (id) sender;
	- (IBAction) setMineFoundAnimation:	    (id) sender;
	- (IBAction) testMineFoundAnimation:	    (id) sender;
	- (IBAction) toggleGrid:		    (id) sender;
	- (IBAction) setGridColor:		    (id) sender;
	- (IBAction) toggleCellBorder:		    (id) sender;
	- (IBAction) toggleMineCellBorder:	    (id) sender;
	- (IBAction) setBorderSize:		    (id) sender;
	- (IBAction) toggleAlternateCoveredCells:   (id) sender;
	- (IBAction) toggleAlternateUncoveredCells: (id) sender;
	- (IBAction) setCellBrightnessDelta:	    (id) sender;
	- (IBAction) setCellColor:		    (id) sender;
	- (IBAction) setNumberColor:		    (id) sender;
	- (IBAction) setNumberFontSize:		    (id) sender;
	- (IBAction) toggleImageColor:		    (id) sender;
	- (IBAction) setImageColor:		    (id) sender;
	- (IBAction) selectImage:		    (id) sender;
	- (IBAction) performThemeListAction:	    (id) sender;
@end

// EOF
