/* Mines - Fireworks.h
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Betty Lab.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface Fireworks : NSView {
	CAEmitterLayer*	_emitter;
	CAEmitterCell*	_rocket;
	CAEmitterCell*	_flare;
	CAEmitterCell*	_explosion;
} @end

// EOF
