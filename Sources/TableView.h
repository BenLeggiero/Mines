/* Mines - TableView.h
 __  __
|  \/  | __  ____  ___  ____
|      |(__)|    |/ -_)(__ <
|__\/__||__||__|_|\___//___/
Copyright © 2013-2014 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>
#import "Theme.h"

@interface TableView : NSTableView @end

@protocol TableViewDelegate <NSTableViewDelegate>

	- (BOOL) tableViewShouldEndEditing: (NSString *) string;
	- (void) tableViewDidEndEditing;

@end

// EOF
