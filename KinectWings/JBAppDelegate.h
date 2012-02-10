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
#import "JBTiltGestureRecognizer.h"

@class DepthView;
@class VerticalGuageView;

@interface JBAppDelegate : NSObject <NSApplicationDelegate, JBFlapGestureRecognizerDelegate, JBTiltGestureRecognizerDelegate> {
  IBOutlet DepthView *_openGLView;
  IBOutlet VerticalGuageView *_leftVerticalGuageView;
  IBOutlet VerticalGuageView *_rightVerticalGuageView;
  IBOutlet NSTextField *_angleTextField;
  
  JBFlapGestureRecognizer *_flapGestureRecognizer;
  JBTiltGestureRecognizer *_tiltGestureRecognizer;
}

@property (assign) IBOutlet NSWindow *window;

@end
