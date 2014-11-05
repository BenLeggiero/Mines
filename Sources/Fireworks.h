/* Mines - Fireworks.h
 __  __
|  \/  | __  ____  ___  ____
|      |(__)|    |/ -_)(__ <
|__\/__||__||__|_|\___//___/
Copyright © 2013-2014 Manuel Sainz de Baranda y Goñi.
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
