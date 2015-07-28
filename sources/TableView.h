/* Mines - TableView.h
 __  __
|  \/  | __  ____  ___	___
|      |(__)|    |/ -_)/_  \
|__\/__||__||__|_|\___/ /__/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>
#import "Theme.h"

@interface TableView : NSTableView @end

@protocol TableViewDelegate <NSTableViewDelegate>

	- (BOOL) tableViewShouldEndEditing: (NSString *) string;
	- (void) tableViewDidEndEditing;

@end

// EOF
