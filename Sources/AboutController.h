/* Mines - AboutController.h
 __  __
|  \/  | __  ____  ___  ____
|      |(__)|    |/ -_)(__ <
|__\/__||__||__|_|\___//___/
Copyright © 2013-2014 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>
#import "Explosion.h"
#import "ALSound.h"
#import "Link.h"

@interface AboutController : NSWindowController {
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
