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
#import "ControlData.h"

@class ARDrone;
@class GLViewController;

@protocol ARDroneDelegate <NSObject>
- (void)drone:(ARDrone *)drone didEmergencyWithMessage:(NSString *)message;
- (void)droneDidEndEmergency:(ARDrone *)drone;
@end

/**
 * Define a few methods to make it possible for the game engine to control the Parrot drone
 */
@interface ARDrone : NSObject <ARDroneProtocolIn> {
  id<ARDroneDelegate> delegate;
	BOOL running;
  ControlData controlData;
  BOOL inGameOnDemand;
  GLViewController *glviewctrl;
}

@property (assign, nonatomic) id<ARDroneDelegate> delegate;

/**
 * Boolean flag that indicates whether the library is running (YES) or paused (NO).<br/>
 * Note: It is the library sole responsability to handle change of states and modify its behavior; basically, it should pause some of the threads when "paused" then resume everything back to normal when "running".
 */
@property (nonatomic, readonly) BOOL running;
@property (readonly, nonatomic) ControlData *controlData;
/**
 * Initialize the Parrot library.<br/>
 * Note: the library will clean-up everything it allocates by itself, when being destroyed (i.e. when its retain count reaches 0).
 *
 * @param frame Frame of parent view, used to create the library view (which shall cover the whole screen).
 * @param inGame Initial state of the game at startup.
 * @param hudconfiguration is a structure to define HUD properties (can be nil)
 * @return Pointer to the newly initialized Parrot library instance.
 */
- (id)initWithFrame:(CGRect)frame withState:(BOOL)inGame;

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

- (void)setRoll:(float)roll;

- (void)setVertical:(float)vertical;

- (void)sendControls;

- (void)setSomeControls;

- (void)resetControls;

@end
