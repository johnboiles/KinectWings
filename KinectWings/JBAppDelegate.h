//
//  JBAppDelegate.h
//  KinectWings
//
//  Created by John Boiles on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoaOpenNI.h"
#import "DepthView.h"

@interface JBAppDelegate : NSObject <NSApplicationDelegate> {
  IBOutlet DepthView *_openGLView;
}

@property (assign) IBOutlet NSWindow *window;

@end
