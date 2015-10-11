/* Mines - TableView.h
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
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
