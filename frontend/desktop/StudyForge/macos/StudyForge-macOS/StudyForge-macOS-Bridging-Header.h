//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#ifndef StudyForge_Bridging_Header_h
#define StudyForge_Bridging_Header_h

#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>


@interface RCT_EXTERN_MODULE(ScreenShotManager, NSObject)

RCT_EXTERN_METHOD(takeScreenshots:(NSString *)folderPath
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter)

@end

@interface RCT_EXTERN_MODULE(CameraManager, NSObject)

RCT_EXTERN_METHOD(captureFrame:(RCTPromiseResolveBlock)resolver
                  reject:(RCTPromiseRejectBlock)rejecter)

@end


#endif /* StudyForge_Bridging_Header_h */
