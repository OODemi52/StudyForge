// modules/nativeModules.js
import { NativeModules } from 'react-native';

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
    console.error('Screenshot error:', error);
    throw error;
  }
};

export const takeCameraPhoto = async () => {
  if (!CameraManager) {
    throw new Error('CameraManager is not available');
  }
  try {
    const result = await CameraManager.captureFrame();
    console.log('Camera result:', result);
    return result;
  } catch (error) {
    console.error('Camera error:', error);
    throw error;
  }
};
