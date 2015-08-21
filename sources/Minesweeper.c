/* Minesweeper Game Logic - Minesweeper.c
	      __	   __
  _______ ___/ /______ ___/ /__
 / __/ -_) _  / __/ _ \ _  / -_)
/_/  \__/\_,_/\__/\___/_,_/\__/
Copyright © 2012-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#include <Z/functions/base/Z2DValue.h>

#ifdef USE_LOCAL_HEADER_MINESWEEPER
#	include "Minesweeper.h"
#else
#	include <games/puzzle/Minesweeper.h>
#endif

#ifdef USE_POSIX_API
#	include <stdlib.h>
#	include <string.h>

#	define z_deallocate(block)			  free(block)
#	define z_reallocate(block, block_size)		  realloc(block, block_size)
#	define z_copy(block, block_size, output)	  memcpy(output, block, block_size)
#	define z_int8_block_set(block, block_size, value) memset(block, value, block_size)
#	define RANDOM					  ((zsize)random())
#else
#	include <ZBase/allocation.h>
#	include <ZBase/block.h>
#	define RANDOM ((zsize (*)(void))object->random)()
#endif

#define EXPLODED	    MINESWEEPER_CELL_MASK_EXPLODED
#define DISCLOSED	    MINESWEEPER_CELL_MASK_DISCLOSED
#define MINE		    MINESWEEPER_CELL_MASK_MINE
#define FLAG		    MINESWEEPER_CELL_MASK_FLAG
#define WARNING		    MINESWEEPER_CELL_MASK_WARNING
#define HEADER		    MINESWEEPER_SNAPSHOT_HEADER
#define HEADER_SIZE	    sizeof(MinesweeperSnapshotHeader)
#define CELL(cx, cy)	    object->cells[cy * object->size.x + cx]
#define VALID(cx, cy)	    (cx < object->size.x && cy < object->size.y)
#define LOCAL_CELL(cx, cy)  cells[cy * size.x + cx]
#define LOCAL_VALID(cx, cy) (cx < size.x && cy < size.y)
#define X(pointer)	    ((c - object->cells) % object->size.x)
#define Y(pointer)	    ((c - object->cells) / object->size.x)
#define CELLS_END	    (object->cells + object->size.x * object->size.y)

#ifndef DONT_USE_MINESWEEPER_CALLBACKS
#	define UPDATED(x, y, cell) \
	object->cell_updated(object->cell_updated_context, object, z_2d_value(SIZE)(x, y), cell)
#endif

typedef struct {zint8 x, y;} Offset;

Z_PRIVATE Offset const offsets[] = {
	{-1, -1}, {0, -1}, {1, -1},
	{-1,  0},	   {1,	0},
	{-1,  1}, {0,  1}, {1,	1}
};


Z_PRIVATE void place_mines(Minesweeper *object, zsize but_x, zsize but_y)
	{
	MinesweeperCell *c, *nc;
	zsize n = object->mine_count, x, y, nx, ny;
	const Offset *p, *e;
	zboolean valid;

	while (n)
		{
		x = RANDOM % object->size.x;
		y = RANDOM % object->size.y;

		if (!(x == but_x && y == but_y) && !(*(c = &CELL(x, y)) & MINE))
			{
			valid = TRUE;

			for (p = offsets, e = p + 8; p != e; p++)
				if (x == but_x + p->x && y == but_y + p->y)
					{
					valid = FALSE;
					break;
					}

			if (valid)
				{
				*c |= MINE;

				for (p = offsets, e = p + 8; p != e; p++)
					{
					nx = x + p->x;
					ny = y + p->y;

					if (VALID(nx, ny))
						{
						nc = &CELL(nx, ny);
						*nc = (*nc & ~WARNING) | (*nc &  WARNING) + 1;
						}
					}

				n--;
				}
			}
		}

	object->state = MINESWEEPER_STATE_PLAYING;
	}


Z_PRIVATE void disclose_cell(Minesweeper *object, zsize x, zsize y)
	{
	MinesweeperCell *c = &CELL(x, y);

	if (!(*c & (DISCLOSED | FLAG)))
		{
		*c |= DISCLOSED;
		object->remaining_count--;

#		ifndef DONT_USE_MINESWEEPER_CALLBACKS
			if (object->cell_updated != NULL) UPDATED(x, y, *c);
#		endif

		if (!(*c & WARNING))
			{
			const Offset *p = offsets, *e = p + 8;
			zsize nx, ny;

			for (; p != e; p++)
				{
				nx = x + p->x;
				ny = y + p->y;
				if (VALID(nx, ny)) disclose_cell(object, nx, ny);
				}
			}
		}
	}


Z_PRIVATE void count_hint_cases(Minesweeper *object, zsize *counts)
	{
	zsize x, y, nx, ny;
	MinesweeperCell *c = CELLS_END;
	const Offset *p, *e;

	counts[0] = 0;
	counts[1] = 0;
	counts[2] = 0;

	while (c != object->cells)
		{
		c--;

		if (!(*c & (DISCLOSED | FLAG | MINE)))
			{
			counts[2]++;

			if (*c & WARNING)
				{
				counts[1]++;
				y = Y(c);
				x = X(c);

				for (p = offsets, e = p + 8; p != e; p++)
					{
					nx = x + p->x;
					ny = y + p->y;

					if (VALID(nx, ny) && (CELL(nx, ny) & DISCLOSED))
						{
						counts[0]++;
						break;
						}
					}
				}
			}
		}
	}


Z_PRIVATE Z2DSize case0_hint(Minesweeper *object, zsize index)
	{
	zsize x, y, nx, ny;
	MinesweeperCell *c = CELLS_END;
	const Offset *p, *e;

	while (c != object->cells)
		{
		c--;

		if (!(*c & (DISCLOSED | FLAG | MINE)) && (*c & WARNING))
			{
			y = Y(c);
			x = X(c);

			for (p = offsets, e = p + 8; p != e; p++)
				{
				nx = x + p->x;
				ny = y + p->y;

				if (VALID(nx, ny) && (CELL(nx, ny) & DISCLOSED))
					{
					if (!index) return z_2d_value(SIZE)(x, y);
					index--;
					break;
					}
				}
			}
		}

	return z_2d_value_zero(SIZE);
	}


Z_PRIVATE Z2DSize case1_hint(Minesweeper *object, zsize index)
	{
	MinesweeperCell *c = CELLS_END;

	while (c != object->cells)
		{
		c--;

		if (!(*c & (DISCLOSED | FLAG | MINE)) && (*c & WARNING))
			{
			if (!index) return z_2d_value(SIZE)(X(c), Y(c));
			index--;
			}
		}

	return z_2d_value_zero(SIZE);
	}


Z_PRIVATE Z2DSize case2_hint(Minesweeper *object, zsize index)
	{
	MinesweeperCell *c = CELLS_END;

	while (c != object->cells)
		{
		c--;

		if (!(*c & (DISCLOSED | FLAG | MINE)))
			{
			if (!index) return z_2d_value(SIZE)(X(c), Y(c));
			index--;
			}
		}

	return z_2d_value_zero(SIZE);
	}


MINESWEEPER_API
void minesweeper_initialize(Minesweeper *object)
	{
	object->state		     = MINESWEEPER_STATE_INITIALIZED;
	object->size.x		     = 0;
	object->size.y		     = 0;
	object->mine_count	     = 0;
	object->cells		     = NULL;
	object->cell_updated	     = NULL;
	object->cell_updated_context = NULL;
	}


MINESWEEPER_API
void minesweeper_finalize(Minesweeper *object)
	{if (object->cells != NULL) z_deallocate(object->cells);}


MINESWEEPER_API
ZStatus minesweeper_set_snapshot(Minesweeper *object, void *snapshot, zsize snapshot_size)
	{
	MinesweeperCell *p, *e;

	Z2DSize size = z_2d_value(SIZE)
		((zsize)z_uint64_big_endian(HEADER(snapshot)->x),
		 (zsize)z_uint64_big_endian(HEADER(snapshot)->y));

	zsize cell_count = size.x * size.y;

	if (cell_count != object->size.x * object->size.y)
		{
		if ((p = z_reallocate(object->cells, cell_count)) == NULL)
			return Z_ERROR_NOT_ENOUGH_MEMORY;

		object->cells = p;
		object->size  = size;
		}

	object->mine_count	= (zsize)z_uint64_big_endian(HEADER(snapshot)->mine_count);
	object->state		= HEADER(snapshot)->state;
	object->flag_count	= 0;
	object->remaining_count = cell_count - object->mine_count;

	if (object->state <= MINESWEEPER_STATE_PRISTINE)
		z_int8_block_set(object->cells, cell_count, 0);

	else	{
		z_copy(snapshot + HEADER_SIZE, cell_count, object->cells);

		for (p = object->cells, e = p + cell_count; p != e; p++)
			{
			if (*p & FLAG) object->flag_count++;
			if ((*p & DISCLOSED) && !(*p & MINE)) object->remaining_count--;
			}
		}

	return Z_OK;
	}


MINESWEEPER_API
zsize minesweeper_snapshot_size(Minesweeper *object)
	{
	return object->state > MINESWEEPER_STATE_PRISTINE
		? HEADER_SIZE + object->size.x * object->size.y
		: HEADER_SIZE;
	}


MINESWEEPER_API
void minesweeper_snapshot(Minesweeper *object, void *output)
	{
	HEADER(output)->x	   = z_uint64_big_endian(object->size.x);
	HEADER(output)->y	   = z_uint64_big_endian(object->size.y);
	HEADER(output)->mine_count = z_uint64_big_endian(object->mine_count);
	HEADER(output)->state	   = object->state;

	if (object->state > MINESWEEPER_STATE_PRISTINE)
		z_copy(object->cells, object->size.x * object->size.y, output + HEADER_SIZE);
	}


MINESWEEPER_API
ZStatus minesweeper_prepare(Minesweeper *object, Z2DSize size, zsize mine_count)
	{
	zsize cell_count = size.x * size.y;

	if (	size.x	   < MINESWEEPER_MINIMUM_X_SIZE	    ||
		size.y	   < MINESWEEPER_MINIMUM_Y_SIZE	    ||
		mine_count < MINESWEEPER_MINIMUM_MINE_COUNT ||
		mine_count > cell_count - 1
	)
		return Z_ERROR_INVALID_ARGUMENT;

	if (!z_2d_value_are_equal(SIZE)(object->size, size))
		{
		void *cells = z_reallocate(object->cells, cell_count);

		if (cells == NULL) return Z_ERROR_NOT_ENOUGH_MEMORY;

		object->cells = cells;
		object->size  = size;
		}

	object->state		= MINESWEEPER_STATE_PRISTINE;
	object->flag_count	= 0;
	object->remaining_count = cell_count - (object->mine_count = mine_count);

	z_int8_block_set(object->cells, cell_count, 0);
	return Z_OK;
	}


MINESWEEPER_API
Z2DSize minesweeper_size(Minesweeper *object)
	{return object->size;}


MINESWEEPER_API
zsize minesweeper_mine_count(Minesweeper *object)
	{return object->mine_count;}


MINESWEEPER_API
zsize minesweeper_covered_count(Minesweeper *object)
	{return object->size.x * object->size.y - minesweeper_disclosed_count(object);}


MINESWEEPER_API
zsize minesweeper_disclosed_count(Minesweeper *object)
	{
	return	((object->size.x * object->size.y) -
		object->mine_count) - object->remaining_count;
	}


MINESWEEPER_API
zsize minesweeper_remaining_count(Minesweeper *object)
	{return object->remaining_count;}


MINESWEEPER_API
zsize minesweeper_flag_count(Minesweeper *object)
	{return object->flag_count;}


MINESWEEPER_API
MinesweeperCell minesweeper_cell(Minesweeper *object, Z2DSize coordinates)
	{return CELL(coordinates.x, coordinates.y);}


MINESWEEPER_API
MinesweeperState minesweeper_state(Minesweeper *object)
	{return object->state;}


MINESWEEPER_API
MinesweeperResult minesweeper_disclose(Minesweeper *object, Z2DSize coordinates)
	{
	MinesweeperCell *c = &CELL(coordinates.x, coordinates.y);

	if (object->state == MINESWEEPER_STATE_PRISTINE)
		place_mines(object, coordinates.x, coordinates.y);

	if (*c & DISCLOSED) return MINESWEEPER_RESULT_ALREADY_DISCLOSED;
	if (*c & FLAG)	    return MINESWEEPER_RESULT_IS_FLAG;

	if (*c & MINE)
		{
		*c |= DISCLOSED | EXPLODED;
		object->state = MINESWEEPER_STATE_EXPLODED;
		return MINESWEEPER_RESULT_MINE_FOUND;
		}

	disclose_cell(object, coordinates.x, coordinates.y);

	if (!object->remaining_count)
		{
		object->state = MINESWEEPER_STATE_SOLVED;
		return MINESWEEPER_RESULT_SOLVED;
		}

	return Z_OK;
	}


MINESWEEPER_API
MinesweeperResult minesweeper_toggle_flag(
	Minesweeper* object,
	Z2DSize	     coordinates,
	zboolean*    new_value
)
	{
	MinesweeperCell *c = &CELL(coordinates.x, coordinates.y);

        if (*c & DISCLOSED) return MINESWEEPER_RESULT_ALREADY_DISCLOSED;

	if (*c & FLAG)
		{
		object->flag_count--;
		*c &= ~FLAG;
		}

	else	{
		object->flag_count++;
		*c |= FLAG;
		}

#	ifndef DONT_USE_MINESWEEPER_CALLBACKS
		if (object->cell_updated != NULL) UPDATED(coordinates.x, coordinates.y, *c);
#	endif

	if (new_value != NULL) *new_value = !!(*c & FLAG);
	return Z_OK;
	}


MINESWEEPER_API
void minesweeper_disclose_all_mines(Minesweeper *object)
	{
	MinesweeperCell *c = CELLS_END;

#	ifndef DONT_USE_MINESWEEPER_CALLBACKS
		if (object->cell_updated != NULL)
			{
			zsize x = object->size.x, y;

			while (x) for (x--, y = object->size.y; y;)
				{
				y--; c--;

				if (*c & MINE)
					{
					*c |= DISCLOSED;
					UPDATED(x, y, *c);
					}
				}
			}

		else
#	endif

	while (c != object->cells) if (*--c & MINE) *c |= DISCLOSED;
	}


MINESWEEPER_API
void minesweeper_flag_all_mines(Minesweeper *object)
	{
	MinesweeperCell *c = CELLS_END;

#	ifndef DONT_USE_MINESWEEPER_CALLBACKS
		if (object->cell_updated != NULL)
			{
			zsize x = object->size.x, y;

			while (x) for (x--, y = object->size.y; y;)
				{
				y--; c--;

				if (*c & MINE)
					{
					*c |= FLAG;
					UPDATED(x, y, *c);
					}
				}
			}

		else
#	endif

	while (c != object->cells) if (*--c & MINE) *c |= FLAG;
	}


MINESWEEPER_API
zboolean minesweeper_hint(Minesweeper *object, Z2DSize *coordinates)
	{
	zsize counts[3];

	if (	object->state == MINESWEEPER_STATE_EXPLODED ||
		object->state == MINESWEEPER_STATE_SOLVED   ||
		object->state == MINESWEEPER_STATE_INITIALIZED
	)
		return FALSE;

	if (object->state == MINESWEEPER_STATE_PRISTINE)
		{
		place_mines
			(object,
			 coordinates->x = RANDOM % object->size.x,
			 coordinates->y = RANDOM % object->size.y);

		return TRUE;
		}

	count_hint_cases(object, counts);

	if	(counts[0]) *coordinates = case0_hint(object, RANDOM % counts[0]);
	else if (counts[1]) *coordinates = case1_hint(object, RANDOM % counts[1]);
	else if (counts[2]) *coordinates = case2_hint(object, RANDOM % counts[2]);
	else return FALSE;
	return TRUE;
	}


MINESWEEPER_API
void minesweeper_resolve(Minesweeper *object)
	{
	MinesweeperCell *c = CELLS_END;

#	ifndef DONT_USE_MINESWEEPER_CALLBACKS
		if (object->cell_updated != NULL)
			{
			zsize x = object->size.x, y;

			while (x) for (x--, y = object->size.y; y;)
				{
				y--; c--;

				if (!(*c & (MINE | DISCLOSED)))
					{
					*c |= DISCLOSED;
					UPDATED(x, y, *c);
					}
				}
			}

		else
#	endif

	while (c != object->cells) if (!(*--c & (MINE | DISCLOSED))) *c |= DISCLOSED;
	object->remaining_count = 0;
	}


#ifndef DONT_USE_MINESWEEPER_CALLBACKS

MINESWEEPER_API
void minesweeper_set_cell_updated_callback(
	Minesweeper* object,
	void*	     cell_updated,
	void*	     cell_updated_context
)
	{
	object->cell_updated	     = cell_updated;
	object->cell_updated_context = cell_updated_context;
	}

#endif


#ifndef USE_POSIX_API

MINESWEEPER_API
void minesweeper_set_random(Minesweeper *object, void *random)
	{object->random = random;}

#endif


MINESWEEPER_API
ZStatus minesweeper_snapshot_test(void *snapshot, zsize snapshot_size)
	{
	zsize	cell_count;
	zsize	mine_count;
	Z2DSize	size;
	zuint8	state;

	if (snapshot_size < HEADER_SIZE) return Z_ERROR_INVALID_SIZE;

	cell_count =
	(size.x = (zsize)z_uint64_big_endian(HEADER(snapshot)->x)) *
	(size.y = (zsize)z_uint64_big_endian(HEADER(snapshot)->y));

	mine_count = (zsize)z_uint64_big_endian(HEADER(snapshot)->mine_count);
	state	   = HEADER(snapshot)->state;

	if (	state	  == MINESWEEPER_STATE_INITIALIZED  ||
		state	   > MINESWEEPER_STATE_SOLVED	    ||
		size.x	   < MINESWEEPER_MINIMUM_X_SIZE	    ||
		size.y	   < MINESWEEPER_MINIMUM_Y_SIZE	    ||
		mine_count < MINESWEEPER_MINIMUM_MINE_COUNT ||
		mine_count > cell_count - 1
	)
		return Z_ERROR_INVALID_VALUE;

	if (state == MINESWEEPER_STATE_PRISTINE)
		{if (snapshot_size != HEADER_SIZE) return Z_ERROR_INVALID_SIZE;}

	else	{
		MinesweeperCell *cells = snapshot + HEADER_SIZE, *c;
		const Offset *p, *e;
		zsize real_mine_count, exploded_count, x, y, nx, ny;
		zuint8 w;

		if (snapshot_size != HEADER_SIZE + cell_count) return Z_ERROR_INVALID_SIZE;

		real_mine_count = 0;
		exploded_count	= 0;

		for (c = cells + cell_count; c != cells;)
			{
			c--;

			/*-----------------------------------.
			| The flags can not be disclosed and |
			| only 1 exploded cell is allowed.   |
			'-----------------------------------*/
			if (	(*c & FLAG && *c & DISCLOSED) ||
				(*c & EXPLODED && ++exploded_count > 1)
			)
				return Z_ERROR_INVALID_DATA;

			/*------------------------------------------.
			| The mines must be surrounded by warnings. |
			'------------------------------------------*/
			if (*c & MINE)
				{
				real_mine_count++;

				x = (c - cells) % size.x;
				y = (c - cells) / size.x;

				for (p = offsets, e = p + 8; p != e; p++)
					{
					nx = x + p->x;
					ny = y + p->y;

					if (	LOCAL_VALID(nx, ny) &&
						!(LOCAL_CELL(nx, ny) & WARNING)
					)
						return Z_ERROR_INVALID_DATA;
					}
				}

			/*---------------------------------------.
			| The warning numbers must be surrounded |
			| by the correct amount of mines.	 |
			'---------------------------------------*/
			if (*c & WARNING)
				{
				x = (c - cells) % size.x;
				y = (c - cells) / size.x;

				for (w = 0, p = offsets, e = p + 8; p != e; p++)
					{
					nx = x + p->x;
					ny = y + p->y;

					if (LOCAL_VALID(nx, ny) && (LOCAL_CELL(nx, ny) & MINE))
						w++;
					}

				if (w != (*c & WARNING)) return Z_ERROR_INVALID_DATA;
				}
			}

		if (mine_count != real_mine_count) return Z_ERROR_INVALID_FORMAT;
		}

	return Z_OK;
	}


MINESWEEPER_API
ZStatus minesweeper_snapshot_values(
	void*	 snapshot,
	zsize	 snapshot_size,
	Z2DSize* size,
	zsize*	 mine_count,
	zuint8*	 state
)
	{
	if (snapshot_size < sizeof(MinesweeperSnapshotHeader)) return Z_ERROR_INVALID_SIZE;

	if (size != NULL)
		{
		size->x = (zsize)z_uint64_big_endian(HEADER(snapshot)->x);
		size->y = (zsize)z_uint64_big_endian(HEADER(snapshot)->y);
		}

	if (mine_count != NULL)
		*mine_count = (zsize)z_uint64_big_endian(HEADER(snapshot)->mine_count);

	if (state != NULL)
		*state = (zsize)z_uint64_big_endian(HEADER(snapshot)->state);

	return Z_OK;
	}


/* Minesweeper.c EOF */
