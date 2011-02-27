//
//  GSSmokedInfoViewDemoAppDelegate.h
//  GSSmokedInfoViewDemo
//
//  Created by Simon Whitaker on 27/02/2011.
//

#import <UIKit/UIKit.h>

@class GSSmokedInfoViewDemoViewController;

@interface GSSmokedInfoViewDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GSSmokedInfoViewDemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GSSmokedInfoViewDemoViewController *viewController;

@end

