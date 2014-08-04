//
//  SPPlaceObject.m
//  TheMap
//
//  Created by Ivan Lugo on 4/4/14.
//  Copyright (c) 2014 Ivan Lugo. All rights reserved.
//

#import "SPPlaceObject.h"
#import "MyPoint.h"

@implementation SPPlaceObject

@dynamic geometry, properties;



- (NSString *)getMyName
{
    return [self.properties valueForKey:@"identification"];
}

- (void) getMyPolygonFromDoc:(CBLDocument*)doc forDrawings:drawn_documents
{
        NSMutableArray *temp_read = [doc.properties valueForKeyPath:@"geometry.coordinates"];
        
        NSInteger num_points = [[temp_read objectAtIndex:0] count];
        CLLocationCoordinate2D *place_bounds = malloc(sizeof(CLLocationCoordinate2D) * num_points);
        NSInteger place_counter = 0;
        
        for(NSObject *point in [temp_read objectAtIndex:0])
        {
            CLLocationCoordinate2D myPoint = CLLocationCoordinate2DMake([[(NSArray*) point objectAtIndex:1] floatValue],
                                                                         [[(NSArray*) point objectAtIndex:0] floatValue]);

            place_bounds[place_counter++] = myPoint;
        }
    
        [drawn_documents setObject:[MKPolygon polygonWithCoordinates:place_bounds count:num_points]
                            forKey: [doc.properties valueForKeyPath:@"properties.identification"]];
    
        free(place_bounds);
}

- (MKPolygonRenderer*) getMyRenderer
{
    return NULL;
    
}

- (void) drawSelfToScreen:(MBXMapView*)withMapView fromDocument:(NSMutableDictionary*)drawnDocuments
{
    withMapView.delegate = self;
    NSString *building = [self.properties valueForKey:@"identification"];
    [withMapView addOverlay:[drawnDocuments valueForKey:building]];
}

- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolygonRenderer *polyRenderer = [[MKPolygonRenderer alloc]
                                       initWithPolygon:overlay];
    
    //double boundR = [[self.properties valueForKey:@"bound_color_R"] doubleValue];
    //double boundG = [[self.properties valueForKey:@"bound_color_G"] doubleValue];
    //double boundB = [[self.properties valueForKey:@"bound_color_B"] doubleValue];
    //double fillR = [[self.properties valueForKey:@"fill_color_R"] doubleValue];
    //double fillG = [[self.properties valueForKey:@"fill_color_G"] doubleValue];
    //double fillB = [[self.properties valueForKey:@"fill_color_B"] doubleValue];

    //UIColor *bound_color = [UIColor colorWithRed:boundR green:boundG blue:boundB alpha:.5];
    //UIColor *fill_color = [UIColor colorWithRed:fillR green:fillG blue:fillB alpha:.5];
    UIColor *bound_color;
    UIColor *fill_color;
    if([[self.properties valueForKey:@"building_type"] isEqualToString:@"levine"])
    {
        bound_color = [[UIColor greenColor] colorWithAlphaComponent:0.3];
        fill_color = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
    }
    else if([[self.properties valueForKey:@"building_type"] isEqualToString:@"bivins"])
    {
        bound_color = [[UIColor greenColor] colorWithAlphaComponent:0.3];
        fill_color = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    }
    else if([[self.properties valueForKey:@"building_type"] isEqualToString:@"bryan"])
    {
        bound_color = [[UIColor greenColor] colorWithAlphaComponent:0.3];
        fill_color = [[UIColor redColor] colorWithAlphaComponent:0.5];
    }
    else if([[self.properties valueForKey:@"building_type"] isEqualToString:@"yoh"])
    {
        bound_color = [[UIColor greenColor] colorWithAlphaComponent:0.3];
        fill_color = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
    }
    else
    {
        bound_color = [[UIColor greenColor] colorWithAlphaComponent:0.3];
        fill_color = [[UIColor purpleColor] colorWithAlphaComponent:0.5];
    }
    
    polyRenderer.strokeColor = bound_color;
    polyRenderer.fillColor = fill_color;
    polyRenderer.lineWidth = 1.0;
    
    return polyRenderer;
}


@end
