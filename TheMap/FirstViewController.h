//
//  FirstViewController.h
//  TheMap
//
//  Created by Ivan Lugo on 1/14/14.
//  Copyright (c) 2014 Ivan Lugo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceObject.h"

@interface FirstViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

- (void)popUpPlaceInformation:(NSDictionary*)place_data;
- (void)popUpChoices:(NSMutableArray*)place_data;

@end
