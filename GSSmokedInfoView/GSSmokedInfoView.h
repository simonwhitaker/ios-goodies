//
//  GSSmokedInfoView.h
//
//  Created by Simon Whitaker, Goo Software Ltd
//

#import <UIKit/UIKit.h>


@interface GSSmokedInfoView : UIView {
	NSTimeInterval _timeout;
}

@property (nonatomic) NSTimeInterval timeout;

-(id)initWithMessage:(NSString*)message andTimeout:(NSTimeInterval)timeout;
-(void)show;

@end
