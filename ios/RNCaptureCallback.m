//
//  RNCaptureCallback.m
//

#import "RNCaptureCallback.h"
#if __has_include(<React/RCTEventDispatcher.h>)
#import <React/RCTEventDispatcher.h>
#else
#import "RCTEventDispatcher.h"
#endif

@interface RNCaptureCallback ()

@end

@implementation RNCaptureCallback

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(addObserverScreenshot) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTakeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];

}

RCT_EXPORT_METHOD(removeObserver:(NSString *)notificationName)
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationUserDidTakeScreenshotNotification
                                                  object:nil];
}

- (void)userDidTakeScreenshot: (NSNotification *)notification {
    NSLog(@"화면 캡처 감지");

    //인공 스크린 샷, 사용자 스크린 샷 동작 시뮬레이션, 스크린 샷 가져 오기
    UIImage *image_ = [self imageWithScreenshot];

    // 샌드박스 사진
    NSString *path_sandox = NSHomeDirectory();
    //사진 저장 경로 설정
    NSString *imagePath = [path_sandox stringByAppendingString:@"/Documents/Screenshot.jpg"];
    //지정된 경로에 사진을 직접 저장
    NSError *error;

    NSData *data = UIImageJPEGRepresentation(image_, 0.5);

    BOOL writeSucceeded = [data writeToFile:imagePath options:0 error:&error];
    if (!writeSucceeded) {
        NSLog( @"사진 저장 샌드 박스 실패" );
        image_ = nil;
    } else {
        NSLog( @"문서에 저장 %@", imagePath );
        [self.bridge.eventDispatcher sendDeviceEventWithName:@"ScreenshotObserver"
                                                        body:@{ @"imagePath": imagePath ? imagePath : [NSNull null] }];
    }
}

// 캡처 한 이미지를 반환
- (UIImage *)imageWithScreenshot
{
    NSData *imageData = [self dataWithScreenshotInPNGFormat];
    return [UIImage imageWithData:imageData];
}

// 현재 화면 캡처
- (NSData *)dataWithScreenshotInPNGFormat
{
    CGSize imageSize = CGSizeZero;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);

    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return UIImagePNGRepresentation(image);
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
