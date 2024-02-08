#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <TikTokOpenSDK/TikTokOpenSDKAuth.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    
    [[TikTokOpenSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
