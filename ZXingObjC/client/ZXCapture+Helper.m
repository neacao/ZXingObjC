/*
 * Copyright 2018 ZXing contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXCapture.h"

@implementation ZXCapture (Helper)

- (void)applyOrientation: (NSInteger)orientation
          sourceViewRect: (CGRect)sourceViewRect
            scanViewRect: (CGRect)scanViewRect {
    
    float scanRectRotation;
    float captureRotation;
    BOOL isPortrait = FALSE;
    
    switch (orientation) {
        case 1: // UIDeviceOrientationPortrait
            captureRotation = 0;
            scanRectRotation = 90;
            isPortrait = TRUE;
            break;
            
        case 3: // UIInterfaceOrientationLandscapeLeft
            captureRotation = 90;
            scanRectRotation = 180;
            break;
            
        case 4: //UIInterfaceOrientationLandscapeRight
            captureRotation = 270;
            scanRectRotation = 0;
            break;
            
        case 2: // UIDeviceOrientationPortraitUpsideDown
            captureRotation = 180;
            scanRectRotation = 270;
            isPortrait = TRUE;
            break;
            
        default:
            captureRotation = 0;
            scanRectRotation = 90;
            break;
    }
    
    CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) (captureRotation / 180 * M_PI));
    [self setTransform:transform];
    [self setRotation:scanRectRotation];
    
    CGFloat scaleVideoX, scaleVideoY;
    CGFloat videoSizeX, videoSizeY;
    CGRect transformedVideoRect = scanViewRect;
    
    if([self.sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        videoSizeX = 1080;
        videoSizeY = 1920;
    } else {
        videoSizeX = 720;
        videoSizeY = 1280;
    }
    
    if(isPortrait) {
        scaleVideoX = sourceViewRect.size.width / videoSizeX;
        scaleVideoY = sourceViewRect.size.height / videoSizeY;
        
        // Convert CGPoint under portrait mode to map with orientation of image
        // because the image will be cropped before rotate
        // reference: https://github.com/TheLevelUp/ZXingObjC/issues/222
        CGFloat realX = transformedVideoRect.origin.y;
        CGFloat realY = sourceViewRect.size.width - transformedVideoRect.size.width - transformedVideoRect.origin.x;
        CGFloat realWidth = transformedVideoRect.size.height;
        CGFloat realHeight = transformedVideoRect.size.width;
        transformedVideoRect = CGRectMake(realX, realY, realWidth, realHeight);
        
    } else {
        scaleVideoX = sourceViewRect.size.width / videoSizeY;
        scaleVideoY = sourceViewRect.size.height / videoSizeX;
    }
    
    CGAffineTransform tranform = CGAffineTransformMakeScale(1.0/scaleVideoX, 1.0/scaleVideoY);
    self.scanRect = CGRectApplyAffineTransform(transformedVideoRect, tranform);
}

@end
