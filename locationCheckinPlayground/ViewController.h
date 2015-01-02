//
//  ViewController.h
//  locationCheckinPlayground
//
//  Created by Teddy on 23/12/14.
//  Copyright (c) 2014 letsguang.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    float lats[3];
    float longs[3];
    NSMutableArray *coordonates;
    CLLocationCoordinate2D cor[3];
    
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) MKPolyline *routeLine; //your line
@property (nonatomic, retain) MKPolylineView *routeLineView; //overlay view


@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *thresholdLabel;
@property (weak, nonatomic) IBOutlet UISlider *thresholdSlider;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;


@end



