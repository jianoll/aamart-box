//
//  MyTabBarController.m
//  Smartbox
//
//  Created by Mesada on 14-10-16.
//  Copyright (c) 2014年 mesada. All rights reserved.
//

#import "MyTabBarController.h"
#import "LoginViewController.h"
#import "TheUserManager.h"
#import "TheTCPClient.h"
#import "PublicFunction.h"

#define TABBARITEMSCOUNT 4

@interface MyTabBarController ()

@end

@implementation MyTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
        // Do any additional setup after loading the view.
    
//    
//    NSUInteger count = [self.tabBar.items count];
//    CGSize imageSize = CGSizeMake(self.tabBar.frame.size.width/count, self.tabBar.frame.size.height);
//    UIColor *selectColor = [ UIColor colorWithRed: 0.19
//                                           green: 0.21
//                                            blue: 0.21
//                                           alpha: 1.0  
//                           ];
//    UIImage* selectionimage = [self imageWithColor:selectColor andSize:imageSize];
//
//    [self.tabBar setSelectionIndicatorImage:selectionimage];
//    [self showDiscoverTipIcon];
    
//    self.tabBar.selectedImageTintColor = [UIColor greenColor];
    
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    NSUserDefaults* theUserDefaults = [NSUserDefaults standardUserDefaults];
//    NSInteger lastLoginState = [theUserDefaults integerForKey:LastUserLoginState];
//    BOOL savePwd = [[NSUserDefaults standardUserDefaults] boolForKey:RememberPasswdState];
//    BOOL isLauch = false;
//    if (lastLoginState == 1 && savePwd)
//    {
//        isLauch = FALSE;
//    }
//    else
//    {
//        isLauch = TRUE;
//    }
//    
//    if (isLauch) {
//        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        LoginViewController *loginCtr = [mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
//        
//        [self presentViewController:loginCtr animated:FALSE completion:nil];
//    }
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

//- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
//{
//    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}

-(void)showDiscoverTipIcon
{
    UIColor *selectColor = [ UIColor colorWithRed: 0.41
                                            green: 0.42
                                             blue: 0.92
                                            alpha: 1.0
                            ];
   int x = self.tabBar.frame.size.width/TABBARITEMSCOUNT*3-19;
   int y = self.tabBar.frame.size.height/2-2;
   UIImage* image = [PublicFunction imageWithColor:selectColor andSize:CGSizeMake(8,8)];
   UIImageView* Icon = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 8, 8)];
   Icon.image = image;
    
   Icon.layer.cornerRadius = Icon.layer.frame.size.width/2;
   Icon.tag= 1;
   Icon.clipsToBounds = YES;
   [self.tabBar addSubview:Icon];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)doReLogin
{
    NSUserDefaults* theUserDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger lastLoginState = [theUserDefaults integerForKey:LastUserLoginState];
    [LoginManager sharedInstance].type = 3;//登录模式
//    if (lastLoginState == 1)
//    if ( 1)//无密码登录
    if (lastLoginState == 1)
    {
        NSLog(@"lastLoginState == 1");
        NSDate *nowdate = [NSDate date];
        NSTimeInterval timeInterval = [nowdate timeIntervalSince1970];
        NSString *timeString = [NSString stringWithFormat:@"%f", timeInterval * 1000];
        NSString *deviceToken = [theUserDefaults stringForKey:@"SaveDeviceTokenKey"];
        NSInteger userId = [theUserDefaults integerForKey:LastUserID];
        NSString *password = [theUserDefaults stringForKey:LastUserPassword];
        [[TheUserManager defaultUserManager] doLogin:0
                                           andUserID:userId
                                            andEmail:nil
                                        andMobileNum:nil
                                         andOtherKey:nil
                                       andTimeIntVal:timeString
                                         andPassword:password
                                      andDeviceToken:deviceToken
                                         andDelegate:self];
    } else {
        NSLog(@"lastLoginState != 1");
        //该用户名密码失效 重新进入登录界面 该密码和用户名
    
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginCtr = [mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
        
        [self presentViewController:loginCtr animated:FALSE completion:nil];
       // [loginCtr release];;
        
        //		[[NSNotificationCenter defaultCenter] postNotificationName:@"logoutUserNotify" object:nil];
    }
    
}

- (void)theApplicationWillGotoBackground
{
    NSLog(@"The application will goto backgroud.");
    
}

- (void)theApplicationDidBecomeActiveWithLauch
{
   [self showLoadingMessage:@"正在恢复登录..."];
   [self doReLogin];
}


- (void) theUserDidLogin:(BOOL)success andUserInfo:(UserInfo_assist *)user andErrorString:(NSString*)theError
{
    if (success) {
        NSLog(@"恢复登录成功。");
        [LoginManager sharedInstance].userId = [NSString stringWithFormat:@"%@",user.userId];
        //        [LoginManager sharedInstance].loginDelegate = self;
        //        [[LoginManager sharedInstance] isFinishedUserInfo];
        NSDictionary *loginInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:@"LoginStatus",@"Successed",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:LoginSuccessed_Notification object:nil userInfo:loginInfoDic];
        if (HUD) {
            HUD.hidden = YES;
            HUD = nil;
        }
        [self showMessge:@"恢复登录成功"];
    } else {
        //登录失败，提示用户。
        //        HUD.hidden=YES;
        if (HUD) {
            HUD.hidden = YES;
            HUD = nil;
        }
        NSLog(@"恢复登录失败。");
        UIAlertView* tip = [[UIAlertView alloc] initWithTitle:@"登录失败" message:theError
                                                      delegate:self cancelButtonTitle:@"重试"
                                             otherButtonTitles:@"取消", nil];
        [tip show];
    }
}
#pragma mark-UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//yes
        [self showLoadingMessage:@"正在恢复登录..."];
        [self doReLogin];
    }
    else{//debug bobo 暂时注释
#ifndef debugbobo
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *NavloginCtr = [mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
        [self presentViewController:NavloginCtr animated:YES completion:nil];
#endif
    }
}
#pragma mark--
//tcp 登录返回的基本信息
//检查用户基本资料是否完成时失败。让用户重新登录，重新获取。否则用户登录成功进去应用后资料不完整。
- (void)getUserInfofailed
{
    HUD.hidden = YES;
    UIAlertView* tip = [[UIAlertView alloc] initWithTitle:@"登录失败"
                                                  message:@"获取个人资料失败."
                                                 delegate:self
                                        cancelButtonTitle:@"取消"
                                        otherButtonTitles:@"重试",nil];
    tip.tag = 888;
    [tip show];
}

//tcp 登录放回的基本信息
//检查用户基本资料是否完成代理
//- (void)isFinishedUserInfo:(UserBaseInfo *)userBaseInfo andErrorString:(NSString *)theError
//{
//    NSString *figureurl = userBaseInfo.figureurl;
//    NSInteger sex = [userBaseInfo.sex integerValue];
//    NSString  *nick = userBaseInfo.nickname;
//    NSString  *signName = userBaseInfo.signtext;
//    NSInteger count = 0;
//    if (figureurl.length>0) {
//        count++;
//        if ([figureurl rangeOfString:@"http://"].location == NSNotFound) {
//            [LoginManager sharedInstance].iconUrl = [NSString stringWithFormat:@"%@%@%@",FileServPrefix,FileMiddleUri,figureurl];;
//        } else {
//            NSLog(@"count  == [%d]",[figureurl componentsSeparatedByString:@"http://"].count);
//            NSArray *figureurlArry = [figureurl componentsSeparatedByString:@"http://"];
//            if (figureurlArry.count == 3) {
//                NSLog(@"url = [%@]",[figureurlArry objectAtIndex:2]);
//                [LoginManager sharedInstance].iconUrl = [NSString stringWithFormat:@"http://%@",[figureurlArry objectAtIndex:2]];
//            } else {
//                [LoginManager sharedInstance].iconUrl = figureurl;
//            }
//        }
//        [LoginManager sharedInstance].iconUrl = figureurl;
//    } else {
//        [LoginManager sharedInstance].iconUrl = nil;
//    }
//    if (sex==0||sex==1) {
//        count ++;
//        [LoginManager sharedInstance].sex = sex;
//    } else {
//        [LoginManager sharedInstance].sex = 2;
//    }
//    if (nick.length>0) {
//        count ++;
//        [LoginManager sharedInstance].nick = nick;
//    } else {
//        [LoginManager sharedInstance].nick = nil;
//    }
//    if (signName.length>0) {
//        count ++;
//        [LoginManager sharedInstance].signName = signName;
//    } else {
//        [LoginManager sharedInstance].signName = nil;
//    }
//    // 取消用户资料是否完善登录 2014-03-04 by ly
//    //    if (count == 4) {
//    NSLog(@"登录并资料已经完善");
//
//    [self showMessge:@"恢复登录成功"];
//}


- (void)showMessge:(NSString *)mes
{
    if (HUD) {
        [HUD removeFromSuperViewOnHide];
        HUD.hidden = YES;
        HUD = nil;
    }
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.customView = [[UIImageView alloc] init];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = mes;
    [HUD hide:YES afterDelay:2];
}


-(void)showLoadingMessage:(NSString *)message
{
    if (HUD) {
        [HUD removeFromSuperViewOnHide];
    }
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = message;
}

- (void)hideLoading
{
    if (HUD) {
        HUD.hidden = YES;
        HUD = nil;
    }
}

@end
