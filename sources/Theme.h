/* Mines - Theme.h
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Betty Lab.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>

#define kThemeIndexUnknown   0
#define kThemeIndexFlag	     1
#define kThemeIndexGoodFlag  2
#define kThemeIndexMine	     3
#define kThemeIndexExplosion 4
#define kThemeIndexWarning   5
#define kThemeIndexClean     6


#define kThemePropertyGrid		      0
#define kThemePropertyGridColor		      1
#define kThemePropertyCellBorder	      2
#define kThemePropertyCellBorderSize	      3
#define kThemePropertyAlternateCoveredCells   4
#define kThemePropertyAlternateUncoveredCells 5
#define kThemePropertyCellBrightnessDelta     6
#define kThemePropertyCellColor		      7
#define kThemePropertyNumberColor	      8
#define kThemePropertyNumberFontName	      9
#define kThemePropertyNumberFontScale	     10
#define kThemePropertyImage		     11
#define kThemePropertyImageColor	     12

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
