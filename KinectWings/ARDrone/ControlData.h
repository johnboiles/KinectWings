/*
 *  ControlData.h
 *  ARDroneEngine
 *
 *  Created by Frederic D'HAEYER on 14/01/10.
 *  Copyright 2010 Parrot SA. All rights reserved.
 *
 */
#ifndef _CONTROLDATA_H_
#define _CONTROLDATA_H_
#include "ConstantsAndMacros.h"

#define SMALL_STRING_SIZE	16
#define MEDIUM_STRING_SIZE	64

typedef enum _EMERGENCY_STATE_
{
	EMERGENCY_STATE_EMERGENCY,
	EMERGENCY_STATE_RESET
} EMERGENCY_STATE;

typedef enum _CONFIG_STATE_
{
	CONFIG_STATE_IDLE,
	CONFIG_STATE_NEEDED,
	CONFIG_STATE_IN_PROGRESS,
} CONFIG_STATE;	

typedef struct
{
	/**
	 * Current navdata_connected
	 */
	bool_t navdata_connected;

	/**
	 * Progressive commands
	 * And accelerometers values transmitted to drone, FALSE otherwise
	 */
	float yaw, gaz, accelero_phi, accelero_theta;
	int32_t accelero_flag;

	/**
	 * variable to know if setting is needed
	 */
	EMERGENCY_STATE	isInEmergency;
	
	bool_t wifiReachabled;
	
	int framecounter;
	bool_t needSetEmergency;
	bool_t needSetTakeOff;
	
	int needVideoSwitch;

	bool_t needAnimation;
	char needAnimationParam[SMALL_STRING_SIZE];

	bool_t needLedAnimation;
	char needLedAnimationParam[SMALL_STRING_SIZE];

	CONFIG_STATE applicationDefaultConfigState;
	CONFIG_STATE configurationState;

	/**
	 * Strings to display in interface
	 */	
	char error_msg[MEDIUM_STRING_SIZE];
	char takeoff_msg[SMALL_STRING_SIZE];
	char emergency_msg[SMALL_STRING_SIZE];
} ControlData;

void setSomeConfigs(ControlData controlData);
void initControlData(ControlData controlData);
void resetControlData(ControlData controlData);
void initNavdataControlData(ControlData controlData);
void checkErrors(ControlData controlData);
void controlfps(ControlData controlData);
void sendControls(ControlData controlData);
void getConfiguration(ControlData controlData);
void setApplicationDefaultConfig(ControlData controlData);
void switchTakeOff(ControlData controlData);
void emergency(ControlData controlData);
void handleAccelerometers(ControlData controlData);
void disableAccelerometers(ControlData controlData);
void inputYaw(ControlData controlData, float percent);
void inputGaz(ControlData controlData, float percent);
void inputPitch(ControlData controlData, float percent);
void inputRoll(ControlData controlData, float percent);
void signal_input(ControlData controlData, int new_input);
void send_inputs(ControlData controlData);

#endif // _CONTROLDATA_H_
