//
//  JBWindow.h
//  KinectWings
//
//  Created by John Boiles on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol JBWindowDelegate <NSObject>
- (BOOL)handleKeyDownEvent:(NSEvent *)event;
- (BOOL)handleKeyUpEvent:(NSEvent *)event;
@end

@interface JBWindow : NSWindow {
  id<JBWindowDelegate> _windowDelegate;
}

@property (assign, nonatomic) id<JBWindowDelegate> windowDelegate;

@end
