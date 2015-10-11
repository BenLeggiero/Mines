/* Mines - AboutWindowController.h
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>
#import "Explosion.h"
#import "ALSound.h"
#import "Link.h"

@interface AboutWindowController : NSWindowController {
	IBOutlet NSButton*    mineButton;
	IBOutlet NSTextField* appNameTextField;
	IBOutlet NSTextField* versionTextField;
	IBOutlet NSTextField* copyrightTextField;
	IBOutlet Link*	      sourceCodeLinkLabel;

	Explosion* _explosion;
	ALSound*   _explosionSound;
	BOOL	   _mineExploding;
}
	- (IBAction) boom:	 (id) sender;
	- (IBAction) sourceCode: (id) sender;
@end

// EOF
