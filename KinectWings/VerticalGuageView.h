//
//  VerticalGuageView.h
//  KinectWings
//
//  Created by John Boiles on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface VerticalGuageView : NSView {
  double _value;
}
@property (assign, nonatomic) double value;

@end
