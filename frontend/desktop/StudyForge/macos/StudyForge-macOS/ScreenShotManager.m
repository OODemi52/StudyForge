//
//  ScreenShotManager.m
//  StudyForge-macOS
//
//  Created by Demi Daniel on 1/25/25.
//

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(ScreenShotManager, NSObject)

RCT_EXTERN_METHOD(takeScreenshots:(NSString *)folderPath
                  resolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
