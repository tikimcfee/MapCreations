//
//  FirstViewController.m
//  TheMap
//
//  Created by Ivan Lugo on 1/14/14.
//  Copyright (c) 2014 Ivan Lugo. All rights reserved.
//


#import "FirstViewController.h"
#import "SPPlaceObject.h"
#import "myChoiceButton.h"

@interface FirstViewController () <MKMapViewDelegate>
@property (nonatomic, strong) MBXMapView *mapView;
@property (strong, nonatomic) CBLDatabase *database;
@property (strong, nonatomic) CBLManager *manager;
@property (strong, nonatomic) NSDictionary *theWebFile;
@property (strong, nonatomic) NSDictionary *theUserChoice;
@property (strong, nonatomic) NSMutableDictionary *drawnDocuments;
@property (strong, nonatomic) PlaceObject *currentTapObject;
@property (strong, nonatomic) MKPolygon *currentSelection;
@property (strong, nonatomic) CLLocationManager *userLocationManager;
//@property (strong, nonatomic) CBLGeoRect theQuery;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Constructing the Map, setting delegates, centering
    NSString *mapID = @"sightplan.map-eth3a279";
    //NSString *mapID = @"mozilla-webprod.e91ef8b3";
    //NSString *mapID = @"examples.map-z2effxa8";
    
    self.mapView = [[MBXMapView alloc] initWithFrame:self.view.bounds mapID:mapID ];
    self.mapView.delegate = self;
    self.drawnDocuments = [[NSMutableDictionary alloc] init];
    // home
    // +28.44503171,-81.34699322
    //-81.34290754795074, 28.551325868122174
    // 28.55142/-81.34336
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(28.5525363,-81.3441964) zoomLevel:17 animated:YES];
   
    
    // Initiate location manager for GPS, set accuracy as high as possible
    if ([CLLocationManager locationServicesEnabled]) {
        self.userLocationManager = [[CLLocationManager alloc] init];
        self.userLocationManager.delegate = self;
        CLLocationAccuracy accuracy = 1;
        self.userLocationManager.desiredAccuracy = accuracy;
        [self.userLocationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services are not enabled");
    }
    
    
    // Touch Recognizer for taps on screen to correlate to place objects
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foundTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:tapRecognizer];
    
    
    // 4 Buttons on screen : Start (GPS), Stop (GPS), Show all with 'Misc.' Query, Show All (*)
    //================================================================================================================
    UIButton *levine_button = [[UIButton alloc] initWithFrame: CGRectMake(10, 470, 100, 30)];
    [levine_button addTarget:nil
                          action:@selector(pressed:)
                forControlEvents:UIControlEventTouchDown];

    //[levine_button setTitle:@"Levine" forState: UIControlStateNormal];
    [levine_button setTitle:@"Stop" forState: UIControlStateNormal];

    [levine_button setBackgroundColor:[UIColor colorWithRed:0/255.0f
                                                    green:106/255.0f
                                                     blue:166/255.0f
                                                    alpha:1.0]];
    [levine_button setTitleColor:[UIColor colorWithRed:166/255.0f
                                               green:60/255.0f
                                                blue:0/255.0f
                                               alpha:1.0]
                                            forState:UIControlStateNormal];
    
    UIButton *bivins_button = [[UIButton alloc] initWithFrame: CGRectMake(120, 470, 100, 30)];
    [bivins_button addTarget:nil
                        action:@selector(pressed:)
              forControlEvents:UIControlEventTouchDown];
    
    //[bivins_button setTitle:@"Bivins" forState: UIControlStateNormal];
    [bivins_button setTitle:@"Start" forState: UIControlStateNormal];
    
    [bivins_button setBackgroundColor:[UIColor colorWithRed:0/255.0f
                                                          green:106/255.0f
                                                           blue:166/255.0f
                                                            alpha:1.0]];
    
    [bivins_button setTitleColor:[UIColor colorWithRed:166/255.0f
                                                     green:60/255.0f
                                                      blue:0/255.0f
                                                     alpha:1.0]
                          forState:UIControlStateNormal];
    
    UIButton *misc_button = [[UIButton alloc] initWithFrame: CGRectMake(230, 470, 50, 30)];
    [misc_button addTarget:nil
                      action:@selector(pressed:)
            forControlEvents:UIControlEventTouchDown];
    
    [misc_button setTitle:@"Misc." forState: UIControlStateNormal];
    
    [misc_button setBackgroundColor:[UIColor colorWithRed:0/255.0f
                                                      green:106/255.0f
                                                       blue:166/255.0f
                                                      alpha:1.0]];
    
    [misc_button setTitleColor:[UIColor colorWithRed:166/255.0f
                                                 green:60/255.0f
                                                  blue:0/255.0f
                                                 alpha:1.0]
                        forState:UIControlStateNormal];
    
    UIButton *all_button = [[UIButton alloc] initWithFrame: CGRectMake(230, 430, 50, 30)];
    [all_button addTarget:nil
                    action:@selector(pressed:)
          forControlEvents:UIControlEventTouchDown];
    
    [all_button setTitle:@"*" forState: UIControlStateNormal];
    
    [all_button setBackgroundColor:[UIColor colorWithRed:0/255.0f
                                                    green:106/255.0f
                                                     blue:166/255.0f
                                                    alpha:1.0]];
    
    [all_button setTitleColor:[UIColor colorWithRed:166/255.0f
                                               green:60/255.0f
                                                blue:0/255.0f
                                               alpha:1.0]
                      forState:UIControlStateNormal];
    // -- End Buttons --

    
    // Add buttons to view
    [self.view addSubview:self.mapView];
    [self.view addSubview:levine_button];
    [self.view addSubview:bivins_button];
    [self.view addSubview:misc_button];
    [self.view addSubview:all_button];
    //===============================================================================================================
    
    [self loadCouchbase];
    
    
}

- (void)loadCouchbase
{
    // Creates a shared instance of CBLManager
    self.manager = [CBLManager sharedInstance];
    
    // Create a database!
    //    NSError *error;
    //    self.database = [self.manager databaseNamed:@"place-data" error: &error];
    
    BOOL result = [self sayHello];
    NSLog(@"This instance was %@.", (result ? @"a total success." : @"a failure that may bring upon us the destruction of man."));
}

// creates a database, and then creates, stores, and retrieves a document
- (BOOL) sayHello
{
    // holds error error messages from unsuccessful calls
    NSError *error;
    
    if (!self.manager) {
        NSLog (@"Cannot create shared instance of CBLManager");
        return NO;
    }
    
    // create a name for the database and make sure the name is legal
    NSString *dbname = @"my_place_database";
    if (![CBLManager isValidDatabaseName: dbname]) {
        NSLog (@"Bad database name");
        return NO;
    }
    
    // create a new database
    self.database = [self.manager databaseNamed: dbname error: &error];
    if (!self.database) {
        NSLog (@"Cannot create database. Error message: %@", error.localizedDescription);
        return NO;
    }
    
    // create an object that contains data for the new document
    // NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"maps" ofType:@"geojson"];
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"sp" ofType:@"geojson"];
    NSDictionary *buildings = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:jsonPath]
                                                              options:0
                                                                error:nil];
    
    /*
    NSDictionary *places = [buildings valueForKey:@"features"];
    //NSDictionary *places = [self.theWebFile valueForKey:@"features"];
    for(NSObject *place in places)
    {
        CBLDocument* doc = [self.database createDocument];
        CBLRevision *newRevision = [doc putProperties:(NSDictionary*)place error: &error];
        if (!newRevision) {
            NSLog (@"Already found the entry in the database. Error message: %@", error.localizedDescription);
         
        }
    }
     */
    
    
    
    // REMOVE THIS TO KEEP VERSIONS!
    /*
    int vers = 1;
    vers = arc4random() % 100000;
    NSString *thisV = [NSString stringWithFormat:@"%d", vers];
    */
    
    CBLView *home = [self.database viewNamed:@"home"];
    [home setMapBlock: MAPBLOCK({
        id place = [doc objectForKey:@"type"];
        if (place)
        {
            //NSLog(@"The place found is %@", place);
            emit( [doc valueForKeyPath:@"properties.identification"], doc);
        }
    }) version: @"9.0"];

    
    CBLView *view_misc = [self.database viewNamed:@"Misc"];
    [view_misc setMapBlock: MAPBLOCK({
        id place = [doc valueForKeyPath:@"properties.building_type"];
        if(![place isEqualToString:@"bivins"] && ![place isEqualToString:@"levine"])
        {
            emit( [doc valueForKeyPath:@"properties.identification"], doc);
        }
    }) version: @"1.0"];
    
    CBLView *view_geoquery = [self.database viewNamed:@"taps"];
    [view_geoquery setMapBlock: MAPBLOCK({
        id place = [doc objectForKey:@"geometry"];
        if(place)
        {
            //NSLog(@"Added a new object to the TAPS view in foundTap");
            emit(CBLGeoJSONKey([doc valueForKeyPath:@"geometry"]),
                 [doc valueForKeyPath:@"properties"]);
        }
    }) version: @"1.6"];
    
//    CBLQuery* query = [[self.database viewNamed: @"places"] createQuery];
//    CBLQueryEnumerator *rowEnum = [query run: &error];
//    for (CBLQueryRow* row in rowEnum)
//    {
//        // WARNING - THIS WILL DELETE ALL THE DOCUMENTS IN THE LOCAL DATABASE!!
//        // ** with a tag of 'places'
//        // Use this to clear out the database
//        
//        if(![row.document deleteDocument:&error])
//            NSLog(@"Why not? -- %@", error.localizedDescription);
//        
//        NSLog(@"The place type is : %@", row.key);
//        NSLog(@"The place value is : %@", row.value);
//    }
    
    return YES;
    
}

- (void)pressed:(UIButton*)tapped
{
    NSError *error;
    CBLQuery* query;
    //NSLog(@"Current Location: %@", [self.userLocationManager location]);;
    
    if([[tapped currentTitle] isEqualToString:@"Stop"])
    {
        //query = [[self.database viewNamed: @"Levine"] createQuery];
        [self.userLocationManager stopUpdatingLocation];
    }
    else if( [[tapped currentTitle] isEqualToString:@"Start"])
    {
        //query = [[self.database viewNamed: @"Bivins"] createQuery];
        [self.userLocationManager startUpdatingLocation];
    }
    else if( [[tapped currentTitle] isEqualToString:@"Misc."])
    {
        query = [[self.database viewNamed: @"Misc"] createQuery];
    }
    else if ([[tapped currentTitle] isEqualToString:@"*"])
    {
        query = [[self.database viewNamed: @"home"] createQuery];
    }
    
    CBLQueryEnumerator *rowEnum = [query run: &error];
    
    for(CBLQueryRow* row in rowEnum)
    {
        if([self.drawnDocuments valueForKey:row.key] == NULL)
        {
            SPPlaceObject *place = [SPPlaceObject modelForDocument:[row document]];
            
            [place getMyPolygonFromDoc:[row document] forDrawings:self.drawnDocuments];
            
            [place drawSelfToScreen:self.mapView fromDocument:self.drawnDocuments];
            self.mapView.delegate = self;
        }
        else
        {
            [self.mapView removeOverlay:[self.drawnDocuments valueForKey:row.key]];
            [self.drawnDocuments removeObjectForKey:row.key];
        }
    }
    
    /*
    for(CBLQueryRow* row in rowEnum)
    {
        if([self.drawnDocuments objectForKey:[row document]] == NULL)
        {
            SPPlaceObject *place = [SPPlaceObject modelForDocument:[row document]];
            [place getMyPolygonFromDoc:[row document] forDrawings:self.drawnDocuments];
            [place drawSelfToScreen:self.mapView fromDocument:self.drawnDocuments];
        }
        else
        {
            [self.mapView removeOverlay:[self.drawnDocuments objectForKey:[row document]]];
        }
    }
     */

    NSLog(@"The button tapped is named: %@", [tapped currentTitle]);
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    //self.latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    //self.longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    
    CLLocationCoordinate2D myPoint = CLLocationCoordinate2DMake(location.coordinate.latitude,
                                                                location.coordinate.longitude);
    
    NSError *error;
    CBLGeoRect theQuery = (CBLGeoRect){{myPoint.longitude - .000001, myPoint.latitude - .000001},
                                    {myPoint.longitude + .000001, myPoint.latitude + .000001}};
    
    
    CBLQuery* query = [[self.database viewNamed: @"taps"] createQuery];
    
    query.boundingBox = theQuery;
    CBLQueryEnumerator *rowEnum = [query run: &error];
    
    NSMutableArray *selection = [[NSMutableArray alloc] init];
    
    for (CBLGeoQueryRow* row in rowEnum)
    {
        if([self.drawnDocuments valueForKey:[row.value valueForKey:@"identification"]] != NULL)
        {
            //[self popUpPlaceInformation:row.value];
            [selection addObject: row.document];
        }
    }
    
    [self popUpChoices:selection];

    
    MKPointAnnotation *point1 = [[MKPointAnnotation alloc] init];
    point1.coordinate = myPoint;
    
  
    for( MKPointAnnotation *p in [self.mapView annotations])
    {
        [self.mapView removeAnnotation:p];
    }
    
    [self.mapView addAnnotation:point1];
}

-(IBAction)foundTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    NSError *error;
    
    
     CBLView *view = [self.database viewNamed:@"taps"];
    [view setMapBlock: MAPBLOCK({
        id place = [doc objectForKey:@"geometry"];
        if(place)
        {
            NSLog(@"Added a new object to the TAPS view in foundTap");
            emit(CBLGeoJSONKey([doc valueForKeyPath:@"geometry"]),
                                [doc valueForKeyPath:@"properties"]);
        }
    }) version: @"1.6"];

    
    CBLQuery* query = [[self.database viewNamed: @"taps"] createQuery];
    query.boundingBox = (CBLGeoRect){{tapPoint.longitude - .000001, tapPoint.latitude - .000001}, {tapPoint.longitude + .000001, tapPoint.latitude + .000001} };
    //NSLog(@"{%f, %f}, {%f, %f}", query.boundingBox.min.x, query.boundingBox.min.y, query.boundingBox.max.x, query.boundingBox.max.y);
    CBLQueryEnumerator *rowEnum = [query run: &error];
    
    NSMutableArray *selection = [[NSMutableArray alloc] init];
    
    for (CBLGeoQueryRow* row in rowEnum)
    {
        
        if([self.drawnDocuments valueForKey:[row.value valueForKey:@"identification"]] != NULL)
        {
            //[self popUpPlaceInformation:row.value];
            [selection addObject: row.document];
        }
        
    }
    
    NSLog(@"Did you mean...");
    [self popUpChoices:selection];
    
    /*
    for(CBLDocument *doc in selection)
    {
        NSLog(@"%@", [[[SPPlaceObject modelForDocument:doc] properties] valueForKey:@"identification"]);
    }
     */
    
    
    //NSLog(@"End this find");
    for( MKPointAnnotation *p in [self.mapView annotations])
    {
        [self.mapView removeAnnotation:p];
    }
    
    
    MKPointAnnotation *point1 = [[MKPointAnnotation alloc] init];
    point1.coordinate = tapPoint;
    
    [self.mapView addAnnotation:point1];
}

- (void)popUpPlaceInformation:(NSDictionary*)place_data
{
    NSInteger x = 30;
    NSInteger y = 100;
    NSInteger width = 200;
    NSInteger height = 100;
    UIView *viewPopup = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    viewPopup.tag = 8675309;
    if([self.view viewWithTag:8675309] != NULL)
    {
        [[self.view viewWithTag:8675309]removeFromSuperview];
    }
    if([self.view viewWithTag:163900] != NULL)
    {
        [[self.view viewWithTag:163900]removeFromSuperview];
    }
    [self.view addSubview:viewPopup];
    
    // create Image View with image back (your blue cloud)
    /*
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, width, 200)];
    UIImage *image =  [UIImage imageNamed:@"myimage"];
    [imageView setImage:image];
    [viewPopup addSubview:imageView];
     */
    
    UITextView *place = [[UITextView alloc] initWithFrame:CGRectMake(x, 0, width, 90)];
    [place setTextColor:[UIColor redColor]];
    
    [place setBackgroundColor: [[UIColor whiteColor] colorWithAlphaComponent: 0.6]];
    place.editable = NO;
    NSMutableString *theFocus = [[NSMutableString alloc] init];
    [theFocus appendFormat:@"Type:\n\t%@\n", [place_data valueForKey:@"building_type"]];
    [theFocus appendFormat:@"Bldg. #:\n\t%@\n", [place_data valueForKey:@"building_number"]];
    //[theFocus appendFormat:@"Dance Party?\n\t%@\n", [place_data valueForKey:@"dance_party"]];
    [place setText:theFocus];
    [viewPopup addSubview:place];
    
    // create button into viewPopup
    UIButton *dismissPopUp = [[UIButton alloc] initWithFrame:CGRectMake(30, 60, width, 30)];
    [viewPopup addSubview: dismissPopUp];
    [dismissPopUp setTitle:@"Done" forState:UIControlStateNormal];
    [dismissPopUp addTarget:self action:@selector(dismissInfo) forControlEvents:UIControlEventTouchDown];
    [dismissPopUp setTitleColor:[UIColor colorWithRed:166/255.0f
                                                     green:60/255.0f
                                                      blue:0/255.0f
                                                     alpha:1.0]
                            forState:UIControlStateNormal];
    [viewPopup addSubview:dismissPopUp];
}

- (void)popUpChoices:(NSMutableArray*)place_data
{
    NSInteger x = 30;
    NSInteger y = 100;
    NSInteger width = 200;
    NSInteger height = 100;
    UIView *viewPopup = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    viewPopup.tag = 163900;
    if([self.view viewWithTag:163900] != NULL)
    {
        [[self.view viewWithTag:163900]removeFromSuperview];
    }
    [self.view addSubview:viewPopup];
    
    
     UITextView *place = [[UITextView alloc] initWithFrame:CGRectMake(x, 0, width, 90)];
    [place setTextColor:[UIColor redColor]];
    
    [place setBackgroundColor: [[UIColor whiteColor] colorWithAlphaComponent: 0.6]];
    place.editable = NO;
    [viewPopup addSubview:place];
    
    
    // create buttons into viewPopup
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:place_data.count];
    for(int i = 0; i < place_data.count; i++)
    {
        myChoiceButton *choice = [[myChoiceButton alloc] initWithFrame:CGRectMake(30, i*30, width, 30)];
        //[viewPopup addSubview: choice];
        NSString *test =[[[SPPlaceObject modelForDocument:[place_data objectAtIndex:i]] properties] valueForKey:@"building_type"];
        NSString *test2 = [test stringByAppendingString:@" -- "];
        NSString *test3 = [test2 stringByAppendingString:[[[SPPlaceObject modelForDocument:[place_data objectAtIndex:i]] properties] valueForKey:@"def_level"]];
        NSLog(@"%@", test3);
        // NSLog(@"%@", [[place_data objectAtIndex:i] propertyForKey:@"properties.building_type"]);
        [choice setTitle:test3 forState:UIControlStateNormal];
        [choice addTarget:self action: @selector(dismissChoices:) forControlEvents:UIControlEventTouchDown];
        [choice setTitleColor:[UIColor colorWithRed:166/255.0f
                                                    green:60/255.0f
                                                     blue:0/255.0f
                                                    alpha:1.0]
                           forState:UIControlStateNormal];
        [choice setUserData: [[SPPlaceObject modelForDocument:[place_data objectAtIndex:i]] properties] ];
        [choice setExclusiveTouch:NO];
        [viewPopup addSubview:choice];
        [buttons addObject:choice];
    }
    
    
}


- (void)dismissInfo
{
    [[self.view viewWithTag:8675309]removeFromSuperview];
}

- (void) dismissChoices:(myChoiceButton*) button
{
    [self popUpPlaceInformation:button.userData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
