//
//  ViewController.m
//  locationCheckinPlayground
//
//  Created by Teddy on 23/12/14.
//  Copyright (c) 2014 letsguang.com. All rights reserved.
//

#import "ViewController.h"
#import "AnnotationDelegate.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSInteger checkinThreshold;
    float threshold;
    float radius;
    CLLocation * userLocation;
    NSThread* myThread;
    bool isCheckinedRecently;
    bool isLastCheckinAttemptSuccess;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // In terms of meters
    radius = 30.0;
    checkinThreshold = 50.0;
    threshold = 100;
    
    self.thresholdLabel.text = [NSString stringWithFormat:@"%d", (int)threshold];
    self.thresholdSlider.value = (int)threshold;
    
    self.mapView.showsUserLocation = YES;

    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // 100 m
    
    SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
        [locationManager respondsToSelector:requestSelector]) {
        //        [locationManager requestAlwaysAuthorization];
        [locationManager requestWhenInUseAuthorization];
        [locationManager startMonitoringSignificantLocationChanges];
        
    } else {
        [locationManager startMonitoringSignificantLocationChanges];
    }
    
    
    
    [locationManager startUpdatingLocation];
    
    
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    // Points around the HK office
//    lats[0] = 22.280845;
//    longs[0] =  114.182224;
//
//    lats[1] = 22.280331;
//    longs[1] = 114.180969;
//
//    lats[2] = 22.280247;
//    longs[2] = 114.181733;
    
    // Points around EC Mall
    // West Entrance
    lats[0] = 39.978650;
    longs[0] =  116.308013;
    
    // East Entrance
    lats[1] = 39.978255;
    longs[1] = 116.308747;
    
    // Service Counter
    lats[2] = 39.978545;
    longs[2] = 116.308113;
    
    for(int i = 0; i < 3; i++)
    {
        cor[i] = CLLocationCoordinate2DMake(lats[i], longs[i]);
        AnnotationDelegate * annotationDelegate = [[AnnotationDelegate alloc] initWithCoordinate:cor[i] andRadius:radius];
        [self.mapView addAnnotation:annotationDelegate];
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:cor[i] radius:radius];
        [self.mapView addOverlay:circle];


    }
    
    // Init for thread
    isCheckinedRecently = false;
    isLastCheckinAttemptSuccess = false;
    myThread = [[NSThread alloc] initWithTarget:self selector:@selector(userInRange) object:nil];

    [myThread start];
    
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay

{
    MKCircleView *circleView = [[MKCircleView alloc] initWithCircle:(MKCircle *)overlay];
    circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
    return circleView;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *newLocation = [locations lastObject];
    userLocation = newLocation;
    CLLocationAccuracy accuracy = newLocation.horizontalAccuracy;
    NSLog(@"Location %f %f\nAccuracy %f\n\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude, accuracy);
    [self appendLog:[NSString stringWithFormat:@"Location %f %f\nAccuracy %f\n\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude, accuracy]];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed %ld",(long)[error code]);
    
}

-(void) userInRange
{
    while (true) {
        if(userLocation != nil && !isCheckinedRecently)
        {
            CLLocationAccuracy accuracy = userLocation.horizontalAccuracy;
            
            // Need to change to generic array size
            float results[3];
            bool resultsFlag[3];
            for(int i = 0; i < 3; i++)
            {
                resultsFlag[i] = NO;
            }
            
            // Need to change to generic array size loop
            for(int i = 0; i < 3; i++)
            {
                CLLocation *location = [[CLLocation alloc]initWithCoordinate:cor[i] altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
                CLLocationDistance distance = [userLocation distanceFromLocation:location];
                
                results[i] = distance - radius + accuracy;
                if(distance <= radius + accuracy)
                {
                    resultsFlag[i] = YES;
                }
            }
            
            // Init, value not meaningful
            float min = -1;
            int minIndex = 0;
            
            for(int i = 0; i < 3; i++)
            {
                float x = results[i];
                if (resultsFlag[i] == YES && ( min == -1 || x < min) )
                {
                    min = x;
                    minIndex = i;
                }
            }
            
            
            if(min == -1)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.sendLabel.text = @"Not In Range";
                    self.sendLabel.textColor = [UIColor blackColor];
                    self.distanceLabel.text = [NSString stringWithFormat:@"--"];
                    isLastCheckinAttemptSuccess = false;
                }];
            }
            else if(min < threshold)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.sendLabel.text = @"In Range";
                    self.sendLabel.textColor = [UIColor redColor];
                    self.distanceLabel.text = [NSString stringWithFormat:@"%d",(int)min];
                    isCheckinedRecently = true;
                    isLastCheckinAttemptSuccess = true;
                }];
                
            }else
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    self.sendLabel.text = @"Not In Range";
                    self.sendLabel.textColor = [UIColor blackColor];
                    self.distanceLabel.text = [NSString stringWithFormat:@"%d",(int)min];
                    isLastCheckinAttemptSuccess = false;
                }];
                
            }
            
            if(isLastCheckinAttemptSuccess)
            {
                // This is for checkin mall, so if there is a successful attempt, we can let it sleep for a long while
                sleep(3000);
            }
            else
            {
                sleep(1);
            }
        }
        else
        {
            if(userLocation == nil)
            {
                sleep(30);
            }
            else
            {
                isCheckinedRecently = false;
                sleep(1);
            }
        }
    }
}

- (IBAction)locate:(id)sender {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    MKUserLocation *UserLocation = self.mapView.userLocation;
    span.latitudeDelta = 0.001;
    span.longitudeDelta = 0.001;
    CLLocationCoordinate2D location;
    location.latitude = UserLocation.coordinate.latitude;
    location.longitude = UserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self.mapView setRegion:region animated:YES];
}


- (IBAction)sliderValueChanged:(id)sender {
    threshold = self.thresholdSlider.value;
    self.thresholdLabel.text = [NSString stringWithFormat:@"%d", (int) threshold];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) appendLog: (NSString *) log {
    log = [NSString stringWithFormat:@"%@%@", log, self.textView.text];
    if ([log length] > 5000)
        log = [log substringToIndex: 5000];
    
    self.textView.text = log;
    [self.textView setContentOffset:CGPointMake(0, 0) animated:YES];
}


@end
