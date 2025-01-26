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
  StatusBar,
  ScrollView,
} from 'react-native';
import PythonBridge from './modules/pythonBridgeModule';

console.log('CameraManager', NativeModules.CameraManager);

function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [attentionState, setAttentionState] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);

  const containerStyle = [
    styles.container,
    isDarkMode && styles.darkMode,
  ];

  const attentionContainerStyle = [
    styles.attentionContainer,
    isDarkMode && styles.darkModeAttentionContainer,
  ];

  const textStyle = [
    styles.buttonText,
    isDarkMode && styles.darkModeText,
  ];

  return (
    <SafeAreaView style={containerStyle}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={isDarkMode ? '#121212' : '#FFFFFF'}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={containerStyle}
        contentContainerStyle={styles.contentContainer}>
        <View style={styles.header}>
          <Text style={[styles.headerText, isDarkMode && styles.darkModeText]}>
            Attention Analysis
          </Text>
        </View>

                <View>
                <TouchableOpacity
                  style={[
                  styles.button,
                  isAnalyzing && styles.disabledButton,
                  isDarkMode && styles.darkModeButton,
                  ]}
                  onPress={async () => {
                  setIsAnalyzing(true);
                  try {
                    await PythonBridge.runAll();
                  } catch (err) {
                    setError(err instanceof Error ? err.message : 'An error occurred');
                    setIsAnalyzing(false);
                  }
                  }}
                  disabled={isAnalyzing}>
                  <Text style={textStyle}>
                  Start Analysis
                  </Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={[
                  styles.button,
                  !isAnalyzing && styles.disabledButton,
                  isDarkMode && styles.darkModeButton,
                  { marginTop: 10 },
                  ]}
                  onPress={async () => {
                  setIsAnalyzing(false);
                  try {
                    await PythonBridge.stopAll();
                  } catch (err) {
                    setError(err instanceof Error ? err.message : 'An error occurred');
                  }
                  }}
                  disabled={!isAnalyzing}>
                  <Text style={textStyle}>
                  Stop Analysis
                  </Text>
                </TouchableOpacity>
                </View>
        {error && (
          <View style={styles.errorContainer}>
            <Text style={styles.errorText}>{error}</Text>
          </View>
        )}

        {attentionState && (
          <View style={attentionContainerStyle}>
            <View style={styles.statusIndicator}>
              <View style={[
                styles.statusDot,
                attentionState.attention ? styles.statusActive : styles.statusInactive
              ]} />
              <Text style={[styles.attentionHeader, isDarkMode && styles.darkModeText]}>
                {attentionState.attention ? 'Attentive' : 'Not Attentive'}
              </Text>
            </View>

            <View style={styles.metricsContainer}>
              <View style={[styles.metricRow, isDarkMode && styles.darkModeMetricRow]}>
                <Text style={[styles.metricLabel, isDarkMode && styles.darkModeMetricLabel]}>
                  Confidence
                </Text>
                <Text style={[styles.metricValue, isDarkMode && styles.darkModeText]}>
                  {(attentionState.confidence * 100).toFixed(1)}%
                </Text>
              </View>

              {attentionState.metrics && (
                <>
                  <View style={[styles.metricRow, isDarkMode && styles.darkModeMetricRow]}>
                    <Text style={[styles.metricLabel, isDarkMode && styles.darkModeMetricLabel]}>
                      Left Eye Openness
                    </Text>
                    <Text style={[styles.metricValue, isDarkMode && styles.darkModeText]}>
                      {attentionState.metrics.left_eye.openness.toFixed(2)}
                    </Text>
                  </View>

                  <View style={[styles.metricRow, isDarkMode && styles.darkModeMetricRow]}>
                    <Text style={[styles.metricLabel, isDarkMode && styles.darkModeMetricLabel]}>
                      Right Eye Openness
                    </Text>
                    <Text style={[styles.metricValue, isDarkMode && styles.darkModeText]}>
                      {attentionState.metrics.right_eye.openness.toFixed(2)}
                    </Text>
                  </View>
                </>
              )}
            </View>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  contentContainer: {
    padding: 16,
  },
  header: {
    paddingVertical: 20,
    marginBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  headerText: {
    fontSize: 24,
    fontWeight: '600',
    textAlign: 'center',
  },
  button: {
    marginVertical: 8,
    backgroundColor: '#007AFF',
    borderRadius: 8,
    paddingVertical: 12,
    paddingHorizontal: 20,
    elevation: 3,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  disabledButton: {
    backgroundColor: '#A0A0A0',
  },
  attentionContainer: {
    marginTop: 20,
    padding: 16,
    backgroundColor: '#F5F5F5',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  attentionHeader: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 12,
  },
  metricsContainer: {
    marginTop: 8,
  },
  metricRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  metricLabel: {
    fontSize: 14,
    color: '#666666',
  },
  metricValue: {
    fontSize: 14,
    fontWeight: '500',
  },
  statusIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  statusDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 8,
  },
  statusActive: {
    backgroundColor: '#4CAF50',
  },
  statusInactive: {
    backgroundColor: '#F44336',
  },
  errorContainer: {
    marginTop: 16,
    padding: 12,
    backgroundColor: '#FFEBEE',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#FFCDD2',
  },
  errorText: {
    color: '#C62828',
    fontSize: 14,
  },
  darkMode: {
    backgroundColor: '#121212',
    color: '#FFFFFF',
  },
  darkModeText: {
    color: '#FFFFFF',
  },
  darkModeButton: {
    backgroundColor: '#2196F3',
  },
  darkModeAttentionContainer: {
    backgroundColor: '#1E1E1E',
    borderColor: '#333333',
  },
  darkModeMetricRow: {
    borderBottomColor: '#333333',
  },
  darkModeMetricLabel: {
    color: '#BBBBBB',
  },
});

export default App;
