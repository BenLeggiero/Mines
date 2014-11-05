/* Mines - ImageStore.m
 __  __
|  \/  | __  ____  ___  ____
|      |(__)|    |/ -_)(__ <
|__\/__||__||__|_|\___//___/
Copyright © 2013-2014 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "ImageStore.h"
#import "helpers.h"
#import <CommonCrypto/CommonDigest.h>
#import <Q/functions/base/Q2D.h>


NSMutableArray *ImageStoreLoad(NSError **error)
	{
	NSString *path = BundleSupportSubdirectory(@"Custom Images", NO, error);
	NSMutableArray *imageStore;

	if (!path) return nil;

	if ((	imageStore = [[NSMutableArray alloc] initWithContentsOfFile:
			[path stringByAppendingPathComponent: @"index.plist"]]
	))
		{
		Class dictionaryClass = [NSDictionary class];
		Class stringClass     = [NSString class];
		NSString *object;
		NSString *MD5Key = @"MD5";
		NSString *formatKey = @"Format";

		for (NSDictionary *entry in imageStore) if (
			![entry isKindOfClass: dictionaryClass]	    ||
			!(object = [entry objectForKey: MD5Key])    ||
			![object isKindOfClass: stringClass]	    ||
			!(object = [entry objectForKey: formatKey]) ||
			![object isKindOfClass: stringClass]
		)
			{
			[imageStore release];
			goto bad_file;
			}

		return imageStore;
		}

	bad_file:
	if (error != NULL) *error = ErrorForFile(_("Error.UnableToLoadFile"), path);
	return nil;
	}


BOOL ImageStoreSave(NSMutableArray *imageStore, NSError **error)
	{
	NSString *path = BundleSupportSubdirectory(@"Custom Images", NO, error);

	if (!path) return NO;

	BOOL result = [imageStore
		writeToFile: [path stringByAppendingPathComponent: @"index.plist"]
		atomically:  YES];

	if (!result && error != NULL) *error = ErrorForFile(_("Error.UnableToLoadFile"), path);
	return result;
	}


BOOL ImageStoreKeepImage(NSMutableArray *imageStore, NSString *imagePath, NSImage **loadedImage, NSError **error)
	{
	NSString *path;
	NSData *data;
	unsigned char MD5[16];

	if (!(data = [[NSData alloc] initWithContentsOfFile: imagePath options: 0 error: error]))
		return NO;

	//----------------------------------------------.
	// Calculamos el MD5 del contenido del archivo. |
	//----------------------------------------------'
	CC_MD5(data.bytes, (unsigned int)data.length, MD5);

	NSString *MD5String = [NSString stringWithFormat:
		@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
		MD5[0], MD5[1], MD5[ 2], MD5[ 3], MD5[ 4], MD5[ 5], MD5[ 6], MD5[ 7],
		MD5[8], MD5[9], MD5[10], MD5[11], MD5[12], MD5[13], MD5[14], MD5[15]];

	//---------------------------------------------------------------------.
	// Si tenemos ya una imagen guardada con el mismo MD5 no hacemos nada. |
	//---------------------------------------------------------------------'
	NSString *MD5Key = @"MD5";

	for (NSDictionary *item in imageStore)
		if ([[item objectForKey: MD5Key] isEqualToString: MD5String])
			goto release_data_and_return_no;

	//----------------------------------------.
	// Comprobamos que sea una imágen válida. |
	//----------------------------------------'
	NSImage *image = [[NSImage alloc] initWithData: data];

	if (!image)
		{
		if (error != NULL) *error = ErrorForBadImageFormatInFile(imagePath);
		goto release_data_and_return_no;
		}

	//-------------------------------------------------------------.
	// Copiamos la imagen al almacén de imágenes de la aplicación. |
	//-------------------------------------------------------------'
	if (	!(path = BundleSupportSubdirectory(@"Custom Images", YES, error)) ||
		![data	writeToFile: STRING(@"%@/%@.%@", path, MD5String, imagePath.pathExtension)
			options:     NSDataWritingAtomic
			error:	     error]
	)
		{
		[image release];
		release_data_and_return_no:
		[data release];
		return NO;
		}

	[data release];

	//----------------------------------------------------------------------.
	// Actualizamos el índice de las imágenes y lo guardamos en su archivo. |
	//----------------------------------------------------------------------'
	NSDictionary *item = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
		MD5String,		 MD5Key,
		imagePath.pathExtension, @"Format",
		nil];

	[imageStore addObject: item];
	[item release];

	if (![imageStore
		writeToFile: path = [path stringByAppendingPathComponent: @"index.plist"]
		atomically:  YES]
	)
		{
		[image release];
		[imageStore removeLastObject];
		if (error != NULL) *error = ErrorForFile(_("Error.UnableToWriteToFile"), path);
		return NO;
		}

	if (loadedImage == NULL) [image release];
	else *loadedImage = [image autorelease];
	return YES;
	}


BOOL ImageStoreRemoveImage(NSMutableArray *imageStore, NSUInteger index, NSError **error)
	{
	NSDictionary *entry = [[imageStore objectAtIndex: index] retain];
	NSString *path = BundleSupportSubdirectory(@"Custom Images", NO, error);
	BOOL result;

	if (imageStore.count > 1)
		{
		NSString *filePath = [path stringByAppendingPathComponent: @"index.plist"];

		[imageStore removeObjectAtIndex: index];

		//----------------------------------------------------------------------.
		// Solamente abortamos y devolvemos el error cuando falla la escritura	|
		// del archivo de índice, no la de el de la imagen. En caso contrario,	|
		// tendríamos que volver a escribir el primero en su estado original,	|
		// lo cual también puede fallar. Un archivo de imagen fantasma siempre	|
		// puede ser sobreescrito en el futuro sin problemas si se añade una	|
		// imagen con el mismo formato y MD5.					|
		//----------------------------------------------------------------------'
		if ((result = [imageStore writeToFile: filePath atomically: YES])) [[NSFileManager defaultManager]
			removeItemAtPath: STRING
				(@"%@/%@.%@", path, [entry objectForKey: @"MD5"], [entry objectForKey: @"Format"])
			error: NULL];

		else	{
			[imageStore insertObject: entry atIndex: index];
			if (error != NULL) *error = ErrorForFile(_("Error.UnableToWriteToFile"), filePath);
			}
		}

	else if ((result = [[NSFileManager defaultManager] removeItemAtPath: path error: error]))
		[imageStore removeObjectAtIndex: index];

	[entry release];
	return result;
	}


NSString *ImageStoreFileNameAtIndex(NSMutableArray* imageStore, NSUInteger index)
	{
	NSDictionary *entry = [imageStore objectAtIndex: index];

	return [[entry objectForKey: @"MD5"] stringByAppendingPathExtension: [entry objectForKey: @"Format"]];
	}


// EOF
