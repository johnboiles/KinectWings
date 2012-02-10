//
//  JBTiltGestureRecognizer.h
//  KinectWings
//
//  Created by John Boiles on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JB3DGestureRecognizer.h"

@class JBTiltGestureRecognizer;

@protocol JBTiltGestureRecognizerDelegate <NSObject>
- (void)tiltGestureRecognizer:(JBTiltGestureRecognizer *)tiltGestureRecognizer didGetTiltAngle:(double)angle;
@end

@interface JBTiltGestureRecognizer : JB3DGestureRecognizer {
  id<JBTiltGestureRecognizerDelegate> _delegate;
}

@property (weak, nonatomic) id<JBTiltGestureRecognizerDelegate> delegate;

@end
