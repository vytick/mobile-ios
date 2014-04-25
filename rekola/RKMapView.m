//
//  RKMapView.m
//  rekola
//
//  Created by Martin Banas on 25/04/14.
//  Copyright (c) 2014 Martin Banas. All rights reserved.
//

#import "RKMapView.h"
#import "RKAnnotation.h"

@implementation RKMapView {
    NSMutableSet *_allAnnotations;
    MKCoordinateRegion _lastMapRegion;
    MKMapRect _lastMapRect;
    
    BOOL _needsClusturing;
    
    CLLocationDistance _clusterSize;
    CLLocationDegrees _minClusterDelta;
    NSUInteger _minAnnotationsForCluster;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _allAnnotations = [NSMutableSet new];
    _clusterSize = 0.15;
    _minClusterDelta = 0.;
    _minAnnotationsForCluster = 4.;
    
    _clusteringEnabled = YES;
    _needsClusturing = YES;
}

#pragma mark - MKMapView Accessors

- (void)addAnnotation:(id < MKAnnotation >)annotation {
    [_allAnnotations addObject:annotation];
    _needsClusturing = YES;
    [self clusterAnnotations];
}

- (void)addAnnotations:(NSArray *)annotations {
    [_allAnnotations addObjectsFromArray:annotations];
    _needsClusturing = YES;
    [self clusterAnnotations];
}

- (void)removeAnnotation:(id < MKAnnotation >)annotation {
    [_allAnnotations removeObject:annotation];
    _needsClusturing = YES;
    [self clusterAnnotations];
}

- (void)removeAnnotations:(NSArray *)annotations{
    for (id<MKAnnotation> annotation in annotations) {
        [_allAnnotations removeObject:annotation];
    }
    _needsClusturing = YES;
    [self clusterAnnotations];
}

- (NSArray *)annotations {
    return [_allAnnotations allObjects];
}

- (NSArray *)displayedAnnotations {
    return super.annotations;
}

- (void)clearAnnotations {
    _allAnnotations = [NSMutableSet new];
    [super removeAnnotations:[self displayedAnnotations]];
}

#pragma mark - Private methods

- (BOOL)mapDidZoom {
    return (fabs(_lastMapRect.size.width - self.visibleMapRect.size.width) > 0.1f);
}

- (BOOL)mapDidMove {
    CGPoint lastPoint = [self convertCoordinate:_lastMapRegion.center toPointToView:self];
    CGPoint currentPoint = [self convertCoordinate:self.region.center toPointToView:self];
    
    return ((fabs(lastPoint.x - currentPoint.x) > self.frame.size.width / 3.0) ||
            (fabs(lastPoint.y - currentPoint.y) > self.frame.size.height / 3.0));
}

#pragma mark - Clustering

- (void)clusterAnnotations {
    
    if (_needsClusturing || MKMapRectIsNull(_lastMapRect) || [self mapDidZoom] || [self mapDidMove]) {

        NSMutableArray *annotations = [[_allAnnotations allObjects] mutableCopy];
        //[self annotationsForVisibleRect:[_allAnnotations allObjects]].mutableCopy;
        NSArray *clusteredAnnotations = nil;
        
        if (_clusteringEnabled && (self.region.span.longitudeDelta > _minClusterDelta)) {
            CLLocationDistance clusterRadius = self.region.span.longitudeDelta * _clusterSize;
            clusteredAnnotations = [self clusteringWithAnnotations:annotations clusterRadius:clusterRadius];
            
        } else {
            clusteredAnnotations = annotations;
        }
        
        NSMutableArray *annotationsToDisplay = clusteredAnnotations.mutableCopy;
        
        for (NSUInteger i = 0; i < annotationsToDisplay.count; i++) {
            RKAnnotation *ann = annotationsToDisplay[i];
            if ([ann isKindOfClass:[RKAnnotation class]] && ann.clusterAnnotations.count < _minAnnotationsForCluster) {
                [annotationsToDisplay removeObject:ann];
                [annotationsToDisplay addObjectsFromArray:ann.clusterAnnotations];
                i--;
            }
        }
        
        for (id<MKAnnotation> annotation in self.displayedAnnotations) {
            if (annotation == self.userLocation) {
                continue;
            }
            
            if (![annotationsToDisplay containsObject:annotation]) {
                [super removeAnnotation:annotation];
                
            } else {
                [annotationsToDisplay removeObject:annotation];
            }
        }
        
        [super addAnnotations:annotationsToDisplay];

        _lastMapRect = self.visibleMapRect;
        _lastMapRegion = self.region;
        _needsClusturing = NO;
    }
}

#pragma mark - Helpers

- (NSArray *)annotationsForVisibleRect:(NSArray *)originAnnotations {
    
    NSMutableArray *annotations = @[].mutableCopy;
    
    CLLocationDistance a = self.region.span.latitudeDelta / 2.0;
    CLLocationDistance b = self.region.span.longitudeDelta / 2.0;
    CLLocationDistance radius = sqrt(pow(a, 2.0) + pow(b, 2.0));
    
    for (id<MKAnnotation> annotation in originAnnotations) {
        if ((CLLocationCoordinateDistance(annotation.coordinate, self.centerCoordinate) <= radius)) {
            [annotations addObject:annotation];
        }
    }
    return annotations;
}

- (NSArray *)clusteringWithAnnotations:(NSArray*)annotations clusterRadius:(CLLocationDistance)radius {
    
    NSMutableArray *clusteredAnnotations = @[].mutableCopy;
    
	for (id <MKAnnotation> annotation in annotations) {
		BOOL foundCluster = NO;
        for (RKAnnotation *ann in clusteredAnnotations) {
            if ((CLLocationCoordinateDistance([annotation coordinate], ann.coordinate) <= radius)) {
                foundCluster = YES;
                [ann addAnnotation:annotation];
                break;
            }
        }
        
        if (!foundCluster){
            RKAnnotation *newCluster = [[RKAnnotation alloc] initWithAnnotation:annotation];
            [clusteredAnnotations addObject:newCluster];
        }
	}
    
    NSMutableArray *results = @[].mutableCopy;
    for (RKAnnotation *ann in clusteredAnnotations) {
        if (ann.clusterAnnotations.count == 1) {
            [results addObject:[ann.clusterAnnotations lastObject]];
        } else if (ann.clusterAnnotations.count > 1) {
            [results addObject:ann];
        }
    }
    return results;
}

double CLLocationCoordinateDistance(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2) {
    return sqrt(pow(c1.latitude  - c2.latitude , 2.0) + pow(c1.longitude - c2.longitude, 2.0));
}

@end
