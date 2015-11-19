/* Minesweeper Kit - Minesweeper.c
	      __	   __
  _______ ___/ /______ ___/ /__
 / __/ -_) _  / __/ _ \ _  / -_)
/_/  \__/\_,_/\__/\___/_,_/\__/
Copyright © 2012-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU Lesser General Public License v3. */

#include <Z/functions/base/Z2DValue.h>

#if defined(MINESWEEPER_BUILDING_DYNAMIC)
#	define MINESWEEPER_API Z_API_EXPORT
#else
#	define MINESWEEPER_API
#endif

#ifdef MINESWEEPER_USE_LOCAL_HEADER
#	include "Minesweeper.h"
#else
#	include <games/puzzle/Minesweeper.h>
#endif

#ifdef MINESWEEPER_USE_C_STANDARD_LIBRARY
#	include <stdlib.h>
#	include <string.h>

#	define z_deallocate(block)			  free(block)
#	define z_reallocate(block, block_size)		  realloc(block, block_size)
#	define z_copy(block, block_size, output)	  memcpy(output, block, block_size)
#	define z_block_int8_set(block, block_size, value) memset(block, value, block_size)
#	define z_random					  random
#else
#	include <ZBase/allocation.h>
#	include <ZBase/block.h>
#	include <ZSystem/random.h>
#endif

#define RANDOM		    ((zuint)z_random())
#define EXPLODED	    MINESWEEPER_CELL_MASK_EXPLODED
#define DISCLOSED	    MINESWEEPER_CELL_MASK_DISCLOSED
#define MINE		    MINESWEEPER_CELL_MASK_MINE
#define FLAG		    MINESWEEPER_CELL_MASK_FLAG
#define WARNING		    MINESWEEPER_CELL_MASK_WARNING
#define HEADER(p)	    ((MinesweeperSnapshotHeader *)(p))
#define HEADER_SIZE	    ((zsize)sizeof(MinesweeperSnapshotHeader))
#define CELL(cx, cy)	    object->matrix[cy * object->size.x + cx]
#define VALID(cx, cy)	    (cx < object->size.x && cy < object->size.y)
#define LOCAL_CELL(cx, cy)  matrix[cy * size.x + cx]
#define LOCAL_VALID(cx, cy) (cx < size.x && cy < size.y)
#define X(pointer)	    (((zuint)(c - object->matrix)) % object->size.x)
#define Y(pointer)	    (((zuint)(c - object->matrix)) / object->size.x)
#define MATRIX_END	    (object->matrix + object->size.x * object->size.y)

#ifdef MINESWEEPER_USE_CALLBACK
#	define UPDATED(x, y, cell) \
	object->cell_updated(object->cell_updated_context, object, z_2d_type(UINT)(x, y), cell)
#endif

typedef struct {zint8 x, y;} Offset;

static Offset const offsets[] = {
	{-1, -1}, {0, -1}, {1, -1},
	{-1,  0},	   {1,	0},
	{-1,  1}, {0,  1}, {1,	1}
};


static void place_mines(Minesweeper *object, zuint but_x, zuint but_y)
	{
	MinesweeperCell *c, *nc;
	const Offset *p, *e;
	zboolean valid;
	zuint x, y, nx, ny, n = object->mine_count;

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


static void disclose_cell(Minesweeper *object, zuint x, zuint y)
	{
	MinesweeperCell *c = &CELL(x, y);

	if (!(*c & (DISCLOSED | FLAG)))
		{
		*c |= DISCLOSED;
		object->remaining_count--;

#		ifdef MINESWEEPER_USE_CALLBACK
			if (object->cell_updated != NULL) UPDATED(x, y, *c);
#		endif

		if (!(*c & WARNING))
			{
			const Offset *p = offsets, *e = p + 8;
			zuint nx, ny;

			for (; p != e; p++)
				{
				nx = x + p->x;
				ny = y + p->y;
				if (VALID(nx, ny)) disclose_cell(object, nx, ny);
				}
			}
		}
	}


static void count_hint_cases(Minesweeper const *object, zuint *counts)
	{
	MinesweeperCell *c = MATRIX_END;
	const Offset *p, *e;
	zuint x, y, nx, ny;

	counts[0] = 0;
	counts[1] = 0;
	counts[2] = 0;

	while (c-- != object->matrix) if (!(*c & (DISCLOSED | FLAG | MINE)))
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


static Z2DUInt case0_hint(Minesweeper const *object, zuint index)
	{
	MinesweeperCell *c = MATRIX_END;
	const Offset *p, *e;
	zuint x, y, nx, ny;

	while (c-- != object->matrix) if (!(*c & (DISCLOSED | FLAG | MINE)) && (*c & WARNING))
		{
		y = Y(c);
		x = X(c);

		for (p = offsets, e = p + 8; p != e; p++)
			{
			nx = x + p->x;
			ny = y + p->y;

			if (VALID(nx, ny) && (CELL(nx, ny) & DISCLOSED))
				{
				if (!index--) return z_2d_type(UINT)(x, y);
				break;
				}
			}
		}

	return z_2d_type_zero(UINT);
	}


static Z2DUInt case1_hint(Minesweeper const *object, zuint index)
	{
	MinesweeperCell *c = MATRIX_END;

	while (c-- != object->matrix) if (!(*c & (DISCLOSED | FLAG | MINE)) && (*c & WARNING))
		if (!index--) return z_2d_type(UINT)(X(c), Y(c));

	return z_2d_type_zero(UINT);
	}


static Z2DUInt case2_hint(Minesweeper const *object, zuint index)
	{
	MinesweeperCell *c = MATRIX_END;

	while (c != object->matrix)
		{
		c--;

		if (!(*c & (DISCLOSED | FLAG | MINE)))
			{
			if (!index--) return z_2d_type(UINT)(X(c), Y(c));
			}
		}

	return z_2d_type_zero(UINT);
	}


MINESWEEPER_API
void minesweeper_initialize(Minesweeper *object)
	{
	object->state	   = MINESWEEPER_STATE_INITIALIZED;
	object->size.x	   = 0;
	object->size.y	   = 0;
	object->mine_count = 0;
	object->matrix	   = NULL;

#	ifdef MINESWEEPER_USE_CALLBACK
		object->cell_updated	     = NULL;
		object->cell_updated_context = NULL;
#	endif
	}


MINESWEEPER_API
void minesweeper_finalize(Minesweeper *object)
	{z_deallocate(object->matrix);}


MINESWEEPER_API
ZStatus minesweeper_prepare(Minesweeper *object, Z2DUInt size, zuint mine_count)
	{
	zuint cell_count = size.x * size.y;

	if (size.x < MINESWEEPER_MINIMUM_X_SIZE || size.y < MINESWEEPER_MINIMUM_Y_SIZE)
		return Z_ERROR_TOO_SMALL;

	if (z_type_multiplication_overflow(UINT)(size.x, size.y))
		return Z_ERROR_TOO_BIG;

	if (mine_count < MINESWEEPER_MINIMUM_MINE_COUNT || mine_count > cell_count - 1)
		return Z_ERROR_INVALID_ARGUMENT;

	if (	z_2d_type_inner_product(UINT)(object->size) !=
		z_2d_type_inner_product(UINT)(size)
	)
		{
		void *matrix = z_reallocate(object->matrix, cell_count);

		if (matrix == NULL) return Z_ERROR_NOT_ENOUGH_MEMORY;
		object->matrix = matrix;
		}

	z_block_int8_set(object->matrix, cell_count, 0);
	object->size		= size;
	object->state		= MINESWEEPER_STATE_PRISTINE;
	object->flag_count	= 0;
	object->remaining_count = cell_count - (object->mine_count = mine_count);
	return Z_OK;
	}


MINESWEEPER_API
zuint minesweeper_covered_count(Minesweeper const *object)
	{return object->size.x * object->size.y - minesweeper_disclosed_count(object);}


MINESWEEPER_API
zuint minesweeper_disclosed_count(Minesweeper const *object)
	{
	return	((object->size.x * object->size.y) - object->mine_count) -
		object->remaining_count;
	}


MINESWEEPER_API
MinesweeperResult minesweeper_disclose(Minesweeper *object, Z2DUInt coordinates)
	{
	MinesweeperCell *c = &CELL(coordinates.x, coordinates.y);

	if (object->state == MINESWEEPER_STATE_PRISTINE)
		place_mines(object, coordinates.x, coordinates.y);

	if (*c & DISCLOSED) return MINESWEEPER_RESULT_ALREADY_DISCLOSED;
	if (*c & FLAG	  ) return MINESWEEPER_RESULT_IS_FLAG;

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
	Z2DUInt	     coordinates,
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

#	ifdef MINESWEEPER_USE_CALLBACK
		if (object->cell_updated != NULL) UPDATED(coordinates.x, coordinates.y, *c);
#	endif

	if (new_value != NULL) *new_value = !!(*c & FLAG);
	return Z_OK;
	}


MINESWEEPER_API
void minesweeper_disclose_all_mines(Minesweeper *object)
	{
	MinesweeperCell *c = MATRIX_END;

#	ifdef MINESWEEPER_USE_CALLBACK
		if (object->cell_updated != NULL)
			{
			zuint x = object->size.x, y;

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

	while (c != object->matrix) if (*--c & MINE) *c |= DISCLOSED;
	}


MINESWEEPER_API
void minesweeper_flag_all_mines(Minesweeper *object)
	{
	MinesweeperCell *c = MATRIX_END;

#	ifdef MINESWEEPER_USE_CALLBACK
		if (object->cell_updated != NULL)
			{
			zuint x = object->size.x, y;

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

	while (c != object->matrix) if (*--c & MINE) *c |= FLAG;
	}


MINESWEEPER_API
zboolean minesweeper_hint(Minesweeper *object, Z2DUInt *coordinates)
	{
	zuint counts[3];

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
	MinesweeperCell *c = MATRIX_END;

#	ifdef MINESWEEPER_USE_CALLBACK
		if (object->cell_updated != NULL)
			{
			zuint x = object->size.x, y;

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

	while (c != object->matrix) if (!(*--c & (MINE | DISCLOSED))) *c |= DISCLOSED;
	object->remaining_count = 0;
	}


MINESWEEPER_API
zsize minesweeper_snapshot_size(Minesweeper const *object)
	{
	return object->state > MINESWEEPER_STATE_PRISTINE
		? HEADER_SIZE + object->size.x * object->size.y
		: HEADER_SIZE;
	}


MINESWEEPER_API
void minesweeper_snapshot(Minesweeper const *object, void *output)
	{
	HEADER(output)->x	   = z_uint64_big_endian(object->size.x);
	HEADER(output)->y	   = z_uint64_big_endian(object->size.y);
	HEADER(output)->mine_count = z_uint64_big_endian(object->mine_count);
	HEADER(output)->state	   = object->state;

	if (object->state > MINESWEEPER_STATE_PRISTINE)
		z_copy(object->matrix, object->size.x * object->size.y, output + HEADER_SIZE);
	}


MINESWEEPER_API
ZStatus minesweeper_set_snapshot(Minesweeper *object, void *snapshot, zsize snapshot_size)
	{
	MinesweeperCell *p, *e;

	Z2DUInt size = z_2d_type(UINT)
		((zuint)z_uint64_big_endian(HEADER(snapshot)->x),
		 (zuint)z_uint64_big_endian(HEADER(snapshot)->y));

	zuint cell_count = z_2d_type_inner_product(UINT)(size);

	if (cell_count != z_2d_type_inner_product(UINT)(object->size))
		{
		if ((p = z_reallocate(object->matrix, cell_count)) == NULL)
			return Z_ERROR_NOT_ENOUGH_MEMORY;

		object->matrix = p;
		}

	object->size		= size;
	object->mine_count	= (zuint)z_uint64_big_endian(HEADER(snapshot)->mine_count);
	object->state		= HEADER(snapshot)->state;
	object->flag_count	= 0;
	object->remaining_count = cell_count - object->mine_count;

	if (object->state <= MINESWEEPER_STATE_PRISTINE)
		z_block_int8_set(object->matrix, cell_count, 0);

	else	{
		z_copy(snapshot + HEADER_SIZE, cell_count, object->matrix);

		for (p = object->matrix, e = p + cell_count; p != e; p++)
			{
			if (*p & FLAG) object->flag_count++;
			if ((*p & DISCLOSED) && !(*p & MINE)) object->remaining_count--;
			}
		}

	return Z_OK;
	}


#ifdef MINESWEEPER_USE_CALLBACK

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


MINESWEEPER_API
ZStatus minesweeper_snapshot_test(void const *snapshot, zsize snapshot_size)
	{
	Z2DUInt64	 size;
	zuint64		 mine_count;
	MinesweeperState state;
	zuint		 cell_count;

	if (	snapshot_size < HEADER_SIZE ||
		((state = HEADER(snapshot)->state) == MINESWEEPER_STATE_PRISTINE &&
		 snapshot_size			   != HEADER_SIZE)
	)
		return Z_ERROR_INVALID_SIZE;

	if (	state == MINESWEEPER_STATE_INITIALIZED				 ||
		state >  MINESWEEPER_STATE_SOLVED				 ||
		(size.x = z_uint64_big_endian(HEADER(snapshot)->x))		 <
		MINESWEEPER_MINIMUM_X_SIZE					 ||
		(size.y = z_uint64_big_endian(HEADER(snapshot)->y))		 <
		MINESWEEPER_MINIMUM_Y_SIZE					 ||
		(mine_count = z_uint64_big_endian(HEADER(snapshot)->mine_count)) <
		MINESWEEPER_MINIMUM_MINE_COUNT
	)
		return Z_ERROR_INVALID_VALUE;

	if (
#		if Z_UINT_BITS < 64
			size.x > Z_UINT_MAXIMUM || size.y > Z_UINT_MAXIMUM ||
#		endif
		z_type_multiplication_overflow(UINT)((zuint)size.x, (zuint)size.y)
	)
		return Z_ERROR_TOO_BIG;

	if (mine_count > (cell_count = (zuint)size.x * (zuint)size.y) - 1)
		return Z_ERROR_INVALID_VALUE;

	if (state != MINESWEEPER_STATE_PRISTINE)
		{
		MinesweeperCell const *matrix = snapshot + HEADER_SIZE, *c;
		Offset const *p, *e;
		zuint real_mine_count, exploded_count, x, y, nx, ny;
		zuint8 w;

		if (snapshot_size != HEADER_SIZE + cell_count) return Z_ERROR_INVALID_SIZE;

		real_mine_count = 0;
		exploded_count	= 0;

		for (c = matrix + cell_count; c != matrix;)
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

				x = (zuint)(c - matrix) % size.x;
				y = (zuint)(c - matrix) / size.x;

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
				x = (zuint)(c - matrix) % size.x;
				y = (zuint)(c - matrix) / size.x;

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

		if (mine_count != real_mine_count) return Z_ERROR_INVALID_DATA;
		}

	return Z_OK;
	}


MINESWEEPER_API
void minesweeper_snapshot_values(
	void const*	  snapshot,
	zsize*		  snapshot_size,
	Z2DUInt*	  size,
	zuint*		  mine_count,
	MinesweeperState* state
)
	{
	zuint64	size_x = z_uint64_big_endian(HEADER(snapshot)->x);
	zuint64 size_y = z_uint64_big_endian(HEADER(snapshot)->y);

	if (snapshot_size != NULL)
		*snapshot_size = HEADER_SIZE + (zuintptr)size_x + (zuintptr)size_y;

	if (size != NULL)
		{
		size->x = (zuint)size_x;
		size->y = (zuint)size_y;
		}

	if (mine_count != NULL)
		*mine_count = (zuint)z_uint64_big_endian(HEADER(snapshot)->mine_count);

	if (state != NULL) *state = HEADER(snapshot)->state;
	}


/* Minesweeper.c EOF */
