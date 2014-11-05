/* ALSound.m
	      __	   __
  _______ ___/ /______ ___/ /__
 / __/ -_) _  / __/ _ \ _  / -_)
/_/  \__/\_,_/\__/\___/_,_/\__/
Copyright © 2013 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU Lesser General Public License v3. */

#import "ALSound.h"
#import <AudioToolbox/AudioToolbox.h>

#define AUDIO_FORMAT_FLAGS \
	(kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsSignedInteger)

static NSMutableDictionary* sounds_  = nil;
static ALCcontext*	    context_ = NULL;


@implementation ALSound


	+ (ALSound *) soundNamed: (NSString *) fileName
		{
		ALSound *sound;

		//-------------------------------------------------------------.
		// Si el sonido está cacheado no es necesario volver a crearlo |
		//-------------------------------------------------------------'
		if (sounds_ && (sound = [sounds_ objectForKey: fileName])) return sound;

		ExtAudioFileRef		    file;
		SInt64			    frameCount;
		UInt32			    size = sizeof(UInt64);
		UInt32			    descriptionSize = sizeof(AudioStreamBasicDescription);
		AudioStreamBasicDescription description;
		uint16_t*		    buffer;

		//------------------------------.
		// Abrimos el archivo de sonido |
		//------------------------------'
		if (noErr != ExtAudioFileOpenURL
			((CFURLRef)[[[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle]
				pathForResource: [fileName stringByDeletingPathExtension]
				ofType:		 [fileName pathExtension]]]
			 autorelease],
			 &file)
		)
			return nil;

		//--------------------------------------------------------------.
		// Obtenemos el número de samples y las propiedades del formato |
		//--------------------------------------------------------------'
		if (	noErr != ExtAudioFileGetProperty(file, kExtAudioFileProperty_FileLengthFrames, &size,		 &frameCount) ||
			noErr != ExtAudioFileGetProperty(file, kExtAudioFileProperty_FileDataFormat,   &descriptionSize, &description)
		)
			goto close_file_and_return_nil;

		//-----------------------------------------------------.
		// Si el formato no es PCM, ajustamos las propiedades  |
		// para que los samples sean convertidos a PCM al leer |
		//-----------------------------------------------------'
		if (description.mFormatID != kAudioFormatLinearPCM || description.mFormatFlags != AUDIO_FORMAT_FLAGS)
			{
			description.mFormatID = kAudioFormatLinearPCM;
			description.mFormatFlags = AUDIO_FORMAT_FLAGS;

			ExtAudioFileSetProperty(file, kExtAudioFileProperty_ClientDataFormat, descriptionSize, &description);
			}

		//---------------------------------------------.
		// Creamos el buffer en dónde leer los samples |
		//---------------------------------------------'
		if ((buffer = malloc((size_t)(frameCount * description.mBytesPerFrame))) == NULL)
			goto close_file_and_return_nil;

		AudioBufferList bufferList;
		bufferList.mNumberBuffers = 1;
		bufferList.mBuffers[0].mNumberChannels = description.mChannelsPerFrame;
		bufferList.mBuffers[0].mDataByteSize   = description.mBytesPerFrame * (UInt32)frameCount;
		bufferList.mBuffers[0].mData	       = buffer;

		//-----------------------------------------------------------------.
		// Posicionamos la lectura al principio y leemos todos los samples |
		//-----------------------------------------------------------------'
		size = (UInt32)frameCount;

		if (	noErr != ExtAudioFileSeek(file, 0) ||
			noErr != ExtAudioFileRead(file, &size, &bufferList)
		)
			goto free_buffer_close_file_and_return_nil;

		//---------------------.
		// Cerramos el archivo |
		//---------------------'
		ExtAudioFileDispose(file);

		//----------------------.
		// Creamos la instancia |
		//----------------------'
		if ((sound = [[self alloc] init]))
			{
			sound->_buffer = buffer;

			//-----------------------------------.
			// Si todavía no existía ninguna.... |
			//-----------------------------------'
			if (!sounds_)
				{
				//---------------------------------.
				// Creamos el diccionario de caché |
				//---------------------------------'
				CFDictionaryValueCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};

				sounds_ = (id)CFDictionaryCreateMutable
					(NULL, (CFIndex)0, &kCFTypeDictionaryKeyCallBacks, &callbacks);

				//----------------------.
				// Inicializamos OpenAL |
				//----------------------'
				const ALCchar *defaultDevice = alcGetString(NULL, ALC_DEFAULT_DEVICE_SPECIFIER);
				ALCdevice *soundDevice = alcOpenDevice(defaultDevice);

				context_ = alcCreateContext(soundDevice, NULL);
				alcMakeContextCurrent(context_);
				alcProcessContext(context_);

				alListener3f(AL_POSITION,    0, 0,  0);
				alListener3f(AL_VELOCITY,    0, 0,  0);
				alListener3f(AL_ORIENTATION, 0, 0, -1);
				}

			//---------------------------------------.
			// Creamos la fuente de sonido de OpenAL |
			//---------------------------------------'
			alGenSources(1, &sound->_sourceID);
			alSource3f(sound->_sourceID, AL_POSITION, 0, 0, 0);
			alSource3f(sound->_sourceID, AL_VELOCITY, 0, 0, 0);
			alSourcei (sound->_sourceID, AL_LOOPING, AL_FALSE);

			//---------------------------------------------------------.
			// Creamos el buffer que contiene los sampels de la fuente |
			//---------------------------------------------------------'
			alGenBuffers(1, &sound->_bufferID);

			ALenum audioFormat = 0;

			if (description.mChannelsPerFrame == 1)
				{
				if (description.mBitsPerChannel == 8) audioFormat = AL_FORMAT_MONO8;
				else if (description.mBitsPerChannel == 16) audioFormat = AL_FORMAT_MONO16;
				}

			else if (description.mChannelsPerFrame == 2)
				{
				if (description.mBitsPerChannel == 8) audioFormat = AL_FORMAT_STEREO8;
				else if (description.mBitsPerChannel == 16) audioFormat = AL_FORMAT_STEREO16;
				}

			alBufferData
				(sound->_bufferID, audioFormat, buffer,
				 (ALsizei)(frameCount * description.mBytesPerFrame),
				 (ALsizei)description.mSampleRate);

			//----------------------------------.
			// Encolamos el buffer en la fuente |
			//----------------------------------'
			alSourceQueueBuffers(sound->_sourceID, 1, &sound->_bufferID);

			//--------------------------------.
			// Añadimos la instancia al caché |
			//--------------------------------'
			[sounds_ setObject: sound forKey: fileName];
			}

		else free(buffer);

		return [sound autorelease];

		free_buffer_close_file_and_return_nil:
		free(buffer);

		close_file_and_return_nil:
		ExtAudioFileDispose(file);
		return nil;
		}


	- (void) dealloc
		{
		[sounds_ removeObjectForKey: [[sounds_ allKeysForObject: self] objectAtIndex: 0]];
		alSourceStop(_sourceID);
		alSourceUnqueueBuffers(_sourceID, 1, &_bufferID);
		alDeleteBuffers(1, &_bufferID);
		alDeleteSources(1, &_sourceID);
		free(_buffer);

		if (![sounds_ count])
			{
			[sounds_ release];
			sounds_ = nil;

			alcSuspendContext(context_);
			alcDestroyContext(context_);
			}

		[super dealloc];
		}


	- (void) play {alSourceStop(_sourceID); alSourcePlay(_sourceID);}
	- (void) stop {alSourceStop(_sourceID);}


@end

// EOF
