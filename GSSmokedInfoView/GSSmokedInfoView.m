//
//  GSSmokedInfoView.m
//
//  Created by Simon Whitaker, Goo Software Ltd
//

#import "GSSmokedInfoView.h"
#import <QuartzCore/QuartzCore.h>

#define VIEW_WIDTH 180.0
#define VIEW_HEIGHT 180.0
#define CORNER_RADIUS 20.0
#define BACKGROUND_OPACITY 0.7
#define TEXT_PADDING 15.0
#define FONT_SIZE 16.0
#define FADE_IN_DURATION 0.1
#define FADE_OUT_DURATION 0.25

@implementation GSSmokedInfoView
@synthesize timeout = _timeout;

-(id)initWithMessage:(NSString*)message andTimeout:(NSTimeInterval)timeout {
    CGRect frame = CGRectMake(0, 0, VIEW_WIDTH, VIEW_HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        // Give the view a transparent background
        self.backgroundColor = [UIColor clearColor];

        // Add a label for the message
        frame = CGRectMake(
                           TEXT_PADDING, 
                           TEXT_PADDING, 
                           VIEW_WIDTH - TEXT_PADDING * 2, 
                           VIEW_HEIGHT - TEXT_PADDING * 2);
        UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
        
        // Configure the label
        label.numberOfLines = 5;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:FONT_SIZE];
        label.text = message;
        
        // Add label to the view
        [self addSubview:label];
        
        self.timeout = timeout;
    }
    return self;
}

-(void)show {
    // Get the key window and add this view as a centered subview
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    self.center = keyWindow.center;
    self.layer.opacity = 0.0;
    [keyWindow addSubview:self];
    
    // Add a fade-in animation
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:self.layer.opacity];
    opacityAnim.toValue = [NSNumber numberWithFloat:0.1];
    opacityAnim.duration = FADE_IN_DURATION;
    [self.layer addAnimation:opacityAnim forKey:@"fadeIn"];
    self.layer.opacity = 1.0;
    
    // Add a little "bulge" animation
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:0.8],
                             [NSNumber numberWithFloat:1.05],
                             [NSNumber numberWithFloat:1.0],
                             nil];
    
    // I find having the "bulge" duration longer than the fade-in duration works well 
    scaleAnimation.duration = FADE_IN_DURATION * 2;
    [self.layer addAnimation:scaleAnimation forKey:@"bulge"];
    
    // Set the view to dismiss itself after specified timeout
    [NSTimer scheduledTimerWithTimeInterval:self.timeout
                                     target:self
                                   selector:@selector(fadeOut)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)fadeOut {
    // Fade out the view's opacity
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:self.layer.opacity];
    opacityAnim.toValue = [NSNumber numberWithFloat:0.0];
    opacityAnim.duration = FADE_OUT_DURATION;
    
	// Add self as the delegate for the fadeout - the delegate method will 
    // remove this view from its superview once it's completely transparent
    opacityAnim.delegate = self;
    [self.layer addAnimation:opacityAnim forKey:@"fadeOut"];
    self.layer.opacity = 0.0;

    // "Zoom" the view out a little as it fades out
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.2];
    scaleAnimation.duration = FADE_OUT_DURATION;
    [self.layer addAnimation:scaleAnimation forKey:@"grow"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    // Only called after fading the view out when it's dismissed - once the
    // fadeout is complete, remove me from my superview. (View will dealloc
    // once it's removed from its superview provided nothing else retains it.)
    [self removeFromSuperview];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    
    /*
     * To draw a rectangle with rounded corners, I'll use 
     * CGContextAddArcToPoint() to draw from one side's
     * midpoint to the next, specifying a radius each 
     * time
     *
     *    (NW)---(N)----(NE)
     *     |             |
     *     |             |
     *     |             |
     *    (W)           (E)
     *     |             |
     *     |             |
     *     |             |
     *    (SW)---(S)----(SE)
     */

    // Draw north-east corner: N to E via NE
    CGContextMoveToPoint(c, VIEW_WIDTH/2, 0);
    CGContextAddArcToPoint(c, 
                           VIEW_WIDTH, 0, 			  	// NE
                           VIEW_WIDTH, VIEW_HEIGHT/2, 	// E
                           CORNER_RADIUS);

    // Draw south-east corner: E to S via SE
    CGContextAddArcToPoint(c, 
                           VIEW_WIDTH, VIEW_HEIGHT, 	// SE
                           VIEW_WIDTH/2, VIEW_HEIGHT, 	// S
                           CORNER_RADIUS);
    
    // Draw south-west corner: S to W via SW
    CGContextAddArcToPoint(c, 
                           0, VIEW_HEIGHT, 				// SW
                           0, VIEW_HEIGHT/2, 			// W
                           CORNER_RADIUS);
    
    // Finish with the "Hitchcock manoeuvre": North by Northwest
    // Bboom, tish. I am available for weddings.
    CGContextAddArcToPoint(c, 
                           0, 0, 						// NW
                           VIEW_WIDTH/2, 0, 			// N
                           CORNER_RADIUS);

    CGContextClosePath(c);

    // Fill the path with glorious, wonderful black
    CGContextSetRGBFillColor (c, 0, 0, 0, BACKGROUND_OPACITY);
    CGContextFillPath(c);
}

- (void)dealloc {
    [super dealloc];
}


@end
