//
//  TestView.m
//  Additive101
//
//  Created by Kevin Doughty on 1/24/13.
//  Copyright (c) 2013 Kevin Doughty. All rights reserved.
//

#import "TestView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TestView

-(BOOL) isFlipped {
    return YES;
}

-(void) awakeFromNib {
	self.layer = [CALayer layer];
	self.wantsLayer = YES;
	[durationTextField setFloatValue:1.0];
    NSSize theSize = self.bounds.size;
    
	left = [CALayer layer];
    left.anchorPoint = CGPointMake(0,0);
    left.position = CGPointMake(0,0);
	left.bounds = CGRectMake(0,0,theSize.width,theSize.height);
	left.borderWidth = 4.0;
    
    right = [CALayer layer];
    right.anchorPoint = CGPointMake(0,0);
    right.position = CGPointMake(theSize.width,0);
	right.bounds = CGRectMake(0,0,theSize.width,theSize.height);
    right.borderWidth = 4.0;
    
	//srandomdev();
    CGFloat red = 1;//(random() % 256) / 256.0;
    CGFloat green = 1;//(random() % 256) / 256.0;
    CGFloat blue = 1;//(random() % 256) / 256.0;
    CGColorRef leftColorRef = CGColorCreateGenericRGB(red,green,blue,1);
    CGColorRef rightColorRef = CGColorCreateGenericRGB(1-red,1-green,1-blue,1);
    
    left.backgroundColor = leftColorRef;
    left.borderColor = rightColorRef;
    
    right.backgroundColor = rightColorRef;
    right.borderColor = leftColorRef;
    
    CGColorRelease(leftColorRef);
    CGColorRelease(rightColorRef);
    
	[self.layer addSublayer:left];
    [self.layer addSublayer:right];
    
}
-(IBAction)changeAdditive:(id)sender {
    [left removeAllAnimations];
    [right removeAllAnimations];
}


-(void)animateLayer:(CALayer*)theLayer toPoint:(CGPoint)new {
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
	theAnimation.duration = [durationTextField floatValue] * ([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSShiftKeyMask ? 5.0 : 1.0);
	if ([additiveCheckBox intValue]) {
        theAnimation.additive = YES;
        theAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :0 :.5 :1];
        CGPoint old = theLayer.position;
        theAnimation.fromValue = [NSValue valueWithPoint:NSMakePoint(old.x-new.x,old.y-new.y)];
        theAnimation.toValue  = [NSValue valueWithPoint:NSZeroPoint];
        [theLayer addAnimation:theAnimation forKey:nil];
    } else {
        CGPoint old = [(CALayer*)theLayer.presentationLayer position];
        theAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :0 :.5 :1]; // Use same timing function for comparison
        theAnimation.fromValue = [NSValue valueWithPoint:NSMakePoint(old.x,old.y)];
        theAnimation.toValue  = [NSValue valueWithPoint:NSMakePoint(new.x,new.y)];
        [theLayer addAnimation:theAnimation forKey:@"position"];
    }
    theLayer.position = new;
    
}
-(IBAction)toggle:(id)sender {
    NSSize theSize = self.bounds.size;
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    if (left.position.x < 0) {
        [self animateLayer:left toPoint:CGPointMake(0,0)];
        [self animateLayer:right toPoint:CGPointMake(theSize.width,0)];
    } else {
        [self animateLayer:left toPoint:CGPointMake(-theSize.width,0)];
        [self animateLayer:right toPoint:CGPointMake(0,0)];
    }
    [CATransaction commit];
}
-(void)setFrameSize:(NSSize)theSize {
    [super setFrameSize:theSize];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    if (left.position.x < 0) {
        left.position = CGPointMake(-theSize.width,0);
        right.position = CGPointMake(0,0);
    } else {
        left.position = CGPointMake(0,0);
        right.position = CGPointMake(theSize.width,0);
    }
    left.bounds = CGRectMake(0,0,theSize.width,theSize.height);
    right.bounds = CGRectMake(0,0,theSize.width,theSize.height);
    [CATransaction commit];
}
@end
