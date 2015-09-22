/* Mines - Theme.h
 __  __
|  \/  | __  ____  ___	___
|      |(__)|    |/ -_)/_  \
|__\/__||__||__|_|\___/ /__/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>

#define kThemeIndexUnknown   0
#define kThemeIndexFlag	     1
#define kThemeIndexGoodFlag  2
#define kThemeIndexMine	     3
#define kThemeIndexExplosion 4
#define kThemeIndexClean     5
#define kThemeIndexWarning   6

#define kThemePropertyGrid		      0
#define kThemePropertyGridColor		      1
#define kThemePropertyCellBorder	      2
#define kThemePropertyMineCellBorder	      3
#define kThemePropertyCellBorderSize	      4
#define kThemePropertyAlternateCoveredCells   5
#define kThemePropertyAlternateUncoveredCells 6
#define kThemePropertyCellBrightnessDelta     7
#define kThemePropertyCellColor		      8
#define kThemePropertyNumberColor	      9
#define kThemePropertyNumberFontName	     10
#define kThemePropertyNumberFontScale	     11
#define kThemePropertyImage		     12
#define kThemePropertyImageColor	     13

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
	@property (nonatomic, readonly) NSMutableArray* imageFileNames;
	@property (nonatomic, readonly) NSMutableArray* imageColors;
	@property (nonatomic, readonly) BOOL*		imageInclusions;

	+ (NSArray *) internalDictionaries;

	+ (BOOL) validateDictionary: (NSDictionary *) dictionary;

	- (id) initWithDictionary: (NSDictionary *) dictionary;

	- (NSDictionary *) dictionary;

	- (Theme *) copyWithName: (NSString *) name;

	- (BOOL) hasExternalImages;

	- (NSMutableArray *) loadImages: (inout BOOL *) errors;

	- (BOOL) save: (NSError **) error;

	- (BOOL) remove: (NSError **) error;
@end

// EOF
