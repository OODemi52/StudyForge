/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
  TouchableOpacity,
  NativeModules,
} from 'react-native';

import {
  Colors,
} from 'react-native/Libraries/NewAppScreen';
import { takeScreenshot, takeCameraPhoto } from './modules/nativeModules';

console.log('CameraManager', NativeModules.CameraManager);

function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}>
        <View
          style={{
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
          }}>
        <TouchableOpacity
          style={styles.button}
          onPress={async () => {
            try {
              await takeScreenshot('/Users/oodemi/Code/StudyForge/frontend/desktop/StudyForge/screenshots');
            } catch (error) {
              console.error('Screenshot error:', error);
            }
          }}
        >
          <Text style={{ color: isDarkMode ? Colors.light : Colors.dark }}>Take Screenshot</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.button}
          onPress={async () => {
            try {
              const result = await takeCameraPhoto();
              console.log('Camera photo taken:', result);
            } catch (error) {
              console.error('Camera error:', error);
            }
          }}
        >
          <Text style={{ color: isDarkMode ? Colors.light : Colors.dark }}>Take Pic</Text>
        </TouchableOpacity>

        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
  button: {
    marginTop: 16,
    backgroundColor: '#007AFF',
    borderRadius: 4,
    paddingVertical: 10,
    paddingHorizontal: 20,
  },
});

export default App;
