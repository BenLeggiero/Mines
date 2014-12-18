/* Mines - PreferencesController.h
 __  __
|  \/  | __  ____  ___  ____
|      |(__)|    |/ -_)(__ <
|__\/__||__||__|_|\___//___/
Copyright © 2013-2014 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>
#import "Board.h"
#import "TableView.h"
#import "SeparatorCell.h"
#import "ImagePicker.h"

@interface PreferencesController : NSWindowController
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
	IBOutlet NSColorWell*	     coveredColorWell;
	IBOutlet NSColorWell*	     cleanColorWell;
	IBOutlet NSColorWell*	     flagColorWell;
	IBOutlet NSColorWell*	     confirmedFlagColorWell;
	IBOutlet NSColorWell*	     mineColorWell;
	IBOutlet NSColorWell*	     warningColorWell;
	IBOutlet NSButton*	     cellBrightnessAlternationButton;
	IBOutlet NSSlider*	     cellBrightnessDeltaSlider;
	IBOutlet NSColorWell*	     warning1FontColorWell;
	IBOutlet NSColorWell*	     warning2FontColorWell;
	IBOutlet NSColorWell*	     warning3FontColorWell;
	IBOutlet NSColorWell*	     warning4FontColorWell;
	IBOutlet NSColorWell*	     warning5FontColorWell;
	IBOutlet NSColorWell*	     warning6FontColorWell;
	IBOutlet NSColorWell*	     warning7FontColorWell;
	IBOutlet NSColorWell*	     warning8FontColorWell;
	IBOutlet NSTextField*	     fontNameTextField;
	IBOutlet NSButton*	     fontButton;
	IBOutlet NSSlider*	     fontScalingSlider;
	IBOutlet NSImageView*	     flagImageView;
	IBOutlet NSColorWell*	     flagImageColorWell;
	IBOutlet NSImageView*	     mineImageView;
	IBOutlet NSColorWell*	     mineImageColorWell;
	IBOutlet NSImageView*	     explosionImageView;
	IBOutlet NSColorWell*	     explosionImageColorWell;

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

	- (IBAction) tab:			     (id) sender;
	- (IBAction) changeCellColor:		     (id) sender;
	- (IBAction) toggleCellBightnessAlternation: (id) sender;
	- (IBAction) changeCellBrightnessDelta:	     (id) sender;
	- (IBAction) changeNumberColor:		     (id) sender;
	- (IBAction) changeFont:		     (id) sender;
	- (IBAction) changeFontScaling:		     (id) sender;
	- (IBAction) changeImageTemplateColor:	     (id) sender;
	- (IBAction) selectImage:		     (id) sender;
	- (IBAction) performThemeAction:	     (id) sender;
@end

// EOF
