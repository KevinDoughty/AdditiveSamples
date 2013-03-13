//
//  DemonstrationView.m
//  AnimationCopying
//
//  Created by Kevin Doughty on 3/10/13.
//  Copyright (c) 2013 Kevin Doughty. All rights reserved.
//

#import "DemonstrationView.h"
#import <QuartzCore/QuartzCore.h>

@interface DemonstrationView ()
@property (assign) BOOL toggled;
@end

@implementation DemonstrationView

-(void)awakeFromNib {
    srandomdev();
    self.layer = [CALayer layer];
    self.wantsLayer = YES;
    self.layer.layoutManager = self;

    CALayer *theLayer = [CALayer layer];
    theLayer.position = CGPointZero;
    theLayer.anchorPoint = CGPointZero;
    theLayer.bounds = CGRectMake(0,0,300,self.bounds.size.height);
    [self debugColorLayer:theLayer];
    [self.layer addSublayer:theLayer];
    
}
-(void) debugColorLayer:(CALayer*)theLayer {
	
	CGFloat red = (random() % 256) / 256.0;
	CGFloat green =  (random() % 256) / 256.0;
	CGFloat blue =  (random() % 256) / 256.0;
	CGColorRef backgroundColorRef = CGColorCreateGenericRGB(red,green,blue,1);
	theLayer.backgroundColor = backgroundColorRef;
	CGColorRelease(backgroundColorRef);
	
	CGColorRef borderColorRef = CGColorCreateGenericRGB(1-red,1-green,1-blue,1);
	theLayer.borderColor = borderColorRef;
	CGColorRelease(borderColorRef);
	
	theLayer.borderWidth = 2.0;
	
}
-(BOOL)wantsUpdateLayer {
    return YES;
}
-(IBAction)veryFast:(id)sender {
    [self toggleWithDuration:1];
}
-(IBAction)fast:(id)sender {
    [self toggleWithDuration:5];
}
-(IBAction)medium:(id)sender {
    [self toggleWithDuration:10];
}
-(IBAction)slow:(id)sender {
    [self toggleWithDuration:15];
}
-(IBAction)verySlow:(id)sender {
    [self toggleWithDuration:25];
}
-(IBAction)merge:(id)sender {
    [CATransaction setDisableActions:YES];
    NSArray *theSublayers = self.layer.sublayers;
    NSUInteger theIndex = theSublayers.count;
    if (theIndex) {
        while (--theIndex) {
            [[theSublayers objectAtIndex:theIndex] removeFromSuperlayer];
        }
        CALayer *theLayer = [theSublayers objectAtIndex:0];
        theLayer.bounds = CGRectMake(0,0,300,self.bounds.size.height);
    }
}
-(void)toggleWithDuration:(CGFloat)theDuration {
    
    NSArray *theLayers = self.layer.sublayers;
    if (theLayers.count) {
        CALayer *theFirstLayer = [theLayers objectAtIndex:0];
        if (theFirstLayer.position.x == 0) self.toggled = YES;
        else self.toggled = NO;
    }
    [self layoutSublayersWithDuration:theDuration];
}

-(void)layoutSublayersOfLayer:(CALayer *)theLayer {
    [self layoutSublayersWithDuration:0];
}
-(void)layoutSublayersWithDuration:(CGFloat)theDuration {
    NSArray *theLayers = self.layer.sublayers;

    if (theLayers.count) {
        if (self.toggled) {
            CGFloat theLoc = self.bounds.size.width;
            NSUInteger theIndex = theLayers.count;
            while (theIndex--) {
                CALayer *theLayer = [theLayers objectAtIndex:theIndex];
                CGFloat theWidth = theLayer.bounds.size.width;
                theLoc -= theWidth;
                CGPoint thePoint = CGPointMake(theLoc, 0);
                [self animateLayer:theLayer to:thePoint duration:theDuration];
            }
        } else {
            CGFloat theLoc = 0;
            for (CALayer *theLayer in theLayers) {
                CGFloat theWidth = theLayer.bounds.size.width;
                CGPoint thePoint = CGPointMake(theLoc, 0);
                [self animateLayer:theLayer to:thePoint duration:theDuration];
                theLoc += theWidth;
            }
        }
    }
}

-(void)animateLayer:(CALayer*)theLayer to:(CGPoint)thePoint duration:(CGFloat)theDuration {
    [CATransaction setDisableActions:YES];
    
    if (theDuration) {
        CABasicAnimation *thePositionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        thePositionAnimation.additive = YES;
        thePositionAnimation.fillMode = kCAFillModeBoth;
        thePositionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :0 :.5 :1];
        thePositionAnimation.fromValue = [NSValue valueWithPoint:NSMakePoint(theLayer.position.x-thePoint.x, theLayer.position.y-thePoint.y)];
        thePositionAnimation.toValue = [NSValue valueWithPoint:NSZeroPoint];
        thePositionAnimation.duration = theDuration;
        static NSUInteger theAnimationIndex = 0;
        NSString *theKey = [NSString stringWithFormat:@"additiveAnimation%lu",theAnimationIndex++];
        [theLayer addAnimation:thePositionAnimation forKey:theKey];
    }
    theLayer.position = thePoint;
    theLayer.bounds = CGRectMake(0,0,theLayer.bounds.size.width,self.bounds.size.height);
}

-(void) mouseDown:(NSEvent*)theEvent {
    CGPoint theViewPoint = NSPointToCGPoint([self convertPoint:theEvent.locationInWindow fromView:nil]);
    CALayer *thePresentationLayer = self.layer.presentationLayer;
    CALayer *theLayer = [thePresentationLayer hitTest:theViewPoint];
    if (theLayer != thePresentationLayer) {
        CGPoint theLayerPoint = [thePresentationLayer convertPoint:theViewPoint toLayer:theLayer];
        [self splitLayer:theLayer.modelLayer atPoint:theLayerPoint];
    }
}

-(void)splitLayer:(CALayer*)theLayer atPoint:(CGPoint)thePoint {
    
    [CATransaction setDisableActions:YES];
    CGFloat theLoc = thePoint.x;
    CGFloat theHeight = self.bounds.size.height;
    
    CALayer *theSplit = [CALayer layer];
    [self debugColorLayer:theSplit];
    theSplit.anchorPoint = CGPointZero;
    theSplit.position = CGPointMake(theLoc,theHeight);
    theSplit.bounds = CGRectMake(0,0,theLayer.bounds.size.width-theLoc,theHeight);
    [self.layer insertSublayer:theSplit atIndex:(unsigned int)[self.layer.sublayers indexOfObject:theLayer]+1];
    theLayer.bounds = CGRectMake(0,0,theLoc,theHeight);
    
    [self copyAnimationsFromLayer:theLayer toLayer:theSplit];
    
}
-(void) copyAnimationsFromLayer:(CALayer*)theOldLayer toLayer:(CALayer*)theNewLayer {
    NSArray *theAnimationKeys = [theOldLayer animationKeys];
    for (NSString *theKey in theAnimationKeys) {
        CAAnimation *theAnimation = [theOldLayer animationForKey:theKey].copy;
        [theNewLayer addAnimation:theAnimation forKey:theKey];
    
    }
}

@end
