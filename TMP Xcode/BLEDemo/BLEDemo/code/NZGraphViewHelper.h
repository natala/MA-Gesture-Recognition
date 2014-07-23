//
//  NZGraphViewHelper.h
//  BLEDemo
//
//  Created by Natalia Zarawska on 20/03/14.
//  Copyright (c) 2014 TUM. All rights reserved.
//

// functions used to draw all the content

#ifndef GRAPH_VIEW_HELPER
#define GRAPH_VIEW_HELPER

extern CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a);
extern CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a);
extern CGColorRef graphBackgroundColor();
extern CGColorRef graphLineColor();
extern CGColorRef graphXColor();
extern CGColorRef graphYColor();
extern CGColorRef graphZColor();
extern void DrawGridlines(CGContextRef context, CGFloat x, CGFloat width);

// must call StrokeLines right after DrawHorizontalLines
extern void DrawHorizontalLine(CGContextRef context, CGFloat x, CGFloat y, CGFloat width);
extern void StrokeLines(CGContextRef context);


#endif


