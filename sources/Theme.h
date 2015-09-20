/* Mines - Theme.h
 __  __
|  \/  | __  ____  ___	___
|      |(__)|    |/ -_)/_  \
|__\/__||__||__|_|\___/ /__/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>

#define kThemeColorKeyCovered	    0
#define kThemeColorKeyFlag	    1
#define kThemeColorKeyConfirmedFlag 2
#define kThemeColorKeyMine	    3
#define kThemeColorKeyWarning	    4
#define kThemeColorKeyClean	    5

#define kThemeImageKeyFlag	    0
#define kThemeImageKeyConfirmedFlag 1
#define kThemeImageKeyMine	    2
#define kThemeImageKeyExplosion     3

@protocol ThemeOwner

	- (void) updateNumbers;

	- (void) updateNumber: (NSUInteger) number;

	- (void) updateImageWithKey: (NSUInteger) key;

	- (void) updateColorWithKey: (NSUInteger) key;

	- (void) updateAlternateColors;

@end

@interface Theme : NSObject {
	NSString*	_name;
	NSColor*	_laserColor;
	NSString*	_mineFoundAnimation;
	NSColor*	_gridColor;
	CGFloat		_cellBorderSize;
	CGFloat		_cellBrightnessDelta;
	NSMutableArray* _cellColors;
	NSMutableArray* _numberColors;
	NSString*	_numberFontName;
	CGFloat		_numberFontScale;
	NSMutableArray*	_imageFileNames;
	NSMutableArray*	_imageColors;
	BOOL		_imageInclusions[4];

	struct {BOOL grid		     :1;
		BOOL cellBorder		     :1;
		BOOL mineCellBorder	     :1;
		BOOL alternateCoveredCells   :1;
		BOOL alternateUncoveredCells :1;
	} _flags;
}
	@property (nonatomic, retain  ) NSString*	name;
	@property (nonatomic, retain  ) NSColor*	laserColor;
	@property (nonatomic, retain  ) NSString*	mineFoundAnimation;
	@property (nonatomic, assign  ) BOOL		grid;
	@property (nonatomic, retain  ) NSColor*	gridColor;
	@property (nonatomic, assign  ) BOOL		cellBorder;
	@property (nonatomic, assign  ) BOOL		mineCellBorder;
	@property (nonatomic, assign  ) CGFloat		cellBorderSize;
	@property (nonatomic, assign  ) BOOL		alternateCoveredCells;
	@property (nonatomic, assign  ) BOOL		alternateUncoveredCells;
	@property (nonatomic, assign  ) CGFloat		cellBrightnessDelta;
	@property (nonatomic, readonly) NSMutableArray* cellColors;
	@property (nonatomic, readonly) NSMutableArray* numberColors;
	@property (nonatomic, retain  ) NSString*	numberFontName;
	@property (nonatomic, assign  ) CGFloat		numberFontScale;
	@property (nonatomic, readonly) NSMutableArray*	images;
	@property (nonatomic, readonly) NSMutableArray* imageColors;
	@property (nonatomic, readonly) BOOL*		imageInclusions;

	+ (NSArray *) internalDictionaries;

	+ (BOOL) validateDictionary: (NSDictionary *) dictionary;

	- (id) initWithDictionary: (NSDictionary *) dictionary;

	- (NSDictionary *) dictionary;

	- (Theme *) copyWithName: (NSString *) name;

	- (BOOL) hasExternalImages;

	- (NSMutableArray *) loadImages: (inout BOOL *) errors;

	- (void) unloadImages;

	- (BOOL) save: (NSError **) error;

	- (BOOL) remove: (NSError **) error;
@end

// EOF
