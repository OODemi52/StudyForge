import { NativeModules } from 'react-native';

const { ScreenShotManager } = NativeModules;

export const takeScreenshot = async (folderPath: string): Promise<void> => {
  try {
    const result = await ScreenShotManager.takeScreenshots(folderPath);
    console.log(result);
  } catch (error) {
    console.log(folderPath);
    console.error('Error taking screenshots:', error);
  }
};
