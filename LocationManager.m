//
//  LocationManager.m
//  LocationManager
//
//  Created by 蒋宇 on 2018/5/2.
//  Copyright © 2018年 Snake_Jay. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager () <CLLocationManagerDelegate>
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) LocationCompletion completion;

@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation LocationManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static LocationManager *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [[LocationManager alloc] init];
    });
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        if (!_autoUpdate) {
            _autoUpdate = !CLLocationManager.significantLocationChangeMonitoringAvailable;
        }
    }
    return self;
}

- (void)resetLocation {
    _coordinate = CLLocationCoordinate2DMake(.0f, .0f);
}

- (void)startUpdatingLocationWithCompletion:(LocationCompletion)completion {
    self.completion = completion;
    [self initial];
}

- (void)startUpdatingLocation {
    [self initial];
}

- (void)stopUpdatingLocation {
    if (_autoUpdate) {
        [_locationManager stopUpdatingLocation];
    } else {
        [_locationManager stopMonitoringSignificantLocationChanges];
    }
    
    [self resetLocation];
    
}

- (void)initial {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    
    [self startLocationManager];
}

- (void)startLocationManager {
    if (_autoUpdate) {
        [_locationManager startUpdatingLocation];
    } else {
        [_locationManager startMonitoringSignificantLocationChanges];
    }
    _isRunning = YES;
}

- (void)stopLocationManager {
    if (_autoUpdate) {
        [_locationManager stopUpdatingLocation];
    } else {
        [_locationManager stopMonitoringSignificantLocationChanges];
    }
    _isRunning = NO;
}

#pragma mark -  CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self stopLocationManager];
    [self resetLocation];
    if (self.completion) {
        self.completion(CLLocationCoordinate2DMake(.0, .0), error.localizedDescription);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSArray *locations_ = locations;
    CLLocation *last = locations_.lastObject;
    CLLocationCoordinate2D coordinate = last.coordinate;
    self.coordinate = coordinate;
    if (self.completion) {
        self.completion(coordinate, nil);
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    BOOL authorised = NO;
    NSString *statusText = nil;
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            statusText = @"用户没有决定是否使用定位服务";
            break;
        case kCLAuthorizationStatusRestricted:
            statusText = @"定位服务授权状态是受限制的";
            break;
        case kCLAuthorizationStatusDenied:
            statusText = @"定位服务授权状态已经被用户明确禁止，或者在设置里的定位服务中关闭";
            break;
        default:
            authorised = YES;
            break;
    }
    
    if (authorised) {
        [self startLocationManager];
    } else {
        [self resetLocation];
        
        if (self.completion) {
            self.completion(self.coordinate, statusText);
        }
    }

}
@end
