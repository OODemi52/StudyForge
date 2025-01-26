import { NativeModules } from 'react-native';

const PythonBridge = {
  screenshotInterval: null,

  async runTestAnalyzer() {
    try {
      const response = await fetch('http://127.0.0.1:5000/start_test_analyzer', {
        method: 'GET',
      });
      return await response.json();
    } catch (error) {
      if (error instanceof Error) {
        return { error: error.message };
      }
      return { error: 'An unknown error occurred' };
    }
  },

  async stopTestAnalyzer() {
    try {
      const response = await fetch('http://127.0.0.1:5000/stop_test_analyzer', {
        method: 'GET',
      });
      return await response.json();
    } catch (error) {
      if (error instanceof Error) {
        return { error: error.message };
      }
      return { error: 'An unknown error occurred' };
    }
  },
  

  async captureScreenshots(interval = 25000) {
      setInterval(async () => {
        console.log('Capturing screenshot...');
          await NativeModules.ScreenShotManager.takeScreenshot();
      }, interval);
  },

  async stopCaptureScreenshots() {
    if (this.screenshotInterval) {
      clearInterval(this.screenshotInterval);
      this.screenshotInterval = null;
      console.log('Screenshot capture stopped');
    }
  },

  async runAll() {
    await this.captureScreenshots();
    await this.runTestAnalyzer();
  },

  async stopAll() {
    await this.stopCaptureScreenshots();
    await this.stopTestAnalyzer();
  },
};



export default PythonBridge;
