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

#import "ZXCGImageLuminanceSourceContext.h"

static const float brightThresholdPercent = 0.55;
static const float alignLuminance = 150;

@interface ZXCGImageLuminanceSourceContext()

@property uint32_t brightPixel;
@property float height;
@property float width;

@property dispatch_queue_t updateQueue;

@end

@implementation ZXCGImageLuminanceSourceContext

+ (id)context {
    static ZXCGImageLuminanceSourceContext *shared = nil;
    @synchronized(self) {
        if (shared == nil) {
            shared = [[self alloc] init];
            [shared reset];
        }
    }
    return shared;
}

- (void)custom {
    _updateQueue = dispatch_queue_create("com.zxing.updateQueue", DISPATCH_QUEUE_SERIAL);
}

- (void)reset {
    _height = 0;
    _width = 0;
    _brightPixel = 0;
}

- (void)setWidth:(float)width height:(float)height {
    _brightPixel = 0;
    _width = width;
    _height = height;
}

- (void)updateRed: (uint32_t)red green: (uint32_t)green blue: (uint32_t)blue {
    float luminance = 0.299 * red + 0.587 * green + 0.114 * blue;
    if (luminance >= alignLuminance) {
        self.brightPixel++;
    }
}

- (ZXCGImageIlluminationType)illuminationType {
    uint32_t brightPixelThreshold = _width * _height * brightThresholdPercent;
    NSLog(@"Compare %d %d", _brightPixel, brightPixelThreshold);

    if (_brightPixel >= brightPixelThreshold) {
        return ZXCGImageIlluminationBrighter;
    }
    return ZXCGImageIlluminationNormal;
}

@end
