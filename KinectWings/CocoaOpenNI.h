//
//  CocoaOpenNI.h
//  KinectWings
//
//  Created by John Boiles on 1/13/12.
//  Copyright (c) 2012 John Boiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <XnOpenNI.h>
#include <XnCodecIDs.h>
#include <XnCppWrapper.h>
#include "SceneDrawer.h"
#include "Shared.h"

@interface CocoaOpenNI : NSObject {
  xn::Context _context;
  xn::ScriptNode _scriptNode;
  xn::DepthGenerator _depthGenerator;
  xn::UserGenerator _userGenerator;

  // State;
  XnBool _bNeedPose;
  XnChar _strPose[20];
}

// WARNING: Do not access these as properties. For some strange reason, accessing these like:
// [CocoaOpenNI sharedOpenNI].userGenerator
// causes crashes in xnProductionNodeAddRef. Instead do:
// [[CocoaOpenNI sharedOpenNI] userGenerator]
- (xn::Context)context;
- (xn::DepthGenerator)depthGenerator;
- (xn::UserGenerator)userGenerator;

- (XnStatus)start;

+ (CocoaOpenNI *)sharedOpenNI;

@end
