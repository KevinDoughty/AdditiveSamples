//
//  MCPSceneView.m
//  SceneKitFun
//
//  Created by Jeff LaMarche on 8/17/12.
//  Copyright (c) 2012 Jeff LaMarche. All rights reserved.
//
//  Modifications by Kevin Doughty, converted to use additive animation.
//  Code from this excellent tutorial was used without permission:
//  http://iphonedevelopment.blogspot.com/2012/08/an-introduction-to-scenekit.html

#define MCP_DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#import "MCPSceneView.h"

@implementation MCPSceneView
-(void)awakeFromNib {
    
    self.backgroundColor = [NSColor grayColor];
    
    self.scene = [SCNScene scene];
    
    // Create an empty scene
    SCNScene *scene = [SCNScene scene];
    self.scene = scene;
    
    // Create a camera
    SCNCamera *camera = [SCNCamera camera];
    camera.xFov = 45;   // Degrees, not radians
    camera.yFov = 45;
	SCNNode *cameraNode = [SCNNode node];
	cameraNode.camera = camera;
	cameraNode.position = SCNVector3Make(0, 0, 30);
    [scene.rootNode addChildNode:cameraNode];
    
    // Create a torus
    SCNTorus *torus = [SCNTorus torusWithRingRadius:8 pipeRadius:3];
    SCNNode *torusNode = [SCNNode nodeWithGeometry:torus];
    CATransform3D rot = CATransform3DIdentity;
    torusNode.transform = rot;
    [scene.rootNode addChildNode:torusNode];
    
    // Create ambient light
    SCNLight *ambientLight = [SCNLight light];
	SCNNode *ambientLightNode = [SCNNode node];
    ambientLight.type = SCNLightTypeAmbient;
	ambientLight.color = [NSColor colorWithDeviceWhite:0.1 alpha:1.0];
	ambientLightNode.light = ambientLight;
    [scene.rootNode addChildNode:ambientLightNode];
    
    // Create a diffuse light
	SCNLight *diffuseLight = [SCNLight light];
    SCNNode *diffuseLightNode = [SCNNode node];
    diffuseLight.type = SCNLightTypeOmni;
    diffuseLightNode.light = diffuseLight;
	diffuseLightNode.position = SCNVector3Make(-30, 30, 50);
	[scene.rootNode addChildNode:diffuseLightNode];
    
    SCNMaterial *material = [SCNMaterial material];
    NSImage *diffuseImage = [NSImage imageNamed:@"tokyo subway map kanji.png"];
    material.diffuse.contents  = diffuseImage;
    material.specular.contents = [NSColor whiteColor];
    material.shininess = 1.0;
    torus.materials = @[material];
}



- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSArray *hits = [self hitTest:mouseLoc options:nil];
    
    if ([hits count] > 0) {
        SCNHitTestResult *hit = hits[0];
        
        CATransform3D theOriginalTransform = hit.node.transform;
        CATransform3D theAlteredTransform = CATransform3DMakeRotation( M_PI_2, .75f, 0.5f, 0.f);
        
        while (YES) {
            mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            CATransform3D theTransform = theOriginalTransform;
            if ([[self hitTest:mouseLoc options:nil] count] && [theEvent type] != NSLeftMouseUp) theTransform = theAlteredTransform;
            
            CABasicAnimation *theTransformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            theTransformAnimation.fillMode = kCAFillModeBoth;
            theTransformAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:.5 :0 :.5 :1];
            theTransformAnimation.additive = YES;
            theTransformAnimation.duration = ([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSShiftKeyMask) ? 10.0 : 1.0;
            theTransformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
            theTransformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DConcat(hit.node.transform, CATransform3DInvert(theTransform))];
            
            [SCNTransaction begin];
            [SCNTransaction setDisableActions:YES];
            [hit.node addAnimation:theTransformAnimation forKey:nil];
            hit.node.transform = theTransform;
            [SCNTransaction commit];
            
            
            if ([theEvent type] == NSLeftMouseUp) break;
            else theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        }
    }
}

@end
