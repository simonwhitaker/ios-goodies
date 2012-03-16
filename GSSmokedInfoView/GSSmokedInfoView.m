//
//  GSSmokedInfoView.m
//
//  Created by Simon Whitaker, Goo Software Ltd
//

#import "GSSmokedInfoView.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>

#define DEFAULT_VIEW_WIDTH 180.0
#define DEFAULT_VIEW_HEIGHT 180.0
#define CORNER_RADIUS 20.0
#define BACKGROUND_OPACITY 0.7
#define TEXT_PADDING 15.0
#define FONT_SIZE 17.0
#define FADE_IN_DURATION 0.1
#define FADE_OUT_DURATION 0.25

@implementation GSSmokedInfoView
@synthesize timeout = _timeout;
@synthesize delegate = _delegate;


-(id)initWithMessage:(NSString *)message viewSize:(CGSize)size andTimeout:(NSTimeInterval)timeout {
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    self = [super initWithFrame:frame];
    if (self) {
        // Give the view a transparent background
        self.backgroundColor = [UIColor clearColor];

        // Add a label for the message
        frame = CGRectMake(
                           TEXT_PADDING, 
                           TEXT_PADDING, 
                           self.frame.size.width - TEXT_PADDING * 2, 
                           self.frame.size.height - TEXT_PADDING * 2);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        
        // Configure the label
        label.numberOfLines = 5;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
        label.shadowColor = [UIColor blackColor];
        label.shadowOffset = CGSizeMake(0, 2);
        label.text = message;
        
        // Add label to the view
        [self addSubview:label];
        
        self.timeout = timeout;
    }
    return self;
}

-(id)initWithMessage:(NSString*)message andTimeout:(NSTimeInterval)timeout {
    return [self initWithMessage:message 
                        viewSize:CGSizeMake(DEFAULT_VIEW_WIDTH, DEFAULT_VIEW_HEIGHT) 
                      andTimeout:timeout];
}

-(void)show {
    // Get the key window and add this view as a centered subview
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    self.center = keyWindow.center;
    self.layer.opacity = 0.0;
    [keyWindow addSubview:self];

    // Adjust the view's orientation
    switch ([UIApplication sharedApplication].statusBarOrientation) {
		case UIInterfaceOrientationLandscapeRight:
            [self.layer setValue:[NSNumber numberWithFloat:M_PI_2 * 1] forKeyPath:@"transform.rotation"];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [self.layer setValue:[NSNumber numberWithFloat:M_PI_2 * 2] forKeyPath:@"transform.rotation"];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [self.layer setValue:[NSNumber numberWithFloat:M_PI_2 * 3] forKeyPath:@"transform.rotation"];
            break;
        default:
            break;
	}

    
    // Add a fade-in animation
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.fromValue = [NSNumber numberWithFloat:self.layer.opacity];
    opacityAnim.toValue = [NSNumber numberWithFloat:0.1];
    opacityAnim.duration = FADE_IN_DURATION;
    [self.layer addAnimation:opacityAnim forKey:@"fadeIn"];
    self.layer.opacity = 1.0;
    
    // Add a scale animation to grow the view as it appears
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:0.8];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
    
    // I find having the "grow" duration longer than the opacity fade-in duration works well 
    scaleAnimation.duration = FADE_IN_DURATION * 2;
    [self.layer addAnimation:scaleAnimation forKey:@"grow"];
    
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(smokedInfoViewDidDismiss:)]) {
        [self.delegate smokedInfoViewDidDismiss:self];
    }
    [self removeFromSuperview];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGFloat view_width = self.frame.size.width;
    CGFloat view_height = self.frame.size.height;

    // Handle rotated views correctly
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = view_width;
        view_width = view_height;
        view_height = temp;
    }

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
    CGContextMoveToPoint(c, view_width/2, 0);
    CGContextAddArcToPoint(c, 
                           view_width, 0, 			  	// NE
                           view_width, view_height/2, 	// E
                           CORNER_RADIUS);

    // Draw south-east corner: E to S via SE
    CGContextAddArcToPoint(c, 
                           view_width, view_height, 	// SE
                           view_width/2, view_height, 	// S
                           CORNER_RADIUS);
    
    // Draw south-west corner: S to W via SW
    CGContextAddArcToPoint(c, 
                           0, view_height, 				// SW
                           0, view_height/2, 			// W
                           CORNER_RADIUS);
    
    // Finish with the "Hitchcock manoeuvre": North by Northwest
    // Bboom, tish. I am available for weddings.
    CGContextAddArcToPoint(c, 
                           0, 0, 						// NW
                           view_width/2, 0, 			// N
                           CORNER_RADIUS);

    CGContextClosePath(c);

    // Fill the path with glorious, wonderful black
    CGContextSetRGBFillColor (c, 0, 0, 0, BACKGROUND_OPACITY);
    CGContextFillPath(c);
}

@end
