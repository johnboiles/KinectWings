 /**
 * @file ARDrone.h
 *
 * Copyright 2009 Parrot SA. All rights reserved.
 * @author D HAEYER Frederic
 * @date 2009/10/26
 */

#import <Foundation/Foundation.h>
#import "ARDroneProtocols.h"
#import "GLViewController.h"

@class GLViewController;

/**
 * Define a few methods to make it possible for the game engine to control the Parrot drone
 */
@interface ARDrone : NSObject <ARDroneProtocolIn> {
	BOOL running;
  BOOL inGameOnDemand;
	CGRect screenFrame;
	id <ARDroneProtocolOut> _uidelegate;
  GLViewController *glviewctrl;
}

/**
 * Boolean flag that indicates whether the library is running (YES) or paused (NO).<br/>
 * Note: It is the library sole responsability to handle change of states and modify its behavior; basically, it should pause some of the threads when "paused" then resume everything back to normal when "running".
 */
@property (nonatomic, readonly) BOOL running;

/**
 * Initialize the Parrot library.<br/>
 * Note: the library will clean-up everything it allocates by itself, when being destroyed (i.e. when its retain count reaches 0).
 *
 * @param frame Frame of parent view, used to create the library view (which shall cover the whole screen).
 * @param inGame Initial state of the game at startup.
 * @param uidelegate Pointer to the object that implements the Parrot protocol ("ARDroneProtocol"), which will be called whenever the library needs the game engine to change its state.
 * @param hudconfiguration is a structure to define HUD properties (can be nil)
 * @return Pointer to the newly initialized Parrot library instance.
 */
- (id)initWithFrame:(CGRect)frame withState:(BOOL)inGame withDelegate:(id <ARDroneProtocolOut>)uidelegate;

/**
 * Set what shall be the orientation of the screen when rendering a frame.
 *
 * @param right Orientation of the screen: FALSE for "landscape left", TRUE for "landscape right".
 */
- (void)setScreenOrientationRight:(BOOL)right;

/**
 * Render a frame. Basically, the Parrot Library renders:<ul>
 * <li> A full screen textured quad in the background (= the video sent by the drone);</li>
 * <li> A set of elements in the foreground (=HUD).</li>
 * </ul>
 */
- (void)render;

- (void)takeOff;

- (void)setYaw:(float)yaw;

- (void)setPitch:(float)pitch;

- (void)setVertical:(float)vertical;

- (void)sendControls;

@end
