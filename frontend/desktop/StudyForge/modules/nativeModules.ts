import { Alert, NativeModules} from 'react-native';

const { ScreenShotManager } = NativeModules;

if (!ScreenShotManager) {
  console.error('ScreenShotManager is not available');
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
      Alert.alert('Please enable screen recording access in System Settings > Privacy & Security > Screen Recording');
    }
    console.error('Screenshot error:', error);
    throw error;
  }
};

const isPermissionError = (error: any): boolean => {
  return error && typeof error === 'object' && 'code' in error && error.code === 'PERMISSION_ERROR';
};
