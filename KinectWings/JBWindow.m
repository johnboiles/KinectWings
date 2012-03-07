//
//  JBWindow.m
//  KinectWings
//
//  Created by John Boiles on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JBWindow.h"

@implementation JBWindow

@synthesize windowDelegate=_windowDelegate;

- (void)keyDown:(NSEvent *)theEvent {
  if (![_windowDelegate handleKeyDownEvent:theEvent]) {
    [super keyDown:theEvent];
  }
}

- (void)keyUp:(NSEvent *)theEvent {
  if (![_windowDelegate handleKeyUpEvent:theEvent]) {
    [super keyUp:theEvent];
  }
}

@end
