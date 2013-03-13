//
//  FilterView.m
//  CoreImageFilter
//
//  Created by Kevin Doughty on 3/13/13.
//  Copyright (c) 2013 Kevin Doughty. All rights reserved.
//

#import "FilterView.h"
#import <QuartzCore/QuartzCore.h>

@interface FilterView ()
@property (assign) NSPoint mouseLoc;

@end
@implementation FilterView

- (void)awakeFromNib {
    self.layer = [CALayer layer];
    self.wantsLayer = YES;
    self.layer.contents = [NSImage imageNamed:@"tokyo subway map kanji.png"];
    
    NSPoint thePoint = NSMakePoint(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    CIFilter *vortexFilter = [self filterWithAmount:0 center:thePoint];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.layer setFilters:@[vortexFilter]];
    [CATransaction commit];
}

-(CABasicAnimation*)additiveAnimationWithKeyPath:(NSString*)theKeyPath {
    CABasicAnimation *theAnimation = [CABasicAnimation animationWithKeyPath:theKeyPath];
    theAnimation.additive = YES;
    theAnimation.fillMode = kCAFillModeBoth;
    theAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :0 :.5 :1];
    theAnimation.duration = ([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSShiftKeyMask) ? 10.0 : 1.0;
    return theAnimation;
}
-(CABasicAnimation*)filterAnimationFrom:(CGFloat)theOld to:(CGFloat)theNew {
    CABasicAnimation *theAnimation = [self additiveAnimationWithKeyPath:@"filters.vortex.inputAngle"];
    theAnimation.fromValue = [NSNumber numberWithFloat:theOld-theNew];
    theAnimation.toValue = [NSNumber numberWithFloat:0];
    return theAnimation;
}
-(CABasicAnimation*)positionAnimationFrom:(NSPoint)fromPoint to:(NSPoint)toPoint {
    CABasicAnimation *theAnimation = [self additiveAnimationWithKeyPath:@"filters.vortex.inputCenter"];
    theAnimation.fromValue = [NSValue valueWithPoint:NSMakePoint(fromPoint.x-toPoint.x,fromPoint.y-toPoint.y)];
    theAnimation.toValue = [NSValue valueWithPoint:NSZeroPoint];
    return theAnimation;
}
-(CIFilter*)filterWithAmount:(CGFloat)theAmount center:(NSPoint)thePoint {
    CIFilter *theFilter = [CIFilter filterWithName:@"CIVortexDistortion"];
    theFilter.name = @"vortex";
    [theFilter setDefaults];
    [theFilter setValue:[NSNumber numberWithFloat:theAmount] forKey:@"inputAngle"];
    [theFilter setValue:[CIVector vectorWithX:thePoint.x Y:thePoint.y] forKey:@"inputCenter"];
    return theFilter;
}

- (void)mouseDown:(NSEvent *)theEvent {
    while (YES) {
        CIFilter *oldFilter = self.layer.filters[0];
        CIVector *fromVector = [oldFilter valueForKey:@"inputCenter"];
        NSPoint fromPoint = NSMakePoint(fromVector.X, fromVector.Y);
        CGFloat fromAmount = [[oldFilter valueForKey:@"inputAngle"] floatValue];
        NSPoint toPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        CGFloat toAmount = ([theEvent type] == NSLeftMouseUp)?0:180;
        
        CIFilter *vortexFilter = [self filterWithAmount:toAmount center:toPoint];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.layer setFilters:@[vortexFilter]];
        [self.layer addAnimation:[self positionAnimationFrom:fromPoint to:toPoint] forKey:nil];
        [self.layer addAnimation:[self filterAnimationFrom:fromAmount to:toAmount] forKey:nil];
        [CATransaction commit];
        
        if ([theEvent type] != NSLeftMouseUp) theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        else break;
    }
}

@end
