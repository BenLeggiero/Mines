/* ALSound.h
	      __	   __
  _______ ___/ /______ ___/ /__
 / __/ -_) _  / __/ _ \ _  / -_)
/_/  \__/\_,_/\__/\___/_,_/\__/
Copyright © 2013 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU Lesser General Public License v3. */

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface ALSound : NSObject {
	ALuint	  _sourceID;
	ALuint	  _bufferID;
	uint16_t* _buffer;
}
	+ (ALSound *) soundNamed: (NSString *) soundFileName;

	- (void) play;
	- (void) stop;
@end

// EOF
