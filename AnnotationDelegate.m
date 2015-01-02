//
//  AnnotationDelegate.m
//  locationCheckinPlayground
//
//  Created by Teddy on 23/12/14.
//  Copyright (c) 2014 letsguang.com. All rights reserved.
//

#import "AnnotationDelegate.h"

@implementation AnnotationDelegate

- (id) initWithCoordinate: (CLLocationCoordinate2D) c andRadius:(float) r{
    _coordinate = c;
    _radius = r;
    
    return self;
}

@end
