//
//  GSSmokedInfoViewDemoViewController.m
//  GSSmokedInfoViewDemo
//
//  Created by Simon Whitaker on 27/02/2011.
//

#import "GSSmokedInfoViewDemoViewController.h"
#import "GSSmokedInfoView.h"

@implementation GSSmokedInfoViewDemoViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.jpg"]];
    [super viewDidLoad];
}

- (void)dealloc {
    [super dealloc];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return YES;
}

-(IBAction)showSmokedInfoView:(id)sender {
    NSString *message = @"Oh no! The internet is broken!";
	GSSmokedInfoView *infoView = [[[GSSmokedInfoView alloc] initWithMessage:message andTimeout:2.0] autorelease];
    [infoView show];
}

@end
