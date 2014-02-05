//
//  AppDelegate.h
//  ContactsManager
//
//  Created by Zeyue Chen on 2/6/14.
//  Copyright (c) 2014 Zeyue Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
- (IBAction)clickStart:(id)sender;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;


@end
