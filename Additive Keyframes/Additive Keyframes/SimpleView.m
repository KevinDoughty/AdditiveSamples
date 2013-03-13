//
//  SimpleView.m
//  Additive KeyFrame Animation
//
//  Created by Kevin Doughty on 8/10/12.
//  Copyright (c) 2012 Kevin Doughty. All rights reserved.
//

#import "SimpleView.h"
#import <QuartzCore/QuartzCore.h>
#import "Evaluate.h"

@interface SimpleView ()
@property (retain) CALayer *ball;
@end

@implementation SimpleView
@synthesize ball;

-(void) awakeFromNib {
    
	self.layer = [CALayer layer];
	self.wantsLayer = YES;
	
	CGFloat theDiameter = 30.0;
    ball = [CALayer layer];
	ball.position = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
	ball.bounds = CGRectMake(0, 0, theDiameter, theDiameter);
	ball.cornerRadius = theDiameter / 2.0;
	CGColorRef bgColor = CGColorCreateGenericRGB(0, 0, 0, 1);
    ball.backgroundColor = bgColor;
	CGColorRelease(bgColor);
	
	[self.layer addSublayer:ball];
}
-(BOOL) isFlipped {
    return YES;
}

-(CAKeyframeAnimation*)additiveKeyframeAnimation {
    CAKeyframeAnimation *theAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    theAnimation.additive = YES;
    theAnimation.fillMode = kCAFillModeBoth;
    theAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :0 :.5 :1];
    theAnimation.duration = ([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSShiftKeyMask) ? 10.0 : 1.0;
    return theAnimation;
}

- (void)mouseDown:(NSEvent *)theEvent {
    while (YES) {
        NSPoint toPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        [self animateToPoint:toPoint];
        if ([theEvent type] != NSLeftMouseUp) theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        else break;
    }
}

-(void)animateToPoint:(NSPoint)toPoint {
    CGPoint fromPoint = ball.position;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CAKeyframeAnimation *theAnimation = [self additiveKeyframeAnimation];
    SecondOrderResponseEvaluator *theEvaluator = [[SecondOrderResponseEvaluator alloc] initWithOmega:20.0 zeta:0.5];
    NSUInteger count = 100;
    NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:count];
    double progress = 0.0;
    double increment = 1.0 / (double)(count - 1);
    NSUInteger i;
    for (i = 0; i < count; i++) {
        CGFloat x = ([theEvaluator evaluateAt:progress]-1) * (toPoint.x - fromPoint.x);
        CGFloat y = ([theEvaluator evaluateAt:progress]-1) * (toPoint.y - fromPoint.y);
        [valueArray addObject:[NSValue valueWithPoint:NSMakePoint(x, y)]];
        progress += increment;
    }
    [theAnimation setValues:valueArray];
    [ball addAnimation:theAnimation forKey:nil];
    ball.position = NSPointToCGPoint(toPoint);
    [CATransaction commit];
}




@end
