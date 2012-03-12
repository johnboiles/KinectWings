//
//  JBAppDelegate.h
//  KinectWings
//
//  Created by John Boiles on 1/13/12.
//  Copyright (c) 2012 John Boiles. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoaOpenNI.h"
#import "ControlData.h"
#import "JBWindow.h"
#import "ARDrone.h"
#import "JBFlyingController.h"

@class DepthView;
@class VerticalGuageView;

@interface JBAppDelegate : NSObject <NSApplicationDelegate, JBWindowDelegate, JBFlyingControllerDelegate, ARDroneDelegate> {
  JBWindow *_window;

  IBOutlet DepthView *_openGLView;
  IBOutlet GLViewController *_droneVideoView;
  IBOutlet VerticalGuageView *_leftVerticalGuageView;
  IBOutlet VerticalGuageView *_rightVerticalGuageView;
  IBOutlet NSTextField *_angleTextField;
  IBOutlet NSTextField *_thrustTextField;
  IBOutlet NSImageView *_indicatorImage;
  IBOutlet NSTextField *_emergencyStatusField;

  JBFlyingController *_flyingController;
  ARDrone *_drone;
  ControlData *_controlData;
}

@property (assign) IBOutlet JBWindow *window;

@end
