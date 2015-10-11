/* Mines - migrations.h
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "Theme.h"

Theme* MigratedUserThemeFrom_v1 (NSDictionary*    themeDictionary,
				 NSMutableArray** images,
				 NSError**        error);

// EOF
