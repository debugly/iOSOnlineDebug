//
//  FileItemModel.h
//  Utility
//
//  Created by qianlongxu on 15/11/27.
//
//

#import <Foundation/Foundation.h>

@interface FileItemModel : NSObject

+ (instancetype)fileItemWithPath:(NSString *)path;
+ (NSDictionary *)jsonFileItemWithPath:(NSString *)path;

+ (NSArray *)fileItemsWithPathArr:(NSArray *)pathArr;
+ (NSArray *)jsonFileItemsWithPathArr:(NSArray *)pathArr;

- (NSString *)formatterInfo;
- (NSDictionary *)toJSON;

@property (nonatomic,copy) NSString *absPath;
@property (nonatomic,copy) NSString *title;

@property (nonatomic,strong) NSArray *subFiles;
@property (nonatomic,strong) NSArray *subFolder;
@property (nonatomic,assign) bool isFile;

@end
