/* Mines - Fireworks.h
 __  __
|  \/  | __  ____  ___	___
|      |(__)|    |/ -_)/_  \
|__\/__||__||__|_|\___/ /__/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
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
