# GSSmokedInfoView

A simple "smoked glass" info view, complete with unobtrusive 
fade-in/fade-out animations.

## Pre-requisites

1. Add `QuartzCore framework` to your project
2. Copy `GSSmokedInfoView.h` and `GSSmokedInfoView.m` into your project

## Typical usage

    #import "GSSmokedInfoView.h"

    @implementation MyViewController

    -(IBAction)showSmokedInfoView:(id)sender {
        NSString *message = @"Oh no! The internet is broken!";
    	GSSmokedInfoView *infoView = [[[GSSmokedInfoView alloc] initWithMessage:message andTimeout:2.0] autorelease];
        [infoView show];
    }

    @end

## Screenshot

<img src="http://cl.ly/4t7y/GSSmokedInfoView_demo.png">