/* Mines - AboutWindowController.m
   __  __
  /  \/  \  __ ___  ____   ____
 /	  \(__)   \/  -_)_/  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Betty Lab.
Released under the terms of the GNU General Public License v3. */

#import "AboutWindowController.h"


@implementation AboutWindowController


#	pragma mark - Overwritten


	- (id) init
		{
		if ((self = [super initWithWindowNibName: @"About"]))
			{
			_explosion = [[Explosion alloc] init];
			_explosionSound = [[ALSound soundNamed: @"Explosion.wav"] retain];
			}

		return self;
		}


	- (void) dealloc
		{
		[self.window orderOut: self];
		[_explosion cancelExplosion];
		[_explosion release];
		[_explosionSound release];
		[super dealloc];
		}


	- (void) windowDidLoad
		{
		[super windowDidLoad];
		NSBundle *bundle = [NSBundle mainBundle];
		NSImage *image = [NSApp applicationIconImage];

		if (!NSEqualSizes(image.size, NSMakeSize(128.0, 128.0)))
			{
			image = [NSImage imageNamed: @"Mines.icns"];
			image.size = NSMakeSize(128.0, 128.0);
			}

		[mineButton.cell setHighlightsBy: 0];

		mineButton.image	       = image;
		appNameTextField.stringValue   = [bundle objectForInfoDictionaryKey: @"CFBundleDisplayName"];
		copyrightTextField.stringValue = [bundle objectForInfoDictionaryKey: @"NSHumanReadableCopyright"];

		versionTextField.stringValue = STRING
			(@"%@ %@ (%@)", _("Version"),
			 [bundle objectForInfoDictionaryKey: @"CFBundleShortVersionString"],
			 [bundle objectForInfoDictionaryKey: @"CFBundleVersion"]);

		sourceCodeLinkLabel.stringValue = _("SourceCode");
		[sourceCodeLinkLabel sizeToFit];

		NSRect labelFrame = sourceCodeLinkLabel.frame;

		sourceCodeLinkLabel.frame = NSMakeRect
			(round(([self.window.contentView bounds].size.width - labelFrame.size.width)  / 2.0),
			 labelFrame.origin.y,
			 labelFrame.size.width, labelFrame.size.height);
		}


#	pragma mark - IBAction


	- (IBAction) cancel: (id) sender
		{[self.window performClose: self];}


	- (void) explosionDidEnd: (Explosion *) explosion
		{_mineExploding = NO;}


	- (IBAction) boom: (NSButton *) sender
		{
		if (!_mineExploding)
			{
			_mineExploding = YES;
			[_explosionSound play];

			[_explosion
				explodeAtPoint:	[NSEvent mouseLocation]
				target:		self
				action:		@selector(explosionDidEnd:)];
			}
		}


	- (IBAction) sourceCode: (id) sender
		{[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://github.com/redcode/Mines"]];}


@end

// EOF
