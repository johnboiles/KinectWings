#include "navdata.h"
#include "ARDroneTypes.h"
#include <control_states.h>
#include <ardrone_tool/Navdata/ardrone_navdata_file.h>
#include <ardrone_tool/Navdata/ardrone_navdata_client.h>

// These globals should only be referenced in this class
navdata_unpacked_t gInstNav;
vp_os_mutex_t gInstNavMutex;
static bool_t gWriteToFile = FALSE;
char gRootDir[256];

void ardrone_navdata_set_root_dir( const char *root_dir )
{
  strcpy(gRootDir, root_dir);
}

static inline C_RESULT ardrone_navdata_init( void* data)
{
  printf("navdata init");
	vp_os_mutex_init( &gInstNavMutex );
	
	vp_os_mutex_lock( &gInstNavMutex);
	ardrone_navdata_reset_data(&gInstNav);
	vp_os_mutex_unlock( &gInstNavMutex);
	
	gWriteToFile = FALSE;
	
	return C_OK;
}

static inline C_RESULT ardrone_navdata_process( const navdata_unpacked_t* const navdata )
{
	if( gWriteToFile )
	{
		if( navdata_file == NULL )
		{
			ardrone_navdata_file_init(gRootDir);
			
			PRINT("Saving in %s file\n", gRootDir);
		}
		ardrone_navdata_file_process( navdata );
	}
	else
	{
		if(navdata_file != NULL)
			ardrone_navdata_file_release();			
	}
	
	vp_os_mutex_lock( &gInstNavMutex);
/*	gInstNav.ardrone_state = navdata->ardrone_state;
	gInstNav.vision_defined = navdata->vision_defined;
	vp_os_memcpy(&gInstNav.navdata_demo, &navdata->navdata_demo, sizeof(navdata_demo_t));
	vp_os_memcpy(&gInstNav.navdata_vision_detect, &navdata->navdata_vision_detect, sizeof(navdata_vision_detect_t));
*/
	vp_os_memcpy(&gInstNav, navdata, sizeof(navdata_unpacked_t));
	vp_os_mutex_unlock( &gInstNavMutex );

	return C_OK;
}

static inline C_RESULT ardrone_navdata_release( void )
{
  printf("navdata release");
	ardrone_navdata_file_release();
	return C_OK;
}

C_RESULT ardrone_navdata_write_to_file(bool_t enable)
{
	gWriteToFile = enable;
	return C_OK;
}

C_RESULT ardrone_navdata_reset_data(navdata_unpacked_t *nav)
{
	C_RESULT result = C_FAIL;
	
	if(nav)
	{
		vp_os_memset(nav, 0x0, sizeof(navdata_unpacked_t));
		result = C_OK;
	}
	
	return result;
}	

C_RESULT ardrone_navdata_get_data(navdata_unpacked_t *data)
{
	C_RESULT result = C_FAIL;
	
	if(data)
	{
		vp_os_mutex_lock( &gInstNavMutex );
/*		data->ardrone_state = gInstNav.ardrone_state;
		data->vision_defined = gInstNav.vision_defined;
		vp_os_memcpy(&data->navdata_demo, &gInstNav.navdata_demo, sizeof(navdata_demo_t));
		vp_os_memcpy(&data->navdata_vision_detect, &gInstNav.navdata_vision_detect, sizeof(navdata_vision_detect_t));
*/
		vp_os_memcpy(data, &gInstNav, sizeof(navdata_unpacked_t));
		vp_os_mutex_unlock( &gInstNavMutex );
		result = C_OK;
	}
	
	return result;
}

ARDRONE_FLYING_STATE ardrone_navdata_get_flying_state(navdata_unpacked_t data)
{
	ARDRONE_FLYING_STATE tmp_state;
	switch ((data.navdata_demo.ctrl_state >> 16)) 
	{
		case CTRL_FLYING:
		case CTRL_HOVERING:
		case CTRL_TRANS_GOTOFIX:
			tmp_state = ARDRONE_FLYING_STATE_FLYING;
			break;
			
		case CTRL_TRANS_TAKEOFF:
			tmp_state = ARDRONE_FLYING_STATE_TAKING_OFF;
			break;
			
		case CTRL_TRANS_LANDING:
			tmp_state = ARDRONE_FLYING_STATE_LANDING;
			break;
			
		case CTRL_DEFAULT:
		case CTRL_LANDED:
		default:
			tmp_state = ARDRONE_FLYING_STATE_LANDED;
			break;
	}
	
	return tmp_state;
}

BEGIN_NAVDATA_HANDLER_TABLE
NAVDATA_HANDLER_TABLE_ENTRY(ardrone_navdata_init, ardrone_navdata_process, ardrone_navdata_release, NULL)
END_NAVDATA_HANDLER_TABLE
