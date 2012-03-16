//
//  GSSmokedInfoView.h
//
//  Created by Simon Whitaker, Goo Software Ltd
//

#import <UIKit/UIKit.h>

@protocol GSSmokedInfoViewDelegate;

@interface GSSmokedInfoView : UIView 

@property (nonatomic, assign) id<GSSmokedInfoViewDelegate> delegate;
@property (nonatomic) NSTimeInterval timeout;

-(id)initWithMessage:(NSString*)message andTimeout:(NSTimeInterval)timeout;
-(id)initWithMessage:(NSString*)message viewSize:(CGSize)size andTimeout:(NSTimeInterval)timeout;
-(void)show;

@end

@protocol GSSmokedInfoViewDelegate <NSObject>

-(void)smokedInfoViewDidDismiss:(GSSmokedInfoView*)iv;

@end