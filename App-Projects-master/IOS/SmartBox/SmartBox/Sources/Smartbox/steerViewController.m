//
//  steerViewController.m
//  Smartbox
//
//  Created by Mesada on 14/12/23.
//  Copyright (c) 2014年 mesada. All rights reserved.
//
//主界面
#import "steerViewController.h"
#import "AFAppDotNetAPIClient.h"
#import "AFJsonAPIClient.h"
#import "PublicFunction.h"
//#import "StartEndAnnotation.h"
//#import "MKStartEndAnnotationView.h"
#import "SmartAnnotation.h"
//#import "CommonUtility.h"
#import "abnormalType.h"
#import "LoginManager.h"
#import "TravelViewController.h"
#import "mapLogViewController.h"
#import "CommonUtility.h"

@interface steerViewController ()
{
}
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) NSDictionary *lastDriveRecord;
@property (nonatomic, strong) NSDictionary *lastAbnormal;
@property (nonatomic, strong) NSArray *lasttrackList;
@end

@implementation steerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_mapView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(3, 3)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = _mapView.bounds;
    maskLayer.path = maskPath.CGPath;
    _mapView.layer.mask = maskLayer;
    
    _mapView.delegate = self;
    _mapView.showsCompass = NO;
    _mapView.showsScale = NO;
    _search = [[AMapSearchAPI alloc] initWithSearchKey:(NSString*)APIKey Delegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginSuccessed:)name:LoginSuccessed_Notification object:nil];
    if ([[LoginManager sharedInstance] isLogin]) {
        [self getDateFromWeb];
    }
    
    [_mapView bringSubviewToFront:_zoombt];
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//
//    CGFloat frameHight = screenHeight-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height-20;
//    _backScrollView.contentSize = CGSizeMake(_contentView.frame.size.width, _contentView.frame.size.height);
//        _backScrollView.frame = CGRectMake(_backScrollView.frame.origin.x , _backScrollView.frame.origin.y , _backScrollView.frame.size.width, frameHight);
//
//    NSLog(@" _backScrollView.contentSize=%f",_backScrollView.contentSize.height);
//     NSLog(@"_backScrollView.frame=%f,%d",_backScrollView.frame.size.height,_backScrollView.scrollEnabled);
//}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    NSLog(@" viewDidLayoutSubviews_backScrollView.contentSize=%f",_backScrollView.contentSize.height);
//    NSLog(@"viewDidLayoutSubviews _backScrollView.frame=%f,%d",_backScrollView.frame.size.height,_backScrollView.scrollEnabled);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)LoginSuccessed:(NSNotification*)aNotification
{
    [self getDateFromWeb];
}
-(void)getDateFromWeb
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    //  获取最后一次驾驶记录
    [[AFAppDotNetAPIClient sharedClient] findLastDriveRecord:^(NSDictionary *DriveRecord, NSError *error)
     {
         if(nil == error)
         {
             _lastDriveRecord = DriveRecord;
             NSString* RecordId = [DriveRecord objectForKey:@"id"];
             //获取单次异常
             [[AFAppDotNetAPIClient sharedClient] findDriveRecordAbnormalList:RecordId  complete: ^(NSDictionary *repondDate, NSError *error)
              {
                  if(nil == error)
                  {
                      NSLog(@"findDriveRecordAbnormalList =%@",repondDate);
                      NSArray* arr = [repondDate objectForKey:@"data"];
                      _lastAbnormal = repondDate;
                      [self abnormalPins:arr];
                  }
                  else{//错误
                      
                  }
              }];
             // 获取轨迹
             [[AFAppDotNetAPIClient sharedClient] getCarTrackData:[DriveRecord objectForKey:@"startTimeConvert"] endDate:[DriveRecord objectForKey:@"endTimeConvert"] complete:^(NSDictionary *repondData, NSError *error)
              {
                  NSArray* arr = [repondData objectForKey:@"trackList"];
                  NSLog(@"%@",arr);
                  _lasttrackList = arr;
                  [self addRouteAndPins:arr];
              }];
             
         }
         else{//错误
             
         }
     }];
    //    //获取行驶统计
    
    //上一周
    
//    [self settimeIntervalTip];
    NSInteger  weekday = [PublicFunction weekdayStringFromDate: [NSDate date]];
    if(weekday == 0) weekday = 7;
    
//    NSLog(@"CarLocationDic =%ld",(long)weekday);
    
    NSDateComponents *compt = [[NSDateComponents alloc] init];
    [compt setDay:-(weekday-1)];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *endDate = [calendar dateByAddingComponents:compt toDate:[NSDate date] options:NSCalendarSearchBackwards];
//    NSLog(@"星期天 date =%@",endDate);
    
    [compt setDay:-6];
    NSDate * beginDate = [calendar dateByAddingComponents:compt toDate:endDate options:NSCalendarSearchBackwards];
//    NSLog(@"星期一 date =%@",beginDate);
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M月d日"];
    
    NSString* strbeginDate = [dateFormat stringFromDate:beginDate];
    NSString* strendDate = [dateFormat stringFromDate:endDate];
    NSString* timetip = [NSString stringWithFormat:@"%@-%@",strbeginDate,strendDate];
    _timeIntervalView.text = timetip;
    //
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    strbeginDate = [dateFormat stringFromDate:beginDate];
    strendDate = [dateFormat stringFromDate:endDate];
    [[AFJsonAPIClient sharedClient] getDrivingCount:strbeginDate endTime:strendDate complete:^(NSDictionary *drivingcount, NSError *error)
     {
         if(nil == error)
         {
             NSNumber* mileageNum = [drivingcount objectForKey:@"mile"];
             _mileageLabel.text = [mileageNum stringValue];
             
             NSInteger nmileageNum = [mileageNum integerValue];
             
             if (nmileageNum>=60) {
                 double dmileageNum = nmileageNum/60.0f;
                 _timeLabel.text = [NSString stringWithFormat:@"%.1f",dmileageNum];
                 _timeunitLabel.text = @"h";
             }
             else
             {
                 _timeLabel.text    = [mileageNum stringValue];
                 _timeunitLabel.text = @"min";

             }
            
             float averageSpeed = [[drivingcount objectForKey:@"mile"] integerValue]*60.0/[[drivingcount objectForKey:@"spendTime"]integerValue];
             averageSpeed=(int)(averageSpeed*10+5)/10.0;
             _averageSpeedLabel.text = [NSString stringWithFormat:@"%d",(int)averageSpeed];
             _overspeedCountLabel.text = [[drivingcount objectForKey:@"speedTimes"]stringValue];
             
         }
         else{//错误
             
         }
     }
     ];
    //车辆位置
    [[AFAppDotNetAPIClient sharedClient] getCarLocation:^(NSDictionary *CarLocationDic, NSError *error){
        if(nil == error)
        {
            NSLog(@"CarLocationDic =%@",CarLocationDic);
            double latitude = [[CarLocationDic objectForKey:@"elat"] doubleValue];
            double longitude =[[CarLocationDic objectForKey:@"elng"] doubleValue];
            //bobo delete ,超早android 不显示当前车辆位置在地图上
//            SmartAnnotation *annotation = [[SmartAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude,longitude)];
//            annotation.type = DriveStart_Annotation;
//            [self.mapView addAnnotation:annotation];
            
            //
            //构造AMapReGeocodeSearchRequest对象，location为必选项，radius为可选项
            AMapReGeocodeSearchRequest *regeoRequest = [[AMapReGeocodeSearchRequest alloc] init];
            regeoRequest.searchType = AMapSearchType_ReGeocode;
            regeoRequest.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
            regeoRequest.radius = 10000;
            regeoRequest.requireExtension = YES;
            
            //发起逆地理编码
            [_search AMapReGoecodeSearch: regeoRequest];
            
            
        }
        else{//错误
            
        }
    }];
}

#pragma mark - AMapSearchDelegate

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
//        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
//        ReGeocodeAnnotation *reGeocodeAnnotation = [[ReGeocodeAnnotation alloc] initWithCoordinate:coordinate
//
        AMapAddressComponent *addressComponent = response.regeocode.addressComponent;
        NSLog(@"ismainthread%d", [NSThread isMainThread]);
        NSString* straddress = [NSString stringWithFormat:@"%@%@%@%@",
                                addressComponent.city,
                                addressComponent.district,
                                addressComponent.township,
                                addressComponent.building];
        NSLog(@"ismainthread%d  %@", [NSThread isMainThread] , straddress);

        _carAddress.text = straddress;
        
    }
}
#pragma mark - privatefun
-(void)settimeIntervalTip
{
    NSInteger  weekday = [PublicFunction weekdayStringFromDate: [NSDate date]];
    if(weekday == 0) weekday = 7;
    
    NSLog(@"CarLocationDic =%ld",(long)weekday);
    
    NSDateComponents *compt = [[NSDateComponents alloc] init];
    [compt setDay:-(weekday-1)];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *endDate = [calendar dateByAddingComponents:compt toDate:[NSDate date] options:NSCalendarSearchBackwards];
    NSLog(@"星期天 date =%@",endDate);
    
    [compt setDay:-6];
    NSDate * beginDate = [calendar dateByAddingComponents:compt toDate:endDate options:NSCalendarSearchBackwards];
    NSLog(@"星期一 date =%@",beginDate);
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M月d日"];
    
    NSString* strbeginDate = [dateFormat stringFromDate:beginDate];
    NSString* strendDate = [dateFormat stringFromDate:endDate];
    NSString* timetip = [NSString stringWithFormat:@"%@-%@",strbeginDate,strendDate];
    _timeIntervalView.text = timetip;
}

-(void)abnormalPins:(NSArray*) gpsArr
{
    for(int i=0; i<[gpsArr count]; i++){
        NSDictionary* gpsDic = [gpsArr objectAtIndex:i];
        double latitude = [[gpsDic objectForKey:@"lat"] doubleValue];
        double longitude =[[gpsDic objectForKey:@"lng"] doubleValue];
        
        SmartAnnotation *annotation = [[SmartAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude,longitude)];
        annotation.type = DriveSpecial_Annotation;
        annotation.subtype = [[gpsDic objectForKey:@"type"] integerValue];
        [self.mapView addAnnotation:annotation];

    }
}

- (void)addRouteAndPins:(NSArray*) gpsArr {
    
    if(gpsArr == nil)
    {
        return;
    }
    
    CLLocationCoordinate2D StartAnnotationCoordinate = CLLocationCoordinate2DMake(0.0,0.0);
    CLLocationCoordinate2D EndAnnotationCoordinate = CLLocationCoordinate2DMake(0.0,0.0);
    NSDictionary* gpsDic =  [gpsArr firstObject];
    if (gpsDic) {
        double latitude = [[gpsDic objectForKey:@"lat"] doubleValue];
        double longitude =[[gpsDic objectForKey:@"lng"] doubleValue];
        StartAnnotationCoordinate = CLLocationCoordinate2DMake(latitude,longitude);
        SmartAnnotation *annotation = [[SmartAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude,longitude)];
        annotation.type = DriveStart_Annotation;
        [self.mapView addAnnotation:annotation];
    }
    gpsDic =  [gpsArr lastObject];
    if (gpsDic) {
        double latitude = [[gpsDic objectForKey:@"lat"] doubleValue];
        double longitude =[[gpsDic objectForKey:@"lng"] doubleValue];
        EndAnnotationCoordinate = CLLocationCoordinate2DMake(latitude,longitude);
        SmartAnnotation *endannotation = [[SmartAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude,longitude)];
        endannotation.type = DriveEnd_Annotation;
        [self.mapView addAnnotation:endannotation];
    }
    
    CLLocationCoordinate2D polylineCoords[gpsArr.count];
    
    for(int i=0; i<[gpsArr count]; i++){
        NSDictionary* gpsDic = [gpsArr objectAtIndex:i];
        double latitude = [[gpsDic objectForKey:@"lat"] doubleValue];
        double longitude =[[gpsDic objectForKey:@"lng"] doubleValue];
        
        polylineCoords[i].latitude = latitude;
        polylineCoords[i].longitude = longitude;
    }
    
    MAPolyline *myPolyline = [MAPolyline polylineWithCoordinates:polylineCoords count:gpsArr.count];

    [self.mapView addOverlay:myPolyline];
    [self.mapView setVisibleMapRect:myPolyline.boundingMapRect edgePadding:UIEdgeInsetsMake(20,14,20,14) animated:YES];
//    MACoordinateRegion region = MACoordinateRegionMakeWithDistance(polylineCoords[0], 1000, 1000);
//    MACoordinateRegion adjustedRegion = [_mapView regionThatFits:region];
//    
//    [self.mapView setRegion:adjustedRegion animated:YES];
//     [CommonUtility zoomMapViewToFitAnnotations:self.mapView animated:YES];
//     ///self.mapView.visibleMapRect = myPolyline.boundingMapRect;
   
//     [self.mapView convertCoordinate:StartAnnotationCoordinate toPointToView:self.mapView];
//    - (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(UIView *)view;
//
//     CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[ locationInView:self.view]
//                                              toCoordinateFromView:self.];
}


//- (void)addCharacterLocation:(CLLocationCoordinate2D)coordinate {
//    SmartAnnotation *annotation = [[SmartAnnotation alloc] initWithCoordinate:coordinate];
//    annotation.type = DriveSpecial_Annotation;
//    annotation.color = [UIColor blueColor];
//    [self.mapView addAnnotation:annotation];
//
//}
//


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[SmartAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:reuseIndetifier];
        }
        
        SmartAnnotation* smartannotation = annotation;
        switch (smartannotation.type) {
        case DriveStart_Annotation:
            annotationView.image = [UIImage imageNamed:@"startAnnotation"];
            annotationView.layer.anchorPoint = CGPointMake(0.5, 1);
            break;
        case DriveEnd_Annotation:
            annotationView.image = [UIImage imageNamed:@"endAnnotation"];
            annotationView.layer.anchorPoint = CGPointMake(0.5, 1);
            break;
        case DriveSpecial_Annotation:
            {
//                
//                overspeed_travel =0,//超速
//                ACC_travel,//加速
//                brakes_travel, //急刹车
//                sharpturn_travel, //急转弯
//                idle_travel,//长怠速
//                collision_travel,//碰撞
//                fatigue_travel,//疲劳
                switch (smartannotation.subtype) {
                    case overspeed_travel:
                        annotationView.image = [UIImage imageNamed:@"超速"];
                        break;
                    case ACC_travel:
                        annotationView.image = [UIImage imageNamed:@"急加速"];
                        break;
                    case brakes_travel:
                        annotationView.image = [UIImage imageNamed:@"急刹车"];
                        break;
                    case sharpturn_travel:
                        annotationView.image = [UIImage imageNamed:@"急转弯"];
                    case idle_travel:
                        annotationView.image = [UIImage imageNamed:@"长怠速"];
                        break;
                    case collision_travel:
                        return  nil;
                        break;
                    case fatigue_travel:
                        return  nil;
                        break;
                    default:
                        break;
                }
            }
        break;
                default:
                return  nil;
                break;
        }

        return annotationView;
    }
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineRenderer.lineWidth   = 4.f;
        polylineRenderer.strokeColor = [UIColor magentaColor];
        
        return polylineRenderer;
    }
    
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    NSLog(@" _backScrollView.contentSize=%f",_backScrollView.contentSize.height);
//    NSLog(@"_backScrollView.frame=%f,%d",_backScrollView.frame.size.height,_backScrollView.scrollEnabled);
    
    if([segue.identifier isEqualToString: @"TravelView"])
    {
        TravelViewController* travelViewController = (TravelViewController*)segue.destinationViewController;
        NSString* strStartTime = [_lastDriveRecord objectForKey:@"startTimeConvert"];
        strStartTime = [strStartTime substringToIndex:10];
        travelViewController.startDate = strStartTime;
    }
    else if([segue.identifier isEqualToString: @"main2mapLog"])
    {
        mapLogViewController* destination =(mapLogViewController*)segue.destinationViewController;
        destination.lastDriveRecord = _lastDriveRecord;
        destination.lastAbnormal = _lastAbnormal;
        destination.lasttrackList = _lasttrackList;
    }
}
//- (IBAction)test:(id)sender {
//    NSLog(@" _backScrollView.contentSize=%f",_backScrollView.contentSize.height);
//    NSLog(@"_backScrollView.frame=%f,%d",_backScrollView.frame.size.height,_backScrollView.scrollEnabled);
//}
@end




