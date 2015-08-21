/* Mines - PreferencesWindowController.h
 __  __
|  \/  | __  ____  ___	___
|      |(__)|    |/ -_)/_  \
|__\/__||__||__|_|\___/ /__/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
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
	IBOutlet NSBox*		     cellsBox;
	IBOutlet NSButton*	     gridEnabledCheck;
	IBOutlet NSColorWell*	     gridColorWell;
	IBOutlet NSButton*	     bordersEnabledCheck;
	IBOutlet NSSlider*	     borderSizeSlider;
	IBOutlet NSButton*	     alternateCoveredCheck;
	IBOutlet NSButton*	     alternateUncoveredCheck;
	IBOutlet NSSlider*	     brightnessDeltaSlider;
	IBOutlet NSButton*	     mineBordersEnabledCheck;
	IBOutlet NSBox*		     numbersBox;
	IBOutlet NSTextField*	     fontNameTextField;
	IBOutlet NSButton*	     fontButton;
	IBOutlet NSSlider*	     fontSizeSlider;
	IBOutlet NSBox*		     imagesBox;

	SeparatorCell*	_separatorCell;
	Board*		_board;
	NSMutableArray* _bundleThemes;
	NSMutableArray*	_userThemes;
	Theme*		_theme;
	NSMutableArray* _themeImages;
	NSView*		_currentView;
	NSUInteger	_imageKey;
	NSColor*	_imageBackgroundColor;
	ImagePicker*	_imagePicker;

	struct {BOOL doNotSelectRow  :1;
		BOOL themeIsUnsaved  :1;
		BOOL themeHasChanged :1;
	} _flags;
}
	- (id) initWithBoard: (Board *) board;

	- (IBAction) tab:			      (id) sender;
	- (IBAction) setLaserColor:		      (id) sender;
	- (IBAction) setAnimation:		      (id) sender;
	- (IBAction) testAnimation:		      (id) sender;
	- (IBAction) toggleGrid:		      (id) sender;
	- (IBAction) setGridColor:		      (id) sender;
	- (IBAction) toggleBorders:		      (id) sender;
	- (IBAction) toggleMineBorders:		      (id) sender;
	- (IBAction) setBorderSize:		      (id) sender;
	- (IBAction) toggleCoveredCellsAlternation:   (id) sender;
	- (IBAction) toggleUncoveredCellsAlternation: (id) sender;
	- (IBAction) setBrightnessDelta:	      (id) sender;
	- (IBAction) setCellColor:		      (id) sender;
	- (IBAction) setNumberColor:		      (id) sender;
	- (IBAction) setFont:			      (id) sender;
	- (IBAction) setFontSize:		      (id) sender;
	- (IBAction) toggleImageColor:		      (id) sender;
	- (IBAction) setImageColor:		      (id) sender;
	- (IBAction) selectImage:		      (id) sender;
	- (IBAction) performThemeListAction:	      (id) sender;
@end

// EOF
