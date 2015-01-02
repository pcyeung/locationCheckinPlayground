//
//  AnnotationDelegate.h
//  locationCheckinPlayground
//
//  Created by Teddy on 23/12/14.
//  Copyright (c) 2014 letsguang.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>


@interface AnnotationDelegate : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) float radius;


- (id) initWithCoordinate: (CLLocationCoordinate2D) c andRadius:(float) r;

@end
