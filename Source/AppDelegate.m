//
// AppDelegate.m
// 
// Copyright (c) 2020-2026 Larry M. Taylor
//
// This software is provided 'as-is', without any express or implied
// warranty. In no event will the authors be held liable for any damages
// arising from the use of this software. Permission is granted to anyone to
// use this software for any purpose, including commercial applications, and to
// to alter it and redistribute it freely, subject to 
// the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Create the master View Controller
    self.masterViewController = [[MasterViewController alloc] 
        initWithNibName:@"MasterViewController" bundle:nil];
    
    // Update color
    NSColor * const kLTPurple = [NSColor colorWithSRGBRed:(61.0 / 255.0)
                                 green:(39.0 / 255.0) blue:(93.0 / 255.0)
                                 alpha:1.0];
    [self.window setBackgroundColor:kLTPurple];

    // Add the view controller to the window's content view
    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame =
        ((NSView*)self.window.contentView).bounds;

    // Set up logging
    mLog = os_log_create("com.larrymtaylor.AppInfo", "AppDelegate");
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)cleanup
{
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self cleanup];
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app
{
    return TRUE;
}

- (IBAction)checkForUpdates:(id)sender
{
    if (mVersionCheck == nil)
    {
        mVersionCheck = [[LTVersionCheck alloc] init];
        NSBundle *appBundle = [NSBundle mainBundle];
        NSDictionary *appInfo = [appBundle infoDictionary];
        mAppVersion = [appInfo objectForKey:@"CFBundleShortVersionString"];
    }

    [mVersionCheck checkVersionForAppName:@"AppInfo"
     withAppVersion:mAppVersion withLogHandle:mLog withLogFile:LTLOG_NO_FILE];
}

- (IBAction)showAboutBox:(id)sender
{
    [[AboutWindowController defaultController].window orderFront:self];
}

@end
