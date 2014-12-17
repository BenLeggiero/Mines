/* Mines - Theme.h
 __  __
|  \/  | __  ____  ___  ____
|      |(__)|    |/ -_)(__ <
|__\/__||__||__|_|\___//___/
Copyright © 2013-2014 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>

#define kThemeColorKeyCovered	    0
#define kThemeColorKeyClean	    1
#define kThemeColorKeyFlag	    2
#define kThemeColorKeyConfirmedFlag 3
#define kThemeColorKeyMine	    4
#define kThemeColorKeyWarning	    5

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
	BOOL		_alternateCells;
}
	@property (nonatomic, assign   ) id		 owner;
	@property (nonatomic, retain   ) NSString*	 name;
	@property (nonatomic, readwrite) BOOL		 alternateCells;
	@property (nonatomic, readwrite) CGFloat	 cellBrightnessDelta;
	@property (nonatomic, readwrite) CGFloat	 fontScaling;
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
