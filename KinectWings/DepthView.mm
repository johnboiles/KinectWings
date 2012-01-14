//
//  DepthView.m
//  KinectWings
//
//  Created by John Boiles on 1/13/12.
//  Copyright (c) 2012 John Boiles. All rights reserved.
//

#import "DepthView.h"
#import <OpenGL/gl.h>
#import "CocoaOpenNI.h"
#include <XnCppWrapper.h>

static void drawTriangle() {
  glColor3f(1.0f, 0.85f, 0.35f);
  glBegin(GL_TRIANGLES);
  {
    glVertex3f(  0.0,  0.6, 0.0);
    glVertex3f( -0.2, -0.3, 0.0);
    glVertex3f(  0.2, -0.3 ,0.0);
  }
  glEnd();
}

@implementation DepthView

@synthesize started=_started;

-(void)drawRect:(NSRect)bounds {
  if (_started) {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // Setup the OpenGL viewpoint
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();

    xn::SceneMetaData sceneMD;
    xn::DepthMetaData depthMD;
    [[CocoaOpenNI sharedOpenNI] depthGenerator].GetMetaData(depthMD);
    glOrtho(0, depthMD.XRes(), depthMD.YRes(), 0, -1.0, 1.0);

    glDisable(GL_TEXTURE_2D);

    // Read next available data
    // If we skip this, the view will appear paused
    [[CocoaOpenNI sharedOpenNI] context].WaitNoneUpdateAll();

    // Process the data
    [[CocoaOpenNI sharedOpenNI] depthGenerator].GetMetaData(depthMD);
    [[CocoaOpenNI sharedOpenNI] userGenerator].GetUserPixels(0, sceneMD);
    DrawDepthMap(depthMD, sceneMD);
    DrawUserInfo();

    // TODO(johnb): I wonder what the difference in swapping buffers and flushing is
    // glutSwapBuffers();
    glFlush();
  } else {
    // Draw a triangle. Why the hell not?
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    drawTriangle();
    glFlush();
  }
}

@end
