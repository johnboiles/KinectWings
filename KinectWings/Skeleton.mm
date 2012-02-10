//
//  Skeleton.m
//  KinectWings
//
//  Created by John Boiles on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Skeleton.h"

@implementation Skeleton

@synthesize head, neck, torso, leftShoulder, leftElbow, leftHand, rightShoulder, rightElbow, rightHand;

+ (Skeleton *)skeletonFromUserGenerator:(xn::UserGenerator)userGenerator user:(XnUserID)user {
  Skeleton *skeleton = [[Skeleton alloc] init];
  skeleton.head = GetJointPosition(userGenerator, user, XN_SKEL_HEAD);
  skeleton.neck = GetJointPosition(userGenerator, user, XN_SKEL_NECK);
  skeleton.torso = GetJointPosition(userGenerator, user, XN_SKEL_TORSO);

  skeleton.leftShoulder = GetJointPosition(userGenerator, user, XN_SKEL_LEFT_SHOULDER);
  skeleton.leftElbow = GetJointPosition(userGenerator, user, XN_SKEL_LEFT_ELBOW);
  skeleton.leftHand = GetJointPosition(userGenerator, user, XN_SKEL_LEFT_HAND);

  skeleton.rightShoulder = GetJointPosition(userGenerator, user, XN_SKEL_RIGHT_SHOULDER);
  skeleton.rightElbow = GetJointPosition(userGenerator, user, XN_SKEL_RIGHT_ELBOW);
  skeleton.rightHand = GetJointPosition(userGenerator, user, XN_SKEL_RIGHT_HAND);

  return [skeleton autorelease];
}

@end

inline XnSkeletonJointPosition GetJointPosition(xn::UserGenerator userGenerator, XnUserID user, XnSkeletonJoint joint) {
  XnSkeletonJointPosition jointPosition;
  xnGetSkeletonJointPosition(userGenerator.GetHandle(), user, joint, &jointPosition);
  return jointPosition;
}
