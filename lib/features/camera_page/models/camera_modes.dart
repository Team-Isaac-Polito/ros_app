/*
 * These are the possible camera state
 * 0: OFF
 * 1: INITIALIZING
 * 2: SENSOR_CRATE
 * 3: MAPPING
 * 
 * The QR and the Hazmat are running in SENSOR_CRATE
 * and MAPPING
 */

enum CAMERA_MODE {
  OFF,
  INITIALIZING,
  SENSOR_CRATE,
  MAPPING
}