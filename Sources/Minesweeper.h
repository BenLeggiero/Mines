/* Minesweeper Game Logic API - Minesweeper.h
	      __	   __
  _______ ___/ /______ ___/ /__
 / __/ -_) _  / __/ _ \ _  / -_)
/_/  \__/\_,_/\__/\___/_,_/\__/
Copyright © 2012-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#ifndef __games_puzzle_Minesweeper_H__
#define __games_puzzle_Minesweeper_H__

#include <Q/types/base.h>
#include <Q/keys/status.h>

Q_C_SYMBOLS_BEGIN

#define MINESWEEPER_MINIMUM_X_SIZE     4
#define MINESWEEPER_MINIMUM_Y_SIZE     4
#define MINESWEEPER_MINIMUM_MINE_COUNT 2

#define MINESWEEPER_CELL_MASK_EXPLODED	(1 << 7)
#define MINESWEEPER_CELL_MASK_MINE	(1 << 6)
#define MINESWEEPER_CELL_MASK_DISCLOSED (1 << 5)
#define MINESWEEPER_CELL_MASK_FLAG	(1 << 4)
#define MINESWEEPER_CELL_MASK_WARNING	0xF

typedef quint8 MinesweeperCell;

#define MINESWEEPER_CELL_EXPLODED( cell) ((cell) & MINESWEEPER_CELL_MASK_EXPLODED)
#define MINESWEEPER_CELL_MINE(	   cell) ((cell) & MINESWEEPER_CELL_MASK_MINE)
#define MINESWEEPER_CELL_DISCLOSED(cell) ((cell) & MINESWEEPER_CELL_MASK_DISCLOSED)
#define MINESWEEPER_CELL_FLAG(	   cell) ((cell) & MINESWEEPER_CELL_MASK_FLAG)
#define MINESWEEPER_CELL_WARNING(  cell) ((cell) & MINESWEEPER_CELL_MASK_WARNING)

typedef quint8 MinesweeperState;

#define MINESWEEPER_STATE_INITIALIZED 0
#define MINESWEEPER_STATE_PRISTINE    1
#define MINESWEEPER_STATE_PLAYING     2
#define MINESWEEPER_STATE_EXPLODED    3
#define MINESWEEPER_STATE_SOLVED      4

typedef quint8 MinesweeperResult;

#define MINESWEEPER_RESULT_ALREADY_DISCLOSED 1
#define MINESWEEPER_RESULT_IS_FLAG	     2
#define MINESWEEPER_RESULT_MINE_FOUND	     3
#define MINESWEEPER_RESULT_SOLVED	     4

typedef struct Minesweeper Minesweeper;

typedef void (* MinesweeperCellUpdated) (void*		 context,
					 Minesweeper*	 minesweeper,
					 Q2DSize	 cell_coordinates,
					 MinesweeperCell cell_value);

struct Minesweeper {
	MinesweeperCellUpdated cell_updated;
	void*		       cell_updated_context;
#	ifndef BUILD_FOR_POSIX_PROJECT
		qsize (* random)(void);
#	endif
	MinesweeperCell* cells;
	Q2DSize		 size;
	qsize		 mine_count;
	qsize		 remaining_count;
	qsize		 flag_count;
	MinesweeperState state;
};

typedef Q_STRICT_STRUCTURE(
	quint64 x;
	quint64 y;
	quint64 mine_count;
	quint8	state;
) MinesweeperSnapshotHeader;

#define MINESWEEPER(		    p) ((Minesweeper		   *)(p))
#define MINESWEEPER_SNAPSHOT_HEADER(p) ((MinesweeperSnapshotHeader *)(p))

void		  minesweeper_initialize		(Minesweeper* object);

void		  minesweeper_finalize			(Minesweeper* object);


void		  minesweeper_set_cell_updated_callback	(Minesweeper* object,
							 void*	      cell_updated,
							 void*	      cell_updated_context);

#ifndef BUILD_FOR_POSIX_PROJECT

void		  minesweeper_set_random		(Minesweeper* object,
							 void*	      random);

#endif

QStatus		  minesweeper_set_snapshot		(Minesweeper* object,
							 void*	      snapshot,
							 qsize	      snapshot_size);

qsize		  minesweeper_snapshot_size		(Minesweeper* object);

void		  minesweeper_snapshot			(Minesweeper* object,
							 void*	      output);

QStatus		  minesweeper_prepare			(Minesweeper* object,
							 Q2DSize      size,
							 qsize	      mine_count);

Q2DSize		  minesweeper_size			(Minesweeper* object);

qsize		  minesweeper_mine_count		(Minesweeper* object);

qsize		  minesweeper_covered_count		(Minesweeper* object);

qsize		  minesweeper_disclosed_count		(Minesweeper* object);

qsize		  minesweeper_remaining_count		(Minesweeper* object);

qsize		  minesweeper_flag_count		(Minesweeper* object);

MinesweeperCell   minesweeper_cell			(Minesweeper* object,
							 Q2DSize      coordinates);

MinesweeperState  minesweeper_state			(Minesweeper* object);

MinesweeperResult minesweeper_disclose			(Minesweeper* object,
							 Q2DSize      coordinates);

void		  minesweeper_disclose_all_mines	(Minesweeper* object);

MinesweeperResult minesweeper_toggle_flag		(Minesweeper* object,
							 Q2DSize      coordinates,
							 qboolean*    new_state);

void		  minesweeper_flag_all_mines		(Minesweeper* object);

qboolean	  minesweeper_hint			(Minesweeper* object,
							 Q2DSize*     coordinates);

void		  minesweeper_resolve			(Minesweeper* object);

QStatus		  minesweeper_snapshot_test		(void*	      snapshot,
							 qsize	      snapshot_size);

QStatus		  minesweeper_snapshot_values		(void*	      snapshot,
							 qsize	      snapshot_size,
							 Q2DSize*     size,
							 qsize*	      mine_count,
							 quint8*      state);

Q_C_SYMBOLS_END

#endif /* __games_puzzle_Minesweeper_H__ */
