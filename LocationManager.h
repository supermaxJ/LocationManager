//
//  LocationManager.h
//  LocationManager
//
//  Created by 蒋宇 on 2018/5/2.
//  Copyright © 2018年 Snake_Jay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^LocationCompletion)(CLLocationCoordinate2D coordinate,
                                  NSString *error);

@interface LocationManager : NSObject 
@property (nonatomic, assign) BOOL autoUpdate;
@property (nonatomic, assign, readonly) BOOL isRunning;

+ (instancetype)sharedInstance;

- (void)startUpdatingLocationWithCompletion:(LocationCompletion)completion;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
@end
