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
#define kThemeImageKeyMine	    1
#define kThemeImageKeyExplosion     2

@protocol ThemeOwner

	- (void) updateNumbers;

	- (void) updateNumber: (NSUInteger) number;

	- (void) updateImageWithKey: (NSUInteger) key;

	- (void) updateColorWithKey: (NSUInteger) key;

	- (void) updateAlternateColors;

@end

@interface Theme : NSObject {
	id <ThemeOwner>	_owner;
	NSString*	_name;
	NSString*	_fontName;
	CGFloat		_fontScaling;
	CGFloat		_cellBrightnessDelta;
	NSMutableArray* _cellColors;
	NSMutableArray* _numberColors;
	NSMutableArray*	_imageColors;
	NSMutableArray*	_imageFileNames;
	BOOL		_imageInclusions[3];
	BOOL		_flat;
}
	@property (nonatomic, assign   ) id		 owner;
	@property (nonatomic, retain   ) NSString*	 name;
	@property (nonatomic, assign   ) BOOL		 flat;
	@property (nonatomic, assign   ) CGFloat	 cellBrightnessDelta;
	@property (nonatomic, assign   ) CGFloat	 fontScaling;
	@property (nonatomic, retain   ) NSString*	 fontName;
	@property (nonatomic, readonly ) NSMutableArray* imageFileNames;
	@property (nonatomic, readonly ) BOOL*		 imageInclusions /*NS_RETURNS_INNER_POINTER*/;

	+ (NSArray *) internalDictionaries;

	+ (BOOL) validateDictionary: (NSDictionary *) dictionary;

	- (id) initWithDictionary: (NSDictionary *) dictionary;

	- (NSDictionary *) dictionary;

	- (Theme *) copyWithName: (NSString *) name;

	- (NSColor *) colorForKey: (NSUInteger) key;

	- (void) setColor: (NSColor  *) color
		 forKey:   (NSUInteger)	key;

	- (NSColor *) colorForNumber: (NSUInteger) number;

	- (void) setColor:  (NSColor  *) color
		 forNumber: (NSUInteger) number;

	- (NSColor *) imageColorForKey: (NSUInteger) key;

	- (void) setImageColor: (NSColor  *) color
		 forKey:	(NSUInteger) key;

	- (void) setImageColor: (NSColor  *) color
		 fileName:	(NSString *) fileName
		 included:	(BOOL      ) included
		 forKey:	(NSUInteger) key;

	- (BOOL) hasExternalImages;

	- (NSMutableArray *) loadImages: (inout BOOL *) errors;

	- (BOOL) save: (NSError **) error;

	- (BOOL) remove: (NSError **) error;
@end

// EOF
