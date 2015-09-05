/* Minesweeper Game Logic API - Minesweeper.h
	      __	   __
  _______ ___/ /______ ___/ /__
 / __/ -_) _  / __/ _ \ _  / -_)
/_/  \__/\_,_/\__/\___/_,_/\__/
Copyright © 2012-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#ifndef __games_puzzle_Minesweeper_H__
#define __games_puzzle_Minesweeper_H__

#include <Z/types/base.h>
#include <Z/keys/status.h>

#if defined(BUILDING_DYNAMIC_MINESWEEPER)
#	define MINESWEEPER_API Z_API_EXPORT
#elif defined(BUILDING_STATIC_MINESWEEPER)
#	define MINESWEEPER_API Z_PUBLIC
#elif defined(USE_STATIC_MINESWEEPER)
#	define MINESWEEPER_API
#else
#	define MINESWEEPER_API Z_API
#endif

Z_C_SYMBOLS_BEGIN

#define MINESWEEPER_MINIMUM_X_SIZE     4
#define MINESWEEPER_MINIMUM_Y_SIZE     4
#define MINESWEEPER_MINIMUM_MINE_COUNT 2

#define MINESWEEPER_CELL_MASK_EXPLODED	(1 << 7)
#define MINESWEEPER_CELL_MASK_MINE	(1 << 6)
#define MINESWEEPER_CELL_MASK_DISCLOSED (1 << 5)
#define MINESWEEPER_CELL_MASK_FLAG	(1 << 4)
#define MINESWEEPER_CELL_MASK_WARNING	0xF

typedef zuint8 MinesweeperCell;

#define MINESWEEPER_CELL_EXPLODED( cell) ((cell) & MINESWEEPER_CELL_MASK_EXPLODED )
#define MINESWEEPER_CELL_MINE(	   cell) ((cell) & MINESWEEPER_CELL_MASK_MINE	  )
#define MINESWEEPER_CELL_DISCLOSED(cell) ((cell) & MINESWEEPER_CELL_MASK_DISCLOSED)
#define MINESWEEPER_CELL_FLAG(	   cell) ((cell) & MINESWEEPER_CELL_MASK_FLAG	  )
#define MINESWEEPER_CELL_WARNING(  cell) ((cell) & MINESWEEPER_CELL_MASK_WARNING  )

typedef zuint8 MinesweeperState;

#define MINESWEEPER_STATE_INITIALIZED 0
#define MINESWEEPER_STATE_PRISTINE    1
#define MINESWEEPER_STATE_PLAYING     2
#define MINESWEEPER_STATE_EXPLODED    3
#define MINESWEEPER_STATE_SOLVED      4

typedef zuint8 MinesweeperResult;

#define MINESWEEPER_RESULT_ALREADY_DISCLOSED 1
#define MINESWEEPER_RESULT_IS_FLAG	     2
#define MINESWEEPER_RESULT_MINE_FOUND	     3
#define MINESWEEPER_RESULT_SOLVED	     4

typedef struct Minesweeper Minesweeper;

# ifndef DONT_USE_MINESWEEPER_CALLBACKS
	typedef void (* MinesweeperCellUpdated) (void*		 context,
						 Minesweeper*	 minesweeper,
						 Z2DSize	 cell_coordinates,
						 MinesweeperCell cell_value);
#endif

struct Minesweeper {
#	ifndef DONT_USE_MINESWEEPER_CALLBACKS
		MinesweeperCellUpdated cell_updated;
		void*		       cell_updated_context;
#	endif

#	ifndef USE_POSIX_API
		zsize (* random)(void);
#	endif

	MinesweeperCell* cells;
	Z2DSize		 size;
	zsize		 mine_count;
	zsize		 remaining_count;
	zsize		 flag_count;
	MinesweeperState state;
};

Z_DEFINE_STRICT_STRUCTURE(
	zuint64 x;
	zuint64 y;
	zuint64 mine_count;
	zuint8	state;
) MinesweeperSnapshotHeader;

MINESWEEPER_API void		  minesweeper_initialize	 (Minesweeper* object);

MINESWEEPER_API void		  minesweeper_finalize		 (Minesweeper* object);

MINESWEEPER_API ZStatus		  minesweeper_set_snapshot	 (Minesweeper* object,
								  void*        snapshot,
								  zsize        snapshot_size);

MINESWEEPER_API zsize		  minesweeper_snapshot_size	 (Minesweeper* object);

MINESWEEPER_API void		  minesweeper_snapshot		 (Minesweeper* object,
								  void*        output);

MINESWEEPER_API ZStatus		  minesweeper_prepare		 (Minesweeper* object,
								  Z2DSize      size,
								  zsize        mine_count);

MINESWEEPER_API Z2DSize		  minesweeper_size		 (Minesweeper* object);

MINESWEEPER_API zsize		  minesweeper_mine_count	 (Minesweeper* object);

MINESWEEPER_API zsize		  minesweeper_covered_count	 (Minesweeper* object);

MINESWEEPER_API zsize		  minesweeper_disclosed_count	 (Minesweeper* object);

MINESWEEPER_API zsize		  minesweeper_remaining_count	 (Minesweeper* object);

MINESWEEPER_API zsize		  minesweeper_flag_count	 (Minesweeper* object);

MINESWEEPER_API MinesweeperCell   minesweeper_cell		 (Minesweeper* object,
								  Z2DSize      coordinates);

MINESWEEPER_API MinesweeperState  minesweeper_state		 (Minesweeper* object);

MINESWEEPER_API MinesweeperResult minesweeper_disclose		 (Minesweeper* object,
								  Z2DSize      coordinates);

MINESWEEPER_API MinesweeperResult minesweeper_toggle_flag	 (Minesweeper* object,
								  Z2DSize      coordinates,
								  zboolean*    new_state);

MINESWEEPER_API void		  minesweeper_disclose_all_mines (Minesweeper* object);

MINESWEEPER_API void		  minesweeper_flag_all_mines	 (Minesweeper* object);

MINESWEEPER_API zboolean	  minesweeper_hint		 (Minesweeper* object,
								  Z2DSize*     coordinates);

MINESWEEPER_API void		  minesweeper_resolve		 (Minesweeper* object);

#ifndef DONT_USE_MINESWEEPER_CALLBACKS
	MINESWEEPER_API void minesweeper_set_cell_updated_callback (Minesweeper* object,
								    void*	 cell_updated,
								    void*	 cell_updated_context);
#endif

#ifndef USE_POSIX_API
	MINESWEEPER_API void minesweeper_set_random (Minesweeper* object,
						     void*	  random);
#endif

MINESWEEPER_API ZStatus minesweeper_snapshot_test   (void*    snapshot,
						     zsize    snapshot_size);

MINESWEEPER_API ZStatus minesweeper_snapshot_values (void*    snapshot,
						     zsize    snapshot_size,
						     Z2DSize* size,
						     zsize*   mine_count,
						     zuint8*  state);

Z_C_SYMBOLS_END

#endif /* __games_puzzle_Minesweeper_H__ */
