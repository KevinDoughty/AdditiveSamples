//
//  TestView.h
//  Additive101
//
//  Created by Kevin Doughty on 1/24/13.
//  Copyright (c) 2013 Kevin Doughty. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TestView : NSView {
    CALayer *left;
    CALayer *right;
    IBOutlet NSTextField *durationTextField;
    IBOutlet NSButton *additiveCheckBox;
}
-(IBAction)toggle:(id)sender;
-(IBAction)changeAdditive:(id)sender;

@end
