/* Mines - geometry.h
   __  __
  /  \/  \  __ ___  ____  _____
 /	  \(__)   \/  -_)_\  _/
/___/__/__/__/__/_/\___/____/
Copyright © 2013-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#ifndef __Mines_geometry_H
#define __Mines_geometry_H

#import <Cocoa/Cocoa.h>


NS_INLINE CGFloat PointAngle(NSPoint a, NSPoint b)
	{
	CGFloat angle = atan2(b.y - a.y, b.x - a.x);

	return angle < 0.0 ? M_PI * 2 + angle : angle;
	}


NS_INLINE NSPoint PointSubtract(NSPoint a, NSPoint b)
	{return NSMakePoint(a.x - b.x, a.y - b.y);}


NS_INLINE CGFloat PointDistanceToZero(NSPoint point)
	{return hypot(point.x, point.y);}


NS_INLINE CGFloat PointDistance(NSPoint a, NSPoint b)
	{return PointDistanceToZero(PointSubtract(b, a));}


NS_INLINE NSPoint PointByVectorAtDistance(
	NSPoint vectorA,
	NSPoint vectorB,
	CGFloat distance
)
	{
	distance /= PointDistance(vectorA, vectorB);

	return NSMakePoint
		((vectorB.x - vectorA.x) * distance + vectorA.x,
		 (vectorB.y - vectorA.y) * distance + vectorA.y);
	}


NS_INLINE NSPoint PointByVectorOfKnownMagnitideAtDistance(
	NSPoint vectorA,
	NSPoint vectorB,
	CGFloat magnitude,
	CGFloat distance
)
	{
	distance /= magnitude;

	return NSMakePoint
		((vectorB.x - vectorA.x) * distance + vectorA.x,
		 (vectorB.y - vectorA.y) * distance + vectorA.y);
	}


NS_INLINE NSSize SizeFit(NSSize a, NSSize b)
	{
	return a.height / a.width > b.height / b.width
		? NSMakeSize(a.width * b.height / a.height, b.height)
		: NSMakeSize(b.width, a.height * b.width / a.width);
	}


NS_INLINE NSSize SizeAdd(NSSize a, NSSize b)
	{return NSMakeSize(a.width + b.width, a.height + b.height);}


NS_INLINE NSSize SizeSubtract(NSSize a, NSSize b)
	{return NSMakeSize(a.width - b.width, a.height - b.height);}


NS_INLINE bool SizeContains(NSSize a, NSSize b)
	{return (b.width <= a.width && b.height <= a.height);}


NS_INLINE NSSize SizeMultiplyByScalar(NSSize size, CGFloat scalar)
	{return NSMakeSize(size.width * scalar, size.height * scalar);}


NS_INLINE NSRect RectangleFitInCenter(NSRect rectangle, NSSize size)
	{
	NSRect result;

	result.size = SizeFit(size, rectangle.size);

	result.origin.x =
		rectangle.origin.x +
		(rectangle.size.width - result.size.width) / 2.0;

	result.origin.y =
		rectangle.origin.y +
		(rectangle.size.height - result.size.height) / 2.0;

	return result;
	}


#endif // __Mines_geometry_H
