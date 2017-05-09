//
//  AppDelegate.m
//  PushTest
//
//  Created by WYZ on 2017/5/5.
//  Copyright © 2017年 WYZ. All rights reserved.
//

#import "AppDelegate.h"
#import <Hyphenate/Hyphenate.h>
#import <UserNotifications/UserNotifications.h>


#define APPKEY        @"更换appkey"
#define USERNAME      @"更换测试环信id"
#define PASSWORD      @"登录密码"
#define APNSCERNAME   @"console后台的证书名"

@interface AppDelegate ()<EMChatManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self _registerRemoteNotification];
    
    EMOptions *options = [EMOptions optionsWithAppkey:APPKEY];
    options.apnsCertName = APNSCERNAME;
    options.enableConsoleLog = YES;
    
    EMError *error = [[EMClient sharedClient] initializeSDKWithOptions:options];
    if (!error) {
        
        [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
        
        [[EMClient sharedClient] loginWithUsername:USERNAME password:PASSWORD completion:^(NSString *aUsername, EMError *aError) {
            if (!aError) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"登录成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }
    
    NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo.allKeys.count > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"推送数据" message:[NSString stringWithFormat:@"%@",userInfo] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    
    return YES;
}

- (void)_registerRemoteNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
#if !TARGET_IPHONE_SIMULATOR
                [application registerForRemoteNotifications];
#endif
            }
        }];
        return;
    }
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}

#pragma mark - EMChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"接收消息" message:[NSString stringWithFormat:@"%lu",(unsigned long)aMessages.count] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册远程通知失败" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[EMClient sharedClient].chatManager removeDelegate:self];
}




@end
