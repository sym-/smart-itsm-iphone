//
//  AppDelegate.m
//  SmartITSM
//

#import "AppDelegate.h"
#import "MastPrerequisites.h"
#import "MastEngine.h"
#import "Contacts.h"
#import "Reachability.h"


@interface AppDelegate ()
{
    Reachability *hostReach;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[MastEngine sharedSingleton] start];
    [self configEngine];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[MastEngine sharedSingleton] stop];
}

#pragma mark - Privite

- (void) configEngine
{
    //监测网络
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    hostReach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    [hostReach startNotifier];
    
    Contacts *contacts = [[Contacts alloc]init];
    [contacts addAddress:@"SmartITOM" host:@"192.168.0.109" port:7000];
    
    //启动引擎
    if (![[MastEngine sharedSingleton] start:contacts])
    {
        NSLog(@"Failed start the host");
    }
    

}

#pragma mark - CheckNetWork

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reach = [notification object];
    NSParameterAssert([reach isKindOfClass:[Reachability class]]);
    NetworkStatus status = [reach currentReachabilityStatus];
    
    if (status == NotReachable)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错误" message:@"网络未连接" delegate:nil cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        [alert show];
    }
    else if (status == ReachableViaWiFi)
    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"wifi已连接" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
//        [alert show];
    }
    else if (status == ReachableViaWWAN)
    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"WWAN已连接" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
//        [alert show];
    }
    
}

@end
