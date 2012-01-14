//
//  DepthView.h
//  KinectWings
//
//  Created by John Boiles on 1/13/12.
//  Copyright (c) 2012 John Boiles. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface DepthView : NSOpenGLView {
  BOOL _started;
}
@property (assign, nonatomic) BOOL started;

@end
