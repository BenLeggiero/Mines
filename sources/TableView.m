/* Mines - TableView.m
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "TableView.h"
#import "Theme.h"


@implementation TableView


	- (BOOL) textShouldEndEditing: (NSText *) text
		{
		id <TableViewDelegate> delegate = (id <TableViewDelegate>)self.delegate;

		return (delegate && [delegate respondsToSelector: @selector(tableViewShouldEndEditing:)])
			? [delegate tableViewShouldEndEditing: text.string]
			: YES;
		}


	- (void) textDidEndEditing: (NSNotification *) notification
		{
		[super textDidEndEditing: notification];

		id <TableViewDelegate> delegate = (id <TableViewDelegate>)self.delegate;

		if (delegate && [delegate respondsToSelector: @selector(tableViewDidEndEditing)])
			[delegate tableViewDidEndEditing];
		}


@end

// EOF
