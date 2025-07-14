//
// MasterViewController.m
// 
// Copyright (c) 2020-2025 Larry M. Taylor
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

#import "MasterViewController.h"
#import "AppData.h"

@implementation MasterViewController

@synthesize mApps;
@synthesize mAppTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    // Set up logging
    mLog = os_log_create("com.larrymtaylor.AppInfo", "MasterView");

    return self;
}

- (NSView *)tableView:(NSTableView *)tableView 
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    // Get a new ViewCell
    NSTableCellView *cellView = 
        [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    LTAppData *appData = [mApps objectAtIndex:row];
    NSString *text = @"";
    
    if ([tableColumn.identifier isEqualToString:@"name"] == YES)
    {
        (appData.name == nil) ? (text = @"N/A") : (text = appData.name);
    }
    else if ([tableColumn.identifier isEqualToString:@"info"] == YES)
    {
        (appData.info == nil) ? (text = @"N/A") : (text = appData.info);
    }
    else if ([tableColumn.identifier isEqualToString:@"arch"] == YES)
    {
        (appData.arch == nil) ? (text = @"N/A") : (text = appData.arch);
    }
    else if ([tableColumn.identifier isEqualToString:@"path"] == YES)
    {
        (appData.path == nil) ? (text = @"N/A") : (text = appData.path);
    }
    else if ([tableColumn.identifier isEqualToString:@"version"] == YES)
    {
        (appData.version == nil) ? (text = @"N/A") : (text = appData.version);
    }
    else if ([tableColumn.identifier isEqualToString:@"minOS"] == YES)
    {
        (appData.minOS == nil) ? (text = @"N/A") : (text = appData.minOS);
    }
    
    cellView.textField.stringValue = text;

    return cellView;
}

- (void)loadView
{
    [super loadView];
    
    // Initialize variables
    mApps = [[NSMutableArray alloc] init];

    // Start timer to wait for app list ready
    mReady = false;
    mReadyTimer = [NSTimer scheduledTimerWithTimeInterval:1
                   target:self selector:@selector(appListReadyTimer:)
                   userInfo:nil repeats:YES];
    
    // Set column sort descriptors
    NSArray<NSTableColumn*> *columns = [mAppTableView tableColumns];
    
    for (int i = 0; i < [columns count]; i++)
    {
        NSTableColumn *column = [columns objectAtIndex:i];
        NSSortDescriptor *sortDescriptor =
            [NSSortDescriptor sortDescriptorWithKey:[column identifier]
             ascending:YES selector:@selector(compare:)];
        [column setSortDescriptorPrototype:sortDescriptor];
    }
    
    // Start task to get app list
    [self getAppList];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
}

- (void)tableView:(NSTableView *)aTableView
        sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    NSArray<NSTableColumn*> *columns = [mAppTableView tableColumns];
    NSTableColumn *column =
        [columns objectAtIndex:[aTableView selectedColumn]];
    NSSortDescriptor *sd = [column sortDescriptorPrototype];
    NSSortDescriptor *sdr = [sd reversedSortDescriptor];
    [column setSortDescriptorPrototype:sdr];
    NSArray *sortedApps = [mApps sortedArrayUsingDescriptors:@[sd]];
    mApps = [sortedApps copy];
    [mAppTableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [mApps count];
}

- (void)appListReadyTimer:(NSTimer *)timer
{
    if (mReady == false)
    {
        return;
    }
    
    [mReadyTimer invalidate];
    mReadyTimer = nil;
    
    [mAppTableView reloadData];
}

- (void)getAppList
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        NSOperatingSystemVersion version =
            [[NSProcessInfo processInfo] operatingSystemVersion];
        NSString *systemVersion = [NSString stringWithFormat:@"%ld.%ld",
                                   version.majorVersion, version.minorVersion];
        
        NSMutableString *dir1 = [[NSMutableString alloc] init];
        NSMutableString *dir2 = [[NSMutableString alloc] init];
        
        if (([systemVersion isEqualToString:@"10.15"]) ||
            (version.majorVersion >= 11))
        {
            [dir1 appendString:@"/System/Applications"];
            [dir2 appendString:@"/System/Volumes/Data/Applications"];
        }
        else
        {
            [dir1 appendString:@"/Applications"];
            [dir2 appendString:NSHomeDirectory()];
            [dir2 appendString:@"/Applications"];
        }
        
        NSMutableArray *installedAppList = [[NSMutableArray alloc] init];
        
        NSURL *dir1Url = [[NSURL alloc] initWithString:dir1];
        NSDirectoryEnumerator *enumerator1 = [[NSFileManager defaultManager]
            enumeratorAtURL:[dir1Url URLByResolvingSymlinksInPath]
            includingPropertiesForKeys:nil
            options:NSDirectoryEnumerationSkipsPackageDescendants
            errorHandler:nil];
        
        for (NSURL *url in enumerator1)
        {
            if ([[[url lastPathComponent] pathExtension] 
                 isEqualToString:@"app"])
            {
                LTAppData *app = [[LTAppData alloc] init];
                app.name = [[url lastPathComponent] substringWithRange:
                    NSMakeRange(0, [url lastPathComponent].length - 4)];
                app.path = [url path];
                [installedAppList addObject:app];
            }
        }
          
        NSURL *dir2Url = [[NSURL alloc] initWithString:dir2];
        NSDirectoryEnumerator *enumerator2 = [[NSFileManager defaultManager]
            enumeratorAtURL:[dir2Url URLByResolvingSymlinksInPath]
            includingPropertiesForKeys:nil
            options:NSDirectoryEnumerationSkipsPackageDescendants
            errorHandler:nil];
        
        for (NSURL *url in enumerator2)
        {
            if ([[[url lastPathComponent] pathExtension]
                 isEqualToString:@"app"])
            {
                LTAppData *app = [[LTAppData alloc] init];
                app.name = [[url lastPathComponent] substringWithRange:
                    NSMakeRange(0, [url lastPathComponent].length - 4)];
                app.path = [url path];
                [installedAppList addObject:app];
            }
        }
          
        NSMutableArray *tmpNameList = [[NSMutableArray alloc] init];
        
        for (LTAppData *tmpAppEntry in installedAppList)
        {
            [tmpNameList addObject:tmpAppEntry.name];
        }
        
        NSArray<NSString *> *sortedNameList =
            [tmpNameList sortedArrayUsingSelector:@selector
             (localizedCaseInsensitiveCompare:)];
     
        NSMutableArray *sortedAppList = [[NSMutableArray alloc] init];
        
        for (NSString *sortedAppName in sortedNameList)
        {
            for (LTAppData *installedAppEntry in installedAppList)
            {
                if ([sortedAppName isEqualToString:installedAppEntry.name])
                {
                    [sortedAppList addObject:installedAppEntry];
                    break;
                }
            }
        }
       
        [self->mApps removeAllObjects];

        for (LTAppData *sortedAppEntry in sortedAppList)
        {
            LTAppData *entry =
                [[LTAppData alloc] initWithName:sortedAppEntry.name
                                   withPath:sortedAppEntry.path];
            [self->mApps addObject:entry];
        }
        
        self->mReady = true;
    }];
}

@end
