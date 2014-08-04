//
//  SPPlaceObject.h
//  TheMap
//
//  Created by Ivan Lugo on 4/4/14.
//  Copyright (c) 2014 Ivan Lugo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBXMapKit.h"
#import "MyPoint.h"

@interface SPPlaceObject : CBLModel  <MKMapViewDelegate>

@property (strong, nonatomic) NSDictionary *geometry;
@property (strong, nonatomic) NSDictionary *properties;

- (void) getMyPolygonFromDoc:(CBLDocument*)doc forDrawings:drawn_documents;

- (MKPolygonRenderer*) getMyRenderer;
- (void) drawSelfToScreen:withMapView fromDocument:drawnDocuments;
- (MKOverlayRenderer *) mapView:mapView rendererForOverlay:overlay;

@end
