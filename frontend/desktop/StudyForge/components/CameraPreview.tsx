// components/CameraPreview.tsx
import React, { useState, useEffect } from 'react';
import { View, Image, StyleSheet, NativeEventEmitter, NativeModules, Text } from 'react-native';

interface FrameDataEvent {
  base64: string;
}

const CameraPreview = () => {
    const [frameData, setFrameData] = useState<string | null>(null);
    const [error, setError] = useState<string | null>(null);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
      let subscription: any = null;
      let eventEmitter: NativeEventEmitter | null = null;
      let isMounted = true;

      const initializeCamera = async () => {
        try {
          setIsLoading(true);
          const cameraManager = NativeModules.CameraManager;
          // Verify CameraManager exists and has required methods
          if (!cameraManager) {
            throw new Error('CameraManager not available');
          }
          // Wait for permissions before creating event emitter
          const hasPermission = await cameraManager.checkPermission();
          if (!hasPermission) {
            const granted = await cameraManager.requestPermission();
            if (!granted) {
              throw new Error('Camera permission denied');
            }
          } // Initialize camera preview
          await cameraManager.startPreview();
          // Create event emitter only after successful initialization
          eventEmitter = new NativeEventEmitter(cameraManager);
          // Add listener for frame data
          subscription = eventEmitter.addListener(
            'onFrameData',
            (event: FrameDataEvent) => {
              if (isMounted) {
                setFrameData(`data:image/jpeg;base64,${event.base64}`);
                setIsLoading(false);
              }
            }
          );
        } catch (err) {
          if (isMounted) {
            setError(err instanceof Error ? err.message : 'Failed to initialize camera');
            setIsLoading(false);
          }
        }
      };

      initializeCamera();

      return () => {
        isMounted = false;
        if (subscription) {
          subscription.remove();
        }
        const cameraManager = NativeModules.CameraManager;
        if (cameraManager) {
          cameraManager.stopPreview().catch(() => {});
        }
      };
    }, []);

    if (error) {
        return (
          <View style={[styles.container, styles.errorContainer]}>
            <Text style={styles.errorText}>Camera Error: {error}</Text>
          </View>
        );
      }
      if (isLoading) {
        return (
          <View style={[styles.container, styles.loadingContainer]}>
            <Text style={styles.loadingText}>Initializing Camera...</Text>
          </View>
        );
      }
      return (
        <View style={styles.container}>
          {frameData ? (
            <Image
              source={{ uri: frameData }}
              style={styles.preview}
              resizeMode="cover"
            />
          ) : (
            <View style={styles.noFeedContainer}>
              <Text style={styles.noFeedText}>No camera feed available</Text>
            </View>
          )}
        </View>
      );
    };

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: 'black',
    borderRadius: 8,
    overflow: 'hidden',
    minHeight: 240,
  },
  preview: {
    flex: 1,
    aspectRatio: 4 / 3,
  },
  loadingContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#1a1a1a',
  },
  loadingText: {
    color: 'white',
    fontSize: 16,
  },
  errorContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#330000',
  },
  errorText: {
    color: '#ff4444',
    fontSize: 16,
    textAlign: 'center',
    paddingHorizontal: 20,
  },
  noFeedContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#000000',
  },
  noFeedText: {
    color: '#666666',
    fontSize: 16,
  },
});

export default CameraPreview;
