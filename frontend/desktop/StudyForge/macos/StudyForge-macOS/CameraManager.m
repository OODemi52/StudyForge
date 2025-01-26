//
//  CameraManager.m
//  StudyForge-macOS
//
//  Created by Demi Daniel on 1/25/25.
//

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(CameraManager, RCTEventEmitter)

RCT_EXTERN_METHOD(captureFrame:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end

