//
//  JBArmsExtendedGestureRecognizer.h
//  KinectWings
//
//  Created by John Boiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JB3DGestureRecognizer.h"

@class JBArmsExtendedGestureRecognizer;

@protocol JBArmsExtendedGestureRecognizerDelegate <NSObject>
- (void)armsExtendedGestureRecognizerDidExtendArms:(JBArmsExtendedGestureRecognizer *)armsExtendedGestureRecognizer;
- (void)armsExtendedGestureRecognizerDidFinishExtendingArms:(JBArmsExtendedGestureRecognizer *)armsExtendedGestureRecognizer;
@end

typedef enum {
  JBArmsExtendedGestureRecognizerStatePossible, 
  JBArmsExtendedGestureRecognizerStateExtended, // Arms are out like wings
  JBArmsExtendedGestureRecognizerStateNotExtended // Arms are not out like wings, but we haven't reached _timeoutTime yet
} JBArmsExtendedGestureRecognizerState;

@interface JBArmsExtendedGestureRecognizer : JB3DGestureRecognizer {
  JBArmsExtendedGestureRecognizerState _state;
  NSTimeInterval _timeout;
  NSTimeInterval _timeoutTimestamp; // The amount of time for arms to be down at the side for 
  NSTimer *_timeoutTimer;
}

@property (assign, nonatomic) id<JBArmsExtendedGestureRecognizerDelegate> delegate;

@end
