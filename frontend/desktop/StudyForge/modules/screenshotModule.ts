import { NativeModules } from 'react-native';

export const takeScreenshot = async (folderPath: string): Promise<void> => {
  if (!NativeModules.ScreenShotManager) {
    throw new Error('ScreenShotManager is not available');
  }
  try {
    return await NativeModules.ScreenShotManager.takeScreenshots(folderPath);
  } catch (error) {
    console.error('Screenshot error:', error);
    throw error;
  }
};
