//
//  MapViewController.m
//  rekola
//
//  Created by Martin Banas on 23/04/14.
//  Copyright (c) 2014 Martin Banas. All rights reserved.
//

#import "MapViewController.h"
#import "RKAnnotation.h"

static CGFloat DefaultLatitude = 50.079167;
static CGFloat DefaultLongtitude = 14.428414;
static CGFloat DefaultUserZoom = 1500;
static CGFloat DefaultDistance = 3500;

@implementation MapViewController {
    NSArray *_bikes;
    
    struct {
        unsigned int firtstUpdate:1;
        unsigned int firstLaunch:1;
        unsigned int loadingData:1;
    } _flags;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RKLocationManagerDidChangeAuthorizationStatusNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _flags.firstLaunch = 1;
    _flags.firtstUpdate = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeAuthorizationStatus) name:RKLocationManagerDidChangeAuthorizationStatusNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_flags.firstLaunch == 1) {
        _flags.firstLaunch = 0;
        
        if ([[RKLocationManager manager] isAuthorized]) {
            [[RKLocationManager manager] startTracking];
            
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Polohové služby nejsou zapnuté, aplikace nebude schopna poskytovat plnou fukncionalitu. Povolit je můžete v nastavení svého zařízení v záložce soukromí.", @"Text message in Alert View.") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"Button title in Alert View.") otherButtonTitles:nil, nil] show];
            
            [self zoomToDefaultLocation];
        }
        _mapView.showsUserLocation = YES;
    }
}

- (void)reloadData {
    if (_flags.loadingData != 1 && _flags.firtstUpdate == 0) {
        _flags.loadingData = 1;
        
        __weak __typeof(self)weakSelf = self;
        [[ContentManager manager] bikesWithLocation:([RKLocationManager manager].currentLocation != nil)? [RKLocationManager manager].currentLocation.coordinate : CLLocationCoordinate2DMake(DefaultLatitude, DefaultLongtitude) completion:^(NSArray *bikes, NSError *error) {
            if (weakSelf) {
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                strongSelf->_bikes = bikes;
                NSMutableArray *annotations = @[].mutableCopy;
                [bikes enumerateObjectsUsingBlock:^(Bike *obj, NSUInteger idx, BOOL *stop) {
                    [annotations addObject:[[RKAnnotation alloc] initWithAnnotation:obj]];
                }];
                
                [strongSelf->_mapView clearAnnotations];
                [strongSelf->_mapView addAnnotations:annotations];
                strongSelf->_flags.loadingData = 0;
            }
        }];
    }
}

#pragma mark - Private methods

-(void)zoomToDefaultLocation {
    
    CLLocationCoordinate2D zoomLocation = [[[CLLocation alloc] initWithLatitude:DefaultLatitude longitude:DefaultLongtitude] coordinate];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, DefaultDistance, DefaultDistance);
    [_mapView setRegion:viewRegion animated:YES];
}

#pragma mark - RKLocationManager Notifications

- (void)didChangeAuthorizationStatus {
    if ([RKLocationManager manager].isAuthorized) {
        [[RKLocationManager manager] startTracking];
    }
}

#pragma mark - MapKitDelegate methods

- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated {
    [_mapView clusterAnnotations];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if ([view.annotation isKindOfClass:[Bike class]]) {
        if ([ContentManager manager].usingBike != nil) {
            [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Uz mate jedno kolo pujcene", @"Text message in Alert View.") delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"Button title in Alert View.") otherButtonTitles:nil, nil] show];
        } else {
            if ([_delegate respondsToSelector:@selector(controller:containerWillChangeType:withObject:)]) {
                [_delegate controller:self containerWillChangeType:ContainerTypeBike withObject:view.annotation];
            }
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *BikeAnnotationViewIdentifier = @"BikeAnnotationViewIdentifier";
    static NSString *ClusterAnnotationViewIdentifier = @"ClusterAnnotationViewIdentifier";
    MKAnnotationView *retPinView = nil;
    
    if (![annotation isKindOfClass:[MKUserLocation class]]) {
        if ([annotation isKindOfClass:[RKAnnotation class]]) {
            MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ClusterAnnotationViewIdentifier];
            
            if (!pinView) {
                pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ClusterAnnotationViewIdentifier];
                pinView.canShowCallout = NO;
            }
            
            // set title
            pinView.pinColor = MKPinAnnotationColorGreen;
            retPinView = pinView;
            
            // Single pin
        } else {
            MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:BikeAnnotationViewIdentifier];
            
            if (!pinView) {
                pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:BikeAnnotationViewIdentifier];
                
                pinView.canShowCallout = YES;
                pinView.pinColor = MKPinAnnotationColorPurple;
                
                // Add a detail disclosure button to the callout.
                UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                pinView.rightCalloutAccessoryView = detailButton;
                
                // TODO: Missing left image for annotation
                // UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
                // pinView.leftCalloutAccessoryView = iconView;
                
            } else {
                pinView.annotation = annotation;
            }
            
            retPinView = pinView;
        }
    }
    return retPinView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (_flags.firtstUpdate == 1) {
        _flags.firtstUpdate = 0;
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, DefaultUserZoom, DefaultUserZoom);
        [_mapView setRegion:region animated:YES];
        [self reloadData];
    }
}

@end
