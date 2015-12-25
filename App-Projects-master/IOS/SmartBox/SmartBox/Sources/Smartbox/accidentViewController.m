//
//  accidentViewController.m
//  Smartbox
//
//  Created by Mesada on 15/1/30.
//  Copyright (c) 2015年 mesada. All rights reserved.
//

#import "accidentViewController.h"
#import "AFAppDotNetAPIClient.h"
#import "SmartAnnotation.h"

@interface accidentViewController ()
{
    SmartAnnotation *carAnnotation ;
}

@property (nonatomic)  CLLocationCoordinate2D carCoordinate;
@property (nonatomic)  CLLocationCoordinate2D personCoordinate;
@end

@implementation accidentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mapView.delegate = self;
    _mapView.showsCompass = NO;
    _mapView.showsScale = NO;
    _mapView.showsUserLocation = YES;
    [_mapView bringSubviewToFront:_personbt];
    [_mapView bringSubviewToFront:_carbt];
    [self getCarLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getCarLocation
{
    [self showLoadingHUB:@"正在获取车辆位置"];
    [[AFAppDotNetAPIClient sharedClient] getCarLocation:^(NSDictionary *CarLocationDic, NSError *error){
        if(nil == error)
        {
            NSLog(@"CarLocationDic =%@",CarLocationDic);
            double latitude = [[CarLocationDic objectForKey:@"elat"] doubleValue];
            double longitude =[[CarLocationDic objectForKey:@"elng"] doubleValue];
            //
            //            SmartAnnotation *annotation = [[SmartAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude,longitude)];
            //            annotation.type = Car_Annotation;
            //            [self.mapView addAnnotation:annotation];
            _carCoordinate = CLLocationCoordinate2DMake(latitude,longitude);
            if (!carAnnotation) {
                [self addCarPins];
            }
            else
            {
                [carAnnotation setCoordinate:_carCoordinate];
                
            }
            [self SetMapRegion:_carCoordinate ];
            [self hideHUD];
        }
        else{//错误
            [self showHUB:@"获取车辆位置失败"];
        }
    }];
    
}

-(void)SetMapRegion:(CLLocationCoordinate2D)coordinate
{
    MACoordinateRegion region = MACoordinateRegionMakeWithDistance(coordinate, 1000, 1000);
    MACoordinateRegion adjustedRegion = [_mapView regionThatFits:region];
    
    [self.mapView setRegion:adjustedRegion animated:YES];
    [self.mapView setRegion:region animated:YES];
    
}

- (void)addCarPins {
    carAnnotation = [[SmartAnnotation alloc] initWithCoordinate:_carCoordinate];
    carAnnotation.type = Car_Annotation;
    [self.mapView addAnnotation:carAnnotation];
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
{
    _personCoordinate.latitude = userLocation.location.coordinate.latitude;
    _personCoordinate.longitude = userLocation.location.coordinate.longitude;
    
    //    [self SetMapRegion:_personCoordinate];
}


- (IBAction)MoveToCarplace:(id)sender {
    if(_carCoordinate.longitude>0)
    {
        [self SetMapRegion:_carCoordinate];
    }
    
    
}

- (IBAction)MoveToMyPlace:(id)sender {
    
    if(_personCoordinate.longitude>0)
    {
        [self SetMapRegion:_personCoordinate];
    }
    
}

#pragma mark --MKMapViewDelegate
////

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[SmartAnnotation class]] || [annotation isKindOfClass:[MAUserLocation class]])
    {
        static NSString *reuseIndetifier = @"CPReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:reuseIndetifier];
        }
        
        if ([annotation isKindOfClass:[MAUserLocation class]]) {
            annotationView.image = [UIImage imageNamed:@"救援_人位置图标"];
            annotationView.layer.anchorPoint = CGPointMake(0.5, 1);
        }
        else
        {
            SmartAnnotation* smartannotation = annotation;
            switch (smartannotation.type) {
                case Car_Annotation:
                    annotationView.image = [UIImage imageNamed:@"startAnnotation"];
                    annotationView.layer.anchorPoint = CGPointMake(0.5, 1);
                    break;
                default:
                    return  nil;
                    break;
            }
        }
        
        return annotationView;
    }
    
    return nil;
}

@end
