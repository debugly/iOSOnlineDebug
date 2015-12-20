//
//  QLFileManagerTool.m
//  Secret
//
//  Created by qianlongxu on 15/11/27.
//  Copyright © 2015年 Debugly. All rights reserved.
//

#import "QLFileManagerTool.h"
#import "FileItemModel.h"

@implementation QLFileManagerTool

static NSFileManager *fileManager;

+(void)initialize
{
    if (!fileManager) {
        fileManager = [[NSFileManager alloc]init];
    }
}

+ (BOOL)isFolder:(NSString *)path
{
    BOOL isDirectory = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory){
        return YES;
    }
    return NO;
}

NSArray *pathsAppendRootPath(NSArray *paths,NSString *root){
    NSMutableArray *ps = [NSMutableArray array];
    for (NSString *path in paths) {
        [ps addObject:pathAppendRootPath(path, root)];
    }
    return [ps copy];
}

NSString *pathAppendRootPath(NSString *path,NSString *root){
    return [root stringByAppendingPathComponent:path];
}
    
+ (NSArray *)jsonModelsForPath:(NSString *)path
{
    BOOL isDirectory = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (isDirectory) {
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:nil];
            return [FileItemModel jsonFileItemsWithPathArr:pathsAppendRootPath(contents,path)];
        }else{
            NSDictionary *item = [FileItemModel jsonFileItemWithPath:path];
            return @[item];
        }
    }else{
        return nil;
    }
}

+ (NSArray *)modelsForPath:(NSString *)path
{
    BOOL isDirectory = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (isDirectory) {
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:nil];
            return [FileItemModel fileItemsWithPathArr:contents];
        }else{
            FileItemModel *itme = [FileItemModel fileItemWithPath:path];
            return @[itme];
        }
    }else{
        return nil;
    }
}

+ (NSArray *)itemsForPath:(NSString *)path
{
    BOOL isDirectory = NO;
    if ([fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (isDirectory) {
            return [fileManager contentsOfDirectoryAtPath:path error:nil];
        }else{
            return @[path];
        }
    }else{
        return nil;
    }
}

+ (void)itemsForPath:(NSString *)path completion:(void(^)(NSArray *files,NSArray *folders))comp
{
    NSMutableArray *files = [NSMutableArray array];
    NSMutableArray *folders = [NSMutableArray array];
    
    NSArray *items = [self itemsForPath:path];
    
    for (NSString *item in items) {
        BOOL isDirectory = NO;
        NSString *fullPath = [path stringByAppendingPathComponent:item];
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
            if (isDirectory) {
                [folders addObject:fullPath];
            }else{
                [files addObject:fullPath];
            }
        }
    }

    if (comp) {
        comp([files copy],[folders copy]);
    }
}


+ (void)asyncItemsForPath:(NSString *)path completion:(void(^)(NSArray *files,NSArray *folders))comp
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSMutableArray *files = [NSMutableArray array];
        NSMutableArray *folders = [NSMutableArray array];
        
        NSArray *items = [self itemsForPath:path];
        
        for (NSString *item in items) {
            BOOL isDirectory = NO;
            NSString *fullPath = [path stringByAppendingPathComponent:item];
            if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
                if (isDirectory) {
                    [folders addObject:fullPath];
                }else{
                    [files addObject:fullPath];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (comp) {
                comp([files copy],[folders copy]);
            }
        });
    });
}


@end
