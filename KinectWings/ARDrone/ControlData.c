/*
 *  ControlData.m
 *  ARDroneEngine
 *
 *  Created by Frederic D'HAEYER on 14/01/10.
 *  Copyright 2010 Parrot SA. All rights reserved.
 *
 */
#include "ConstantsAndMacros.h"
#include "ControlData.h"

//#define DEBUG_CONTROL

#define constrain(value, min, max) (value) < (min) ? (min) : ((value) > (max) ? (max) : (value))

navdata_unpacked_t ctrlnavdata;
extern char iphone_mac_address[];

void configSentCallback(int32_t success) {
  printf("Config was sent (success=%d)\n", success);
}

// I wonder how we can replace void * callbacks with blocks
//typedef void (^CallbackBlock)(int32_t);

void setSomeConfigs(ControlData controlData) {
  // Not sure how i make these do anything?/?
  //ardrone_control_config.bitrate_ctrl_mode = ARDRONE_VARIABLE_BITRATE_MODE_DISABLED;
  //ardrone_control_config.bitrate = 400;
  //ardrone_control_config.video_channel = ARDRONE_VIDEO_CHANNEL_NEXT;
  //ARDRONE_TOOL_CONFIGURATION_ADDEVENT(bitrate_ctrl_mode, &ardrone_control_config.bitrate_ctrl_mode, NULL);
  //ARDRONE_TOOL_CONFIGURATION_ADDEVENT(bitrate, &ardrone_control_config.bitrate, NULL);
  //ARDRONE_TOOL_CONFIGURATION_ADDEVENT(video_channel, &ardrone_control_config.video_channel, NULL);
  //controlData.configurationState = CONFIG_STATE_NEEDED;

  ARDRONE_VARIABLE_BITRATE enabled = ARDRONE_VARIABLE_BITRATE_MODE_DISABLED;
  uint32_t constantBitrate = 10000;
  ardrone_control_config.bitrate_ctrl_mode = enabled;
  ardrone_control_config.bitrate = constantBitrate;

  // TODO(johnb): Should try to add a callback here and see what happens
  ARDRONE_TOOL_CONFIGURATION_ADDEVENT(bitrate_ctrl_mode, &ardrone_control_config.bitrate_ctrl_mode, configSentCallback);
  ARDRONE_TOOL_CONFIGURATION_ADDEVENT(bitrate, &ardrone_control_config.bitrate, configSentCallback);
}

void setApplicationDefaultConfig(ControlData controlData) {
//	ardrone_application_default_config.navdata_demo = TRUE;
//	ardrone_application_default_config.navdata_options = (NAVDATA_OPTION_MASK(NAVDATA_DEMO_TAG) | NAVDATA_OPTION_MASK(NAVDATA_VISION_DETECT_TAG) | NAVDATA_OPTION_MASK(NAVDATA_GAMES_TAG));

	// I dont think these are doing anything for now
  ardrone_application_default_config.video_codec = UVLC_CODEC;//P264_CODEC;
	ardrone_application_default_config.bitrate_ctrl_mode = ARDRONE_VARIABLE_BITRATE_MODE_DISABLED;
  ardrone_application_default_config.video_channel = ARDRONE_VIDEO_CHANNEL_LARGE_HORI_SMALL_VERT;
  ardrone_application_default_config.bitrate = 1000;
  controlData.applicationDefaultConfigState = CONFIG_STATE_IDLE;
}

ControlData *controlDataCallbackReference = NULL;
void configCallback(bool_t result);
void configCallback(bool_t result) {
	if (result) controlDataCallbackReference->configurationState = CONFIG_STATE_IDLE;
}

void initControlData(ControlData controlData) {
	controlData.framecounter = 0;

	controlData.needSetEmergency = FALSE;
	controlData.needSetTakeOff = FALSE;
	controlData.isInEmergency = FALSE;
	controlData.navdata_connected = FALSE;

	controlData.needAnimation = FALSE;
	vp_os_memset(controlData.needAnimationParam, 0, sizeof(controlData.needAnimationParam));

	controlData.needVideoSwitch = -1;

	controlData.needLedAnimation = FALSE;
	vp_os_memset(controlData.needLedAnimationParam, 0, sizeof(controlData.needLedAnimationParam));

	controlData.wifiReachabled = FALSE;

	strcpy(controlData.error_msg, "");
	strcpy(controlData.takeoff_msg, "take_off");
	strcpy(controlData.emergency_msg, "emergency");

  // This is done as part of the reset
	//initNavdataControlData(controlData);
	resetControlData(controlData);
	ardrone_tool_start_reset();

	controlData.configurationState = CONFIG_STATE_NEEDED;

	ardrone_navdata_write_to_file(FALSE);

	/* Setting default values for ControlEngine */
	controlData.applicationDefaultConfigState = CONFIG_STATE_NEEDED;
}

void initNavdataControlData(ControlData controlData) {
	//drone data
	ardrone_navdata_reset_data(&ctrlnavdata);
}

void resetControlData(ControlData controlData) {
	//printf("reset control data\n");
	controlData.accelero_flag = 0;
	inputPitch(controlData, 0.0);
	inputRoll(controlData, 0.0);
	inputYaw(controlData, 0.0);
	inputGaz(controlData, 0.0);
	initNavdataControlData(controlData);
}

void getConfiguration(ControlData controlData) {
  if(controlData.configurationState == CONFIG_STATE_IDLE)
    controlData.configurationState = CONFIG_STATE_NEEDED;
}

void switchTakeOff(ControlData controlData) {
#ifdef DEBUG_CONTROL
	PRINT("%s\n", __FUNCTION__);
#endif
  controlData.needSetTakeOff = TRUE;
}

void emergency(ControlData controlData) {
#ifdef DEBUG_CONTROL
  PRINT("%s\n", __FUNCTION__);
#endif
  controlData.needSetEmergency = TRUE;
}

void inputYaw(ControlData controlData, float percent) {
#ifdef DEBUG_CONTROL
	PRINT("%s : %f\n", __FUNCTION__, percent);
#endif
  controlData.yaw = constrain(percent, -1.0, 1.0);
}

void inputGaz(ControlData controlData, float percent) {
#ifdef DEBUG_CONTROL
	PRINT("%s : %f\n", __FUNCTION__, percent);
#endif
  controlData.gaz = constrain(percent, -1.0, 1.0);
}

void inputPitch(ControlData controlData, float percent) {
#ifdef DEBUG_CONTROL
	PRINT("%s : %f, accelero_enable : %d\n", __FUNCTION__, percent, (controlData.accelero_flag >> ARDRONE_PROGRESSIVE_CMD_ENABLE) & 0x1 );
#endif
  controlData.accelero_theta = constrain(percent, -1.0, 1.0);
}

void inputRoll(ControlData controlData, float percent) {
#ifdef DEBUG_CONTROL
	PRINT("%s : %f, accelero_enable : %d\n", __FUNCTION__, percent, (controlData.accelero_flag >> ARDRONE_PROGRESSIVE_CMD_ENABLE) & 0x1);
#endif
  controlData.accelero_phi = constrain(percent, -1.0, 1.0);
}

void sendControls(ControlData controlData) {
	ardrone_at_set_progress_cmd(controlData.accelero_flag, controlData.accelero_phi, controlData.accelero_theta, controlData.gaz, controlData.yaw);
}

void checkErrors(ControlData controlData) {
	input_state_t* input_state = ardrone_tool_get_input_state();
	
	strcpy(controlData.error_msg, "");
	
	if(!controlData.wifiReachabled)
	{
		strcpy(controlData.error_msg, "WIFI NOT REACHABLE");
		resetControlData(controlData);
	}
	else
	{
		if(controlData.applicationDefaultConfigState == CONFIG_STATE_NEEDED)
		{
			controlData.applicationDefaultConfigState = CONFIG_STATE_IN_PROGRESS;
			setApplicationDefaultConfig(controlData);
		}
		
		if(controlData.configurationState == CONFIG_STATE_NEEDED)
		{
			controlData.configurationState = CONFIG_STATE_IN_PROGRESS;
      controlDataCallbackReference = &controlData;
			ARDRONE_TOOL_CONFIGURATION_GET(configCallback);
		}			
		
		if(controlData.needSetTakeOff)
		{
			if(ctrlnavdata.ardrone_state & ARDRONE_EMERGENCY_MASK)
			{
				controlData.needSetEmergency = TRUE;
			}
			else
			{
				if(!(ctrlnavdata.ardrone_state & ARDRONE_USER_FEEDBACK_START))
					ardrone_tool_set_ui_pad_start(1);
				else
					ardrone_tool_set_ui_pad_start(0);
				controlData.needSetTakeOff = FALSE;
			}
		}
		
		if(controlData.needSetEmergency)
		{
			controlData.isInEmergency = (ctrlnavdata.ardrone_state & ARDRONE_EMERGENCY_MASK);
			ardrone_tool_set_ui_pad_select(1);
			controlData.needSetEmergency = FALSE;
		}
		
		if(ctrlnavdata.ardrone_state & ARDRONE_NAVDATA_BOOTSTRAP)
		{
			getConfiguration(controlData);
		}
		
		if(ardrone_navdata_client_get_num_retries() >= NAVDATA_MAX_RETRIES)
		{
			strcpy(controlData.error_msg, "CONTROL LINK NOT AVAILABLE");
			controlData.navdata_connected = FALSE;
			resetControlData(controlData);
		}
		else
		{
			controlData.navdata_connected = TRUE;
			if(ctrlnavdata.ardrone_state & ARDRONE_EMERGENCY_MASK)
			{
				if(!controlData.isInEmergency && input_state->select)
					ardrone_tool_set_ui_pad_select(0);
				
				if(ctrlnavdata.ardrone_state & ARDRONE_CUTOUT_MASK)
				{
					strcpy(controlData.error_msg, "CUT OUT EMERGENCY");
				}
				else if(ctrlnavdata.ardrone_state & ARDRONE_MOTORS_MASK)
				{
					strcpy(controlData.error_msg, "MOTORS EMERGENCY");
				}
				else if(!(ctrlnavdata.ardrone_state & ARDRONE_VIDEO_THREAD_ON))
				{
					strcpy(controlData.error_msg, "CAMERA EMERGENCY");
				}
				else if(ctrlnavdata.ardrone_state & ARDRONE_ADC_WATCHDOG_MASK)
				{
					strcpy(controlData.error_msg, "PIC WATCHDOG EMERGENCY");
				}
				else if(!(ctrlnavdata.ardrone_state & ARDRONE_PIC_VERSION_MASK))
				{
					strcpy(controlData.error_msg, "PIC VERSION EMERGENCY");
				}
				else if(ctrlnavdata.ardrone_state & ARDRONE_ANGLES_OUT_OF_RANGE)
				{
					strcpy(controlData.error_msg, "TOO MUCH ANGLE EMERGENCY");
				}
				else if(ctrlnavdata.ardrone_state & ARDRONE_VBAT_LOW)
				{
					strcpy(controlData.error_msg, "BATTERY LOW EMERGENCY");
				}
				else if(ctrlnavdata.ardrone_state & ARDRONE_USER_EL)
				{
					strcpy(controlData.error_msg, "USER EMERGENCY");
				}
				else if(ctrlnavdata.ardrone_state & ARDRONE_ULTRASOUND_MASK)
				{
					strcpy(controlData.error_msg, "ULTRASOUND EMERGENCY");
				}
				else
				{
					strcpy(controlData.error_msg, "UNKNOWN EMERGENCY");
				}
							
				strcpy(controlData.emergency_msg, "");
				strcpy(controlData.takeoff_msg, "take_off");
				
				resetControlData(controlData);
				ardrone_tool_start_reset();
			}
			else // Not emergency landing
			{	
				if(controlData.isInEmergency && input_state->select)
				{
					ardrone_tool_set_ui_pad_select(0);
				}
				
				if(video_stage_get_num_retries() > VIDEO_MAX_RETRIES)
				{
					strcpy(controlData.error_msg, "VIDEO CONNECTION ALERT");
				}
				else if(ctrlnavdata.ardrone_state & ARDRONE_VBAT_LOW)
				{
					strcpy(controlData.error_msg, "BATTERY LOW ALERT");
				}
				else if(ctrlnavdata.ardrone_state & ARDRONE_ULTRASOUND_MASK)
				{
					strcpy(controlData.error_msg, "ULTRASOUND ALERT");
				}
				else if(!(ctrlnavdata.ardrone_state & ARDRONE_VISION_MASK))
				{
					ARDRONE_FLYING_STATE tmp_state = ardrone_navdata_get_flying_state(ctrlnavdata);	
					if(tmp_state == ARDRONE_FLYING_STATE_FLYING)
					{
						strcpy(controlData.error_msg, "VISION ALERT");
					}
				}

				if(!(ctrlnavdata.ardrone_state & ARDRONE_TIMER_ELAPSED))
					strcpy(controlData.emergency_msg, "emergency");
				
				if(input_state->start)
				{
					if(ctrlnavdata.ardrone_state & ARDRONE_USER_FEEDBACK_START)
					{
						strcpy(controlData.takeoff_msg, "take_land");
					}
					else
					{	
						strcpy(controlData.takeoff_msg, "take_off");
						strcpy(controlData.error_msg, "START NOT RECEIVED");
						
					}
				}
				else
				{
					strcpy(controlData.takeoff_msg, "take_off");
				}			
			}
		}
	}
}

