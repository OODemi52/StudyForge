/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, { useState } from 'react';
import {
  SafeAreaView,
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

console.log('CameraManager', NativeModules.CameraManager);

function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [attentionState, setAttentionState] = useState(null);

  const startAttentionAnalysis = async () => {
    try {
      setIsAnalyzing(true);
      await startCameraCapture();
      
      // Start periodic attention checks
      const intervalId = setInterval(async () => {
        const result = await PythonBridge.captureAndAnalyzeAttention();
        setAttentionState(result);
      }, 1000); // Adjust interval as needed
      
      return () => {
        clearInterval(intervalId);
        stopCameraCapture();
        setIsAnalyzing(false);
      };
    } catch (error) {
      console.error('Failed to start attention analysis:', error);
      setIsAnalyzing(false);
    }
  };

  return (
    <SafeAreaView style={backgroundStyle}>
      {/* ... existing code ... */}
      <TouchableOpacity
        style={styles.button}
        onPress={() => {
          if (isAnalyzing) {
            stopCameraCapture();
            setIsAnalyzing(false);
          } else {
            startAttentionAnalysis();
          }
        }}
      >
        <Text style={{ color: isDarkMode ? Colors.light : Colors.dark }}>
          {isAnalyzing ? 'Stop Analysis' : 'Start Analysis'}
        </Text>
      </TouchableOpacity>
      
      {attentionState && (
        <View style={styles.attentionInfo}>
          <Text>Attention Status: {attentionState.attention ? 'Attentive' : 'Not Attentive'}</Text>
          {/* Add more UI elements to display eye positions and other metrics */}
        </View>
      )}
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
  previewContainer: {
    flex: 1,
    margin: 20,
  },
});

export default App;
