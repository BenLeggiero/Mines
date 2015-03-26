/* Mines - migrations.m
 __  __
|  \/  | __  ____  ___	___
|      |(__)|    |/ -_)/_  \
|__\/__||__||__|_|\___/ /__/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "migrations.h"
#import "ImageStore.h"
#import "Theme.h"
#import "helpers.h"


Theme *MigratedUserThemeFrom_v1(NSMutableDictionary *themeDictionary, NSMutableArray **images, NSError **error)
	{
	[themeDictionary setObject: _("OldVersionCustomThemeName") forKey: @"Name"];
	if (![Theme validateDictionary: themeDictionary]) return nil;

	NSString*	path	    = nil;
	NSMutableArray* imageStore  = nil;
	NSFileManager*	fileManager = nil;
	NSImage*	image;
	NSMutableArray*	imageDictionaries = [[NSMutableArray alloc] init];

	*images = [[NSMutableArray alloc] init];

	//-----------------------------------------------------.
	// Buscamos imágenes del usuario en el antiguo tema y, |
	// en el caso de que encontremos alguna...	       |
	//-----------------------------------------------------'
	for (NSDictionary *entry in [themeDictionary objectForKey: @"Images"])
		{
		if ([((NSNumber *)[entry objectForKey: @"Included"]) boolValue])
			{
			if (!(image = [NSImage imageNamed: [entry objectForKey: @"FileName"]]))
				goto error;

			[*images addObject: image];
			[imageDictionaries addObject: entry];
			}

		else	{
			//--------------------------------------------------------------------.
			// El directorio "Application Support" debe existir en el contenedor. |
			//--------------------------------------------------------------------'
			if (!path && !(path = BundleSupportDirectory(NO, NULL))) goto error;

			//-------------------------------------------------.
			// Cargamos el índice de las imágenes del usuario. |
			//-------------------------------------------------'
			if (!imageStore && !(imageStore = ImageStoreLoad(error)))
				{
				if (*error) goto error;

				//--------------------------.
				// Si no existe lo creamos. |
				//--------------------------'
				imageStore = [[NSMutableArray alloc] init];
				}

			//----------------------------------------------------------------.
			// Guardamos la imagen de forma compatible con la versión actual. |
			//----------------------------------------------------------------'
			NSString *imagePath = [path stringByAppendingPathComponent: [entry objectForKey: @"FileName"]];
			image = nil;

			if (!ImageStoreKeepImage(imageStore, imagePath, &image, error)) goto error;
			if (!fileManager) fileManager = [NSFileManager defaultManager];
			[fileManager removeItemAtPath: imagePath error: NULL];
			[*images addObject: image];

			NSDictionary *newEntry = [[NSDictionary alloc] initWithObjectsAndKeys:
				[NSNumber numberWithBool: NO],				     @"Included",
				ImageStoreFileNameAtIndex(imageStore, imageStore.count - 1), @"FileName",
				nil];

			[imageDictionaries addObject: newEntry];
			[newEntry release];
			}
		}

	//------------------------------------------------------------------.
	// En el caso de que hayamos migrado imágenes, guardamos el índice. |
	//------------------------------------------------------------------'
	if (imageStore && !ImageStoreSave(imageStore, error) && *error) goto error;
	[themeDictionary setObject: imageDictionaries forKey: @"Images"];

	Theme *theme = [[Theme alloc] initWithDictionary: themeDictionary];

	if ([theme save: error])
		{
		[imageStore release];
		return theme;
		}

	[theme release];

	error:
	[imageDictionaries release];
	[imageStore	   release];
	[*images	   release];
	*images = nil;
	return nil;
	}


// EOF
