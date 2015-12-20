//
//  FileItemModel.m
//  Utility
//
//  Created by qianlongxu on 15/11/27.
//
//

#import "FileItemModel.h"
#import "SandBoxCommHeader.h"

@implementation FileItemModel

+ (instancetype)fileItemWithPath:(NSString *)path
{
    FileItemModel *instance = [[self alloc]init];
    instance.title = [path lastPathComponent];
    instance.absPath = path;
    BOOL isDirec;
    [[NSFileManager defaultManager]fileExistsAtPath:path isDirectory:&isDirec];
    instance.isFile = !isDirec;
    return instance;
}

+ (NSDictionary *)jsonFileItemWithPath:(NSString *)path
{
    return [[self fileItemWithPath:path]toJSON];
}
+ (NSArray *)fileItemsWithPathArr:(NSArray *)pathArr
{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *path in pathArr) {
        [arr addObject:[self fileItemWithPath:path]];
    }
    return arr;
}

+ (NSArray *)jsonFileItemsWithPathArr:(NSArray *)pathArr
{
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *path in pathArr) {
        [arr addObject:[[self fileItemWithPath:path]toJSON]];
    }
    return arr;
}

- (NSString *)formatterInfo
{
    if((self.subFiles.count == 0) && (self.subFolder.count ==0)){
        return nil;
    }
    
    NSString *fileInfo = @"";
    NSString *folderInfo = @"";
    
    if(self.subFolder.count > 0){
        folderInfo = [NSString stringWithFormat:@"%ld个文件夹",(unsigned long)self.subFolder.count];
    }
    
    if(self.subFiles.count > 0){
        fileInfo = [NSString stringWithFormat:@"%ld个文件",(unsigned long)self.subFiles.count];
    }
    
    fileInfo = fileInfo.length?[fileInfo stringByAppendingString:@","]:fileInfo;
    return [NSString stringWithFormat:@"(%@%@)",fileInfo,folderInfo];
}

- (NSDictionary *)toJSON
{
    NSString *path = [self.absPath stringByReplacingOccurrencesOfString:ApplicationHomePath() withString:@""];
    
    NSLog(@"-----%d",self.isFile);
    
    if (self.isFile) {
        return @{
                 @"name":self.title,
                 @"path":path,
                 @"isFile":@(self.isFile),
                 @"url":[@"/sandboxResource?path=" stringByAppendingString:path],
                 };
    }else{
        return @{
                 @"name":self.title,
                 @"path":path,
                 @"isFile":@(self.isFile),
                 };
    }
}

@end
