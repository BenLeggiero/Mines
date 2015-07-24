/* Minesweeper Game Logic - Minesweeper.c
	      __	   __
  _______ ___/ /______ ___/ /__
 / __/ -_) _  / __/ _ \ _  / -_)
/_/  \__/\_,_/\__/\___/_,_/\__/
Copyright © 2012-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#include <Q/functions/base/Q2DValue.h>

#ifdef USE_POSIX_API
#	include "Minesweeper.h"
#	include <stdlib.h>
#	include <string.h>
#	define q_deallocate(block)			  free(block)
#	define q_reallocate(block, block_size)		  realloc(block, block_size)
#	define q_copy(block, block_size, output)	  memcpy(output, block, block_size)
#	define q_int8_block_set(block, block_size, value) memset(block, value, block_size)
#	define RANDOM					  ((qsize)random())
#else
#	include <games/puzzle/Minesweeper.h>
#	include <QBase/allocation.h>
#	include <QBase/block.h>
#	define RANDOM ((qsize (*)(void))object->random)()
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
	object->cell_updated(object->cell_updated_context, object, q_2d_value(SIZE)(x, y), cell)
#endif

typedef struct {qint8 x, y;} Offset;

Q_PRIVATE Offset const offsets[] = {
	{-1, -1}, {0, -1}, {1, -1},
	{-1,  0},	   {1,	0},
	{-1,  1}, {0,  1}, {1,	1}
};


Q_PRIVATE void place_mines(Minesweeper *object, qsize but_x, qsize but_y)
	{
	MinesweeperCell *c, *nc;
	qsize n = object->mine_count, x, y, nx, ny;
	const Offset *p, *e;
	qboolean valid;

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


Q_PRIVATE void disclose_cell(Minesweeper *object, qsize x, qsize y)
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
			qsize nx, ny;

			for (; p != e; p++)
				{
				nx = x + p->x;
				ny = y + p->y;
				if (VALID(nx, ny)) disclose_cell(object, nx, ny);
				}
			}
		}
	}


Q_PRIVATE void count_hint_cases(Minesweeper *object, qsize *counts)
	{
	qsize x, y, nx, ny;
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


Q_PRIVATE Q2DSize case0_hint(Minesweeper *object, qsize index)
	{
	qsize x, y, nx, ny;
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
					if (!index) return q_2d_value(SIZE)(x, y);
					index--;
					break;
					}
				}
			}
		}

	return q_2d_value_zero(SIZE);
	}


Q_PRIVATE Q2DSize case1_hint(Minesweeper *object, qsize index)
	{
	MinesweeperCell *c = CELLS_END;

	while (c != object->cells)
		{
		c--;

		if (!(*c & (DISCLOSED | FLAG | MINE)) && (*c & WARNING))
			{
			if (!index) return q_2d_value(SIZE)(X(c), Y(c));
			index--;
			}
		}

	return q_2d_value_zero(SIZE);
	}


Q_PRIVATE Q2DSize case2_hint(Minesweeper *object, qsize index)
	{
	MinesweeperCell *c = CELLS_END;

	while (c != object->cells)
		{
		c--;

		if (!(*c & (DISCLOSED | FLAG | MINE)))
			{
			if (!index) return q_2d_value(SIZE)(X(c), Y(c));
			index--;
			}
		}

	return q_2d_value_zero(SIZE);
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
	{if (object->cells != NULL) q_deallocate(object->cells);}


MINESWEEPER_API
QStatus minesweeper_set_snapshot(Minesweeper *object, void *snapshot, qsize snapshot_size)
	{
	MinesweeperCell *p, *e;

	Q2DSize size = q_2d_value(SIZE)
		((qsize)q_uint64_big_endian(HEADER(snapshot)->x),
		 (qsize)q_uint64_big_endian(HEADER(snapshot)->y));

	qsize cell_count = size.x * size.y;

	if (cell_count != object->size.x * object->size.y)
		{
		if ((p = q_reallocate(object->cells, cell_count)) == NULL)
			return Q_ERROR_NOT_ENOUGH_MEMORY;

		object->cells = p;
		object->size  = size;
		}

	object->mine_count	= (qsize)q_uint64_big_endian(HEADER(snapshot)->mine_count);
	object->state		= HEADER(snapshot)->state;
	object->flag_count	= 0;
	object->remaining_count = cell_count - object->mine_count;

	if (object->state <= MINESWEEPER_STATE_PRISTINE)
		q_int8_block_set(object->cells, cell_count, 0);

	else	{
		q_copy(snapshot + HEADER_SIZE, cell_count, object->cells);

		for (p = object->cells, e = p + cell_count; p != e; p++)
			{
			if (*p & FLAG) object->flag_count++;
			if ((*p & DISCLOSED) && !(*p & MINE)) object->remaining_count--;
			}
		}

	return Q_OK;
	}


MINESWEEPER_API
qsize minesweeper_snapshot_size(Minesweeper *object)
	{
	return object->state > MINESWEEPER_STATE_PRISTINE
		? HEADER_SIZE + object->size.x * object->size.y
		: HEADER_SIZE;
	}


MINESWEEPER_API
void minesweeper_snapshot(Minesweeper *object, void *output)
	{
	HEADER(output)->x	   = q_uint64_big_endian(object->size.x);
	HEADER(output)->y	   = q_uint64_big_endian(object->size.y);
	HEADER(output)->mine_count = q_uint64_big_endian(object->mine_count);
	HEADER(output)->state	   = object->state;

	if (object->state > MINESWEEPER_STATE_PRISTINE)
		q_copy(object->cells, object->size.x * object->size.y, output + HEADER_SIZE);
	}


MINESWEEPER_API
QStatus minesweeper_prepare(Minesweeper *object, Q2DSize size, qsize mine_count)
	{
	qsize cell_count = size.x * size.y;

	if (	size.x	   < MINESWEEPER_MINIMUM_X_SIZE	    ||
		size.y	   < MINESWEEPER_MINIMUM_Y_SIZE	    ||
		mine_count < MINESWEEPER_MINIMUM_MINE_COUNT ||
		mine_count > cell_count - 1
	)
		return Q_ERROR_INVALID_ARGUMENT;

	if (!q_2d_value_are_equal(SIZE)(object->size, size))
		{
		void *cells = q_reallocate(object->cells, cell_count);

		if (cells == NULL) return Q_ERROR_NOT_ENOUGH_MEMORY;

		object->cells = cells;
		object->size  = size;
		}

	object->state		= MINESWEEPER_STATE_PRISTINE;
	object->flag_count	= 0;
	object->remaining_count = cell_count - (object->mine_count = mine_count);

	q_int8_block_set(object->cells, cell_count, 0);
	return Q_OK;
	}


MINESWEEPER_API
Q2DSize minesweeper_size(Minesweeper *object)
	{return object->size;}


MINESWEEPER_API
qsize minesweeper_mine_count(Minesweeper *object)
	{return object->mine_count;}


MINESWEEPER_API
qsize minesweeper_covered_count(Minesweeper *object)
	{return object->size.x * object->size.y - minesweeper_disclosed_count(object);}


MINESWEEPER_API
qsize minesweeper_disclosed_count(Minesweeper *object)
	{
	return	((object->size.x * object->size.y) -
		object->mine_count) - object->remaining_count;
	}


MINESWEEPER_API
qsize minesweeper_remaining_count(Minesweeper *object)
	{return object->remaining_count;}


MINESWEEPER_API
qsize minesweeper_flag_count(Minesweeper *object)
	{return object->flag_count;}


MINESWEEPER_API
MinesweeperCell minesweeper_cell(Minesweeper *object, Q2DSize coordinates)
	{return CELL(coordinates.x, coordinates.y);}


MINESWEEPER_API
MinesweeperState minesweeper_state(Minesweeper *object)
	{return object->state;}


MINESWEEPER_API
MinesweeperResult minesweeper_disclose(Minesweeper *object, Q2DSize coordinates)
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

	return Q_OK;
	}


MINESWEEPER_API
MinesweeperResult minesweeper_toggle_flag(
	Minesweeper* object,
	Q2DSize	     coordinates,
	qboolean*    new_value
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
	return Q_OK;
	}


MINESWEEPER_API
void minesweeper_disclose_all_mines(Minesweeper *object)
	{
	MinesweeperCell *c = CELLS_END;

#	ifndef DONT_USE_MINESWEEPER_CALLBACKS
		if (object->cell_updated != NULL)
			{
			qsize x = object->size.x, y;

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
			qsize x = object->size.x, y;

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
qboolean minesweeper_hint(Minesweeper *object, Q2DSize *coordinates)
	{
	qsize counts[3];

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
			qsize x = object->size.x, y;

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
QStatus minesweeper_snapshot_test(void *snapshot, qsize snapshot_size)
	{
	qsize	cell_count;
	qsize	mine_count;
	Q2DSize	size;
	quint8	state;

	if (snapshot_size < HEADER_SIZE) return Q_ERROR_INVALID_SIZE;

	cell_count =
	(size.x = (qsize)q_uint64_big_endian(HEADER(snapshot)->x)) *
	(size.y = (qsize)q_uint64_big_endian(HEADER(snapshot)->y));

	mine_count = (qsize)q_uint64_big_endian(HEADER(snapshot)->mine_count);
	state	   = HEADER(snapshot)->state;

	if (	state	  == MINESWEEPER_STATE_INITIALIZED  ||
		state	   > MINESWEEPER_STATE_SOLVED	    ||
		size.x	   < MINESWEEPER_MINIMUM_X_SIZE	    ||
		size.y	   < MINESWEEPER_MINIMUM_Y_SIZE	    ||
		mine_count < MINESWEEPER_MINIMUM_MINE_COUNT ||
		mine_count > cell_count - 1
	)
		return Q_ERROR_INVALID_VALUE;

	if (state == MINESWEEPER_STATE_PRISTINE)
		{if (snapshot_size != HEADER_SIZE) return Q_ERROR_INVALID_SIZE;}

	else	{
		MinesweeperCell *cells = snapshot + HEADER_SIZE, *c;
		const Offset *p, *e;
		qsize real_mine_count, exploded_count, x, y, nx, ny;
		quint8 w;

		if (snapshot_size != HEADER_SIZE + cell_count) return Q_ERROR_INVALID_SIZE;

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
				return Q_ERROR_INVALID_DATA;

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
						return Q_ERROR_INVALID_DATA;
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

				if (w != (*c & WARNING)) return Q_ERROR_INVALID_DATA;
				}
			}

		if (mine_count != real_mine_count) return Q_ERROR_INVALID_FORMAT;
		}

	return Q_OK;
	}


MINESWEEPER_API
QStatus minesweeper_snapshot_values(
	void*	 snapshot,
	qsize	 snapshot_size,
	Q2DSize* size,
	qsize*	 mine_count,
	quint8*	 state
)
	{
	if (snapshot_size < sizeof(MinesweeperSnapshotHeader)) return Q_ERROR_INVALID_SIZE;

	if (size != NULL)
		{
		size->x = (qsize)q_uint64_big_endian(HEADER(snapshot)->x);
		size->y = (qsize)q_uint64_big_endian(HEADER(snapshot)->y);
		}

	if (mine_count != NULL)
		*mine_count = (qsize)q_uint64_big_endian(HEADER(snapshot)->mine_count);

	if (state != NULL)
		*state = (qsize)q_uint64_big_endian(HEADER(snapshot)->state);

	return Q_OK;
	}


/* Minesweeper.c EOF */
