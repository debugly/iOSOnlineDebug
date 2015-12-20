
//
//  SandBoxCommHeader.h
//  Secret
//
//  Created by qianlongxu on 15/11/27.
//  Copyright © 2015年 Debugly. All rights reserved.
//

#ifndef SandBoxCommHeader_h
#define SandBoxCommHeader_h

#ifndef  _weakself
#define  _weakself     __weak __typeof(self)weakself = self;
#endif

#ifndef  _strongself
#define  _strongself   __strong __typeof(weakself)self = weakself;
#endif

static inline NSString *ApplicationHomePath()
{
    return NSHomeDirectory();
}

static inline NSString *ApplicationDocumentPath()
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

static inline NSString *ApplicationLibraryPath()
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

static inline NSString *ApplicationCachesPath()
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];

}

#define OnlineDebugBundle_Name  @"OnlineDebug.bundle"

#define OnlineDebugBundle_Path  [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:OnlineDebugBundle_Name]

#define OnlineDebugBundle   [NSBundle bundleWithPath:OnlineDebugBundle_Path]

static inline NSString * OnlineDebugBundleSource_Path (NSString *filename)
{
    NSBundle *libBundle = OnlineDebugBundle;
    if (libBundle && filename) {
        NSString *s = [[libBundle resourcePath]stringByAppendingPathComponent:filename];
        return s;
    }
    return nil;
}

#import "QLFileManagerTool.h"
#import "FileItemModel.h"

#endif /* SanBoxCommHeader_h */
