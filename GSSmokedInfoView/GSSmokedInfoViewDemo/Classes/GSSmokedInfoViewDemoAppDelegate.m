//
//  GSSmokedInfoViewDemoAppDelegate.m
//  GSSmokedInfoViewDemo
//
//  Created by Simon Whitaker on 27/02/2011.
//

#import "GSSmokedInfoViewDemoAppDelegate.h"
#import "GSSmokedInfoViewDemoViewController.h"

@implementation GSSmokedInfoViewDemoAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    [self.window addSubview:viewController.view];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
