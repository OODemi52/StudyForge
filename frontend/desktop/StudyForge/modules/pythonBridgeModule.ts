import { NativeModules } from 'react-native';

const PythonBridge = {
  async captureAndDetect() {
    try {
      // 1. Capture frame from macOS camera
      const frameData = await NativeModules.CameraManager.captureFrame();
      // 2. Send to Python service
      const response = await fetch('http://localhost:5000/detect', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ image: frameData.base64 }),
      });
      return await response.json();
    } catch (error) {
      if (error instanceof Error) {
        return { error: error.message };
      }
      return { error: 'An unknown error occurred' };
    }
  },
};

export default PythonBridge;
