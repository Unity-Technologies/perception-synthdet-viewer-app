#import <Foundation/Foundation.h>
#import "NativeCallProxy.h"


@implementation FrameworkLibAPI

id<NativeCallsProtocol> api = NULL;
+(void) registerAPIforNativeCalls:(id<NativeCallsProtocol>) aApi
{
    api = aApi;
}

@end


extern "C" {
    void arFoundationDidReceiveCameraFrame(const char* bytes, int count) {
        return [api arFoundationDidReceiveCameraFrame:bytes withCount:count];
    }
    
    void settingsJsonDidChange(const char* json, int count) {
        return [api settingsJsonDidChange:json withCount:count];
    }
    
    void imageRequestHandler(const char* bytes, int count) {
        return [api imageRequestHandler:bytes withCount:count];
    }
}

