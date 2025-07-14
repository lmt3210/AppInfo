//
// AppData.m
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

#import "AppData.h"

@implementation LTAppData

- (id)initWithName:(NSString *)name withPath:(NSString *)path
{
    if ((self = [super init]))
    {
        // Set up logging
        mLog = os_log_create("com.larrymtaylor.AppInfo", "LTAppData");

        self.name = name;
        self.path = path;
        self.info = @"";
        self.version = @"";
        self.minOS = @"";

        NSBundle *bundle = [[NSBundle alloc] initWithPath:path];
        NSArray *archs = [bundle executableArchitectures];
        NSMutableString *arch = [[NSMutableString alloc] init];
    
        for (int j = 0; j < [archs count]; j++)
        {
            switch ([archs[j] integerValue])
            {
                case NSBundleExecutableArchitectureX86_64:
                    [arch appendString:@"I64 "];
                    break;
                case NSBundleExecutableArchitectureARM64:
                    [arch appendString:@"A64 "];
                    break;
                case NSBundleExecutableArchitectureI386:
                    [arch appendString:@"I32 "];
                    break;
                case NSBundleExecutableArchitecturePPC:
                    [arch appendString:@"P32 "];
                    break;
                case NSBundleExecutableArchitecturePPC64:
                    [arch appendString:@"P64 "];
                    break;
                default:
                    [arch appendString:@"??? "];
                    break;
            }
        }
        
        self.arch = [arch copy];
        
        NSDictionary *appInfo = [bundle infoDictionary];
        NSString *shortVersion =
            [appInfo objectForKey:@"CFBundleShortVersionString"];
        NSString *bundleVersion = [appInfo objectForKey:@"CFBundleVersion"];

        if (shortVersion != nil)
        {
             self.version = shortVersion;
        }
        else if (bundleVersion != nil)
        {
             self.version = bundleVersion;
        }
        else
        {
             self.version = @"N/A";
        }

        NSString *minOS = [appInfo objectForKey:@"LSMinimumSystemVersion"];
        (minOS == nil) ? (self.minOS = @"N/A") : (self.minOS = minOS);
        
        NSString *info = [appInfo objectForKey:@"CFBundleGetInfoString"];
        NSString *copyright =
            [appInfo objectForKey:@"NSHumanReadableCopyright"];
        
        if ((info != nil) && ([info isEqualToString:@""] == NO))
        {
            self.info = [info copy];
        }
        else if ((copyright != nil) && ([copyright isEqualToString:@""] == NO))
        {
            self.info = [copyright copy];
        }
        else
        {
            self.info = @"N/A";
        }
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    LTAppData *app = [[[self class] allocWithZone:zone] init];
    
    app.name = [self.name copyWithZone:zone];
    app.info = [self.info copyWithZone:zone];
    app.path = [self.path copyWithZone:zone];
    app.arch = [self.arch copyWithZone:zone];
    app.version = [self.version copyWithZone:zone];
    app.minOS = [self.minOS copyWithZone:zone];

    return app;
}

@end
