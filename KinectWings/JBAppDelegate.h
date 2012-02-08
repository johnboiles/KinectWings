//
//  JBAppDelegate.h
//  KinectWings
//
//  Created by John Boiles on 1/13/12.
//  Copyright (c) 2012 John Boiles. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoaOpenNI.h"
#import "JBFlapGestureRecognizer.h"

@class DepthView;
@class VerticalGuageView;

@interface JBAppDelegate : NSObject <NSApplicationDelegate, JBFlapGestureRecognizerDelegate> {
  IBOutlet DepthView *_openGLView;
  IBOutlet VerticalGuageView *_leftVerticalGuageView;
  IBOutlet VerticalGuageView *_rightVerticalGuageView;
  JBFlapGestureRecognizer *_flapGestureRecognizer;
}

@property (assign) IBOutlet NSWindow *window;

@end
