// modules/nativeModules.js
import { Alert, NativeModules, NativeEventEmitter } from 'react-native';

const { ScreenShotManager, CameraManager } = NativeModules;

if (!ScreenShotManager) {
  console.error('ScreenShotManager is not available');
}

if (!CameraManager) {
  console.error('CameraManager is not available');
}

export const takeScreenshot = async (folderPath: string) => {
  if (!ScreenShotManager) {
    throw new Error('ScreenShotManager is not available');
  }
  try {
    const result = await ScreenShotManager.takeScreenshots(folderPath);
    console.log('Screenshot result:', result);
    return result;
  } catch (error) {
    if (isPermissionError(error)) {
      console.warn('Permission required. Please enable screen recording access.');
      // Add UI prompt to direct user to system preferences
      Alert.alert('Please enable screen recording access in System Settings > Privacy & Security > Screen Recording');
    }
    console.error('Screenshot error:', error);
    throw error;
  }
};

const isPermissionError = (error: any): boolean => {
  return error && typeof error === 'object' && 'code' in error && error.code === 'PERMISSION_ERROR';
};

export const startCameraCapture = async () => {
  if (!CameraManager) {
    throw new Error('CameraManager is not available');
  }
  try {
    await CameraManager.startCapture();
  } catch (error) {
    console.error('Camera capture error:', error);
    throw error;
  }
};

export const stopCameraCapture = async () => {
  if (!CameraManager) {
    throw new Error('CameraManager is not available');
  }
  try {
    await CameraManager.stopCapture();
  } catch (error) {
    console.error('Camera stop error:', error);
    throw error;
  }
};

// Add event listener for detection results
new NativeEventEmitter(CameraManager).addListener('onDetectionResult', (result) => {
  console.log('Face detection result:', result);
  // Handle the detection results here
  // result will contain face count and positions from your Python backend
});

