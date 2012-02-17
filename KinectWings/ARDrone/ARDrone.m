/**
 * @file ARDrone.m
 *
 * Copyright 2009 Parrot SA. All rights reserved.
 * @author D HAEYER Frederic
 * @date 2009/10/26
 */
#import "InternalProtocols.h"
#import "ARDrone.h"
#import "GLViewController.h"

//#define DEBUG_ENNEMIES_DETECTON
#define DEBUG_NAVIGATION_DATA
//#define DEBUG_DETECTION_CAMERA
//#define DEBUG_DRONE_CAMERA

extern navdata_unpacked_t ctrlnavdata;
extern char drone_address[];
extern ControlData ctrldata;
static bool_t threadStarted = false;
char root_dir[256];

static void ARDroneCallback(ARDRONE_ENGINE_MESSAGE msg) {
  NSLog(@"AR drone callback %d", msg);
	switch(msg) {
		case ARDRONE_ENGINE_INIT_OK:
			threadStarted = true;
			break;
		default:
			break;
	}
}

@interface ARDrone () <NavdataProtocol>
- (void)parrotNavdata:(navdata_unpacked_t*)data;
- (void)checkThreadStatus;
@end

/**
 * Define a few methods to make it possible for the game engine to control the Parrot drone
 */
@implementation ARDrone
@synthesize running;

/**
 * Initialize the Parrot library.<br/>
 * Note: the library will clean-up everything it allocates by itself, when being destroyed (i.e. when its retain count reaches 0).
 *
 * @param frame Frame of parent view, used to create the library view (which shall cover the whole screen).
 * @param inGame Initial state of the game at startup.
 * @param uidelegate Pointer to the object that implements the Parrot protocol ("ARDroneProtocol"), which will be called whenever the library needs the game engine to change its state.
 * @return Pointer to the newly initialized Parrot library instance.
 */
- (id)initWithFrame:(CGRect)frame withState:(BOOL)inGame withDelegate:(id <ARDroneProtocolOut>)uidelegate {
	if ((self = [super init])) {
		NSLog(@"Frame ARDrone Engine : %f, %f", frame.size.width, frame.size.height);

		running = NO;
		inGameOnDemand = inGame;
		threadStarted = false;
		_uidelegate = uidelegate;
		
		// Update user path
		[[NSFileManager defaultManager]changeCurrentDirectoryPath:[[NSBundle mainBundle] resourcePath]];
		//creates paths so that you can pull the app's path from it
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		strcpy(root_dir, [[paths objectAtIndex:0] cStringUsingEncoding:NSUTF8StringEncoding]);

    // Create View Controller
		//glviewctrl = [[GLViewController alloc] initWithFrame:frame withDelegate:self];

		// Create main view controller
		initControlData();
		
		ardroneEngineStart(ARDroneCallback, "KinectWings", "JohnBoiles");
		[self checkThreadStatus];
	}
	
	return self;
}

- (void)checkThreadStatus {
	NSLog(@"%s", __FUNCTION__);
  // Ok so this needs to be set once the wifi is turned on
  ctrldata.wifiReachabled = threadStarted;
	if(threadStarted) {
		running = YES;
		[_uidelegate executeCommandOut:ARDRONE_COMMAND_RUN withParameter:(void*)drone_address fromSender:self];
		[self changeState:inGameOnDemand];
	} else {
		[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkThreadStatus) userInfo:nil repeats:NO];
	}
}

/*
 * Render a frame. Basically, the Parrot Library renders:<ul>
 * <li> A full screen textured quad in the background (= the video sent by the drone);</li>
 * <li> A set of elements in the foreground (=HUD).</li>
 * </ul>
 */
- (void)render {
	// Make sure the library is "running"
	[glviewctrl drawView];
}

- (void)dealloc {
	[self changeState:NO];
	[super dealloc];
}

- (void)parrotNavdata:(navdata_unpacked_t*)data {
//  NSLog(@"parrotNavdata");
	ardrone_navdata_get_data(data);
}

/**
 * Get the latest drone's navigation data.
 *
 * @param data Pointer to a navigation data structure.
 */
- (void)navigationData:(ARDroneNavigationData*)data {
  static int numsamples = 0;
  if(numsamples++ > 64) {
    NSLog(@"x : %f, y : %f, z : %f, flying state : %d, navdata video num frame : %d, video num frames : %d", data->angularPosition.x, data->angularPosition.y, data->angularPosition.z, data->flyingState, data->navVideoNumFrames, data->videoNumFrames);		
    numsamples = 0;
  }
}

/**
 * Get the latest detection camera structure (rotation and translation).
 *
 * @param data Pointer to a detection camera structure.
 */
- (void)detectionCamera:(ARDroneDetectionCamera*)camera {
  static int numsamples = 0;
  if(numsamples++ > 64) {
    NSLog(@"Detection Camera Rotation : %f %f %f %f %f %f %f %f %f",
					camera->rotation[0][0], camera->rotation[0][1], camera->rotation[0][2],
					camera->rotation[1][0], camera->rotation[1][1], camera->rotation[1][2],
					camera->rotation[2][0], camera->rotation[2][1], camera->rotation[2][2]);
    NSLog(@"Detection Camera Translation : %f %f %f", camera->translation[0], camera->translation[1], camera->translation[2]);
    NSLog(@"Detection Camera Tag Index : %d", camera->tag_index);

    numsamples = 0;
  }
}

/**
 * Get the latest drone camera structure (rotation and translation).
 *
 * @param data Pointer to a drone camera structure.
 */
- (void)droneCamera:(ARDroneCamera*)camera {
  static int numsamples = 0;
  if(numsamples++ > 64) {
    NSLog(@"Drone Camera Rotation : %f %f %f %f %f %f %f %f %f",
				  camera->rotation[0][0], camera->rotation[0][1], camera->rotation[0][2],
				  camera->rotation[1][0], camera->rotation[1][1], camera->rotation[1][2],
				  camera->rotation[2][0], camera->rotation[2][1], camera->rotation[2][2]);
    NSLog(@"Drone Camera Translation : %f %f %f", camera->translation[0], camera->translation[1], camera->translation[2]);
    numsamples = 0;
  }
}

/**
 * Exchange enemies data.<br/>
 * Note: basically, data should be provided by the Parrot library when in multiplayer mode (enemy type = "HUMAN"), and by the game controller when in single player mode (enemy type = "AI").
 *
 * @param data Pointer to an enemies data structure.
 */
- (void)humanEnemiesData:(ARDroneEnemiesData*)data {
  static int old_value = 0;
  if(old_value != data->count) 
    NSLog(@"enemies detected : %d", data->count);
  old_value = data->count;
}

- (void)changeState:(BOOL)inGame {
  NSLog(@"change state to %d", inGame);
	// Check whether there is a change of state
	if(threadStarted) {
		// Change the state of the library
		if(inGame) ardroneEngineResume();
		else ardroneEnginePause();
		running = inGame;
	} else {
		inGameOnDemand = inGame;
	}
}

- (void)executeCommandIn:(ARDRONE_COMMAND_IN_WITH_PARAM)commandIn fromSender:(id)sender refreshSettings:(BOOL)refresh {
  NSLog(@"executeCommandIn");
  //[mainviewctrl git grep ":commandIn fromSender:sender refreshSettings:refresh];	
}

- (void)executeCommandIn:(ARDRONE_COMMAND_IN)commandId withParameter:(void*)parameter fromSender:(id)sender {
  NSLog(@"executeCommandIn");
  //[mainviewctrl executeCommandIn:commandId withParameter:parameter fromSender:sender];	
}

- (void)setDefaultConfigurationForKey:(ARDRONE_CONFIG_KEYS)key withValue:(void *)value {
  NSLog(@"setDefaultConfigurationKey");
  //[mainviewctrl setDefaultConfigurationForKey:key withValue:value];
}

- (BOOL)checkState {
	return running;
}

- (void)camera {
  /*
   int value;
   value = ARDRONE_CAMERA_DETECTION_NONE;
   [self setDefaultConfigurationForKey:ARDRONE_CONFIG_KEY_DETECT_TYPE withValue:&value];
   value = 0;
   [self setDefaultConfigurationForKey:ARDRONE_CONFIG_KEY_CONTROL_LEVEL withValue:&value];
   */
}

- (void)takeOff {
  switchTakeOff();
}

- (void)setYaw:(float)yaw {
  inputYaw(yaw);
  sendControls();
}

- (void)setPitch:(float)pitch {
  inputPitch(pitch);
  sendControls();
}

extern navdata_unpacked_t ctrlnavdata;

- (void)timerThread {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // Top-level pool

	ardrone_timer_t timer;
	int refreshTimeInUs = 1000000 / kFPS;

	ardrone_timer_reset(&timer);
	ardrone_timer_update(&timer);

	while(YES) {
    int delta = ardrone_timer_delta_us(&timer);
    if(delta >= refreshTimeInUs) {
      // Render frame
      ardrone_timer_update(&timer);

      [self parrotNavdata:&ctrlnavdata];
      //[self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:YES];

      checkErrors();
      //NSLog(@"%s", ctrldata.error_msg);
      ctrldata.framecounter = (ctrldata.framecounter + 1) % kFPS;
    } else {
      //printf("Time waited : %d us\n", refreshTimeInUs - delta);
      usleep(refreshTimeInUs - delta);
    }
	}
  [pool release];  // Release the objects in the pool.
}

@end

