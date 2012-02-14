//
//  VerticalGuageView.m
//  KinectWings
//
//  Created by John Boiles on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VerticalGuageView.h"

@implementation VerticalGuageView

@synthesize value=_value;

- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    [self setWantsLayer:YES];
    _value = 0.5;
  }
  return self;
}

- (BOOL)isFlipped { return YES; }

- (void)drawRect:(NSRect)dirtyRect {
  /*
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, 0, 0); 
  CGPathMoveToPoint(path, NULL, self.frame.size.width, 0);
  CGPathMoveToPoint(path, NULL, self.frame.size.width, self.frame.size.height);
  CGPathMoveToPoint(path, NULL, 0, self.frame.size.height);
  CGPathCloseSubpath(path);
   */

  CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
  [[NSColor whiteColor] set];
  CGContextFillRect(context, NSRectToCGRect(self.bounds));
  [[NSColor grayColor] set];
  CGFloat indicatorHeight = self.frame.size.height * self.value;
  CGContextFillRect(context, CGRectMake(0, self.frame.size.height - indicatorHeight, self.frame.size.width, indicatorHeight));
}

@end
