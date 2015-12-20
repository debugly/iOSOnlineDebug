//
//  SandBoxRootFolderTableViewController.m
//  Secret
//
//  Created by qianlongxu on 15/11/27.
//  Copyright © 2015年 Debugly. All rights reserved.
//

#import "SandBoxRootFolderTableViewController.h"
#import "SandBoxCommHeader.h"
#import "SandBoxFolderDetailTableViewController.h"

typedef NS_ENUM(NSUInteger, RootSections) {
    ///常用的；
    RootSection_Common,
    RootSection_Other,
    RootSection_Count
};

@interface SandBoxRootFolderTableViewController ()

@property (nonatomic, strong) NSArray *commonItems;
@property (nonatomic, strong) NSArray *otherItems;

@end

@implementation SandBoxRootFolderTableViewController

- (NSArray *)commonItems
{
    if (!_commonItems) {
        NSMutableArray *pathArr = [NSMutableArray array];
        NSString *path = [ApplicationLibraryPath() stringByAppendingPathComponent:@"PrivateDocuments"];
        [pathArr addObject:path];
        
        path = [path stringByAppendingPathComponent:@"download"];
        [pathArr addObject:path];
        
        path = ApplicationDocumentPath();
        [pathArr addObject:path];

        
        NSMutableArray *items = [NSMutableArray array];
        
        NSArray *commonTitles = @[@"SOHU_Datas",@"Download",@"Documents"];
        for (int i = 0; i < commonTitles.count; i ++) {
            FileItemModel *model = [FileItemModel new];
            model.title = commonTitles[i];
            model.absPath = pathArr[i];
            [items addObject:model];
        }
        _commonItems = [items copy];
    }
    return _commonItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"沙盒路径下的文件";
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:RootSection_Other] withRowAnimation:UITableViewRowAnimationAutomatic];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
//        计算子文件；
        for (FileItemModel *model in self.commonItems) {
            [QLFileManagerTool itemsForPath:model.absPath completion:^(NSArray *files, NSArray *folders) {
                model.subFiles = [FileItemModel fileItemsWithPathArr:files];
                model.subFolder = [FileItemModel fileItemsWithPathArr:folders];
            }];
        }
        
        NSMutableArray *otherItems = [NSMutableArray array];
//        home下的字文件；
        NSArray *items = [QLFileManagerTool itemsForPath:NSHomeDirectory()];
        for (NSString *item in items) {
            FileItemModel *model = [FileItemModel new];
            model.title = [item lastPathComponent];
            model.absPath = [NSHomeDirectory() stringByAppendingPathComponent:item];
            
//            当前这个子文件（夹）有多少个子文件（夹）
            [QLFileManagerTool itemsForPath:model.absPath completion:^(NSArray *files, NSArray *folders) {
                model.subFiles = [FileItemModel fileItemsWithPathArr:files];
                model.subFolder = [FileItemModel fileItemsWithPathArr:folders];
            }];
            
            [otherItems addObject:model];
        }
        self.otherItems = [otherItems copy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:RootSection_Other] withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    });
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return RootSection_Count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case RootSection_Common:
            return self.commonItems.count;
        case RootSection_Other:
            return self.otherItems.count;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case RootSection_Common:
            return @"常用的";
        case RootSection_Other:
            return @"沙盒根目录";
        default:
            return nil;
    }
}

- (FileItemModel *)modelForIndexPath:(NSIndexPath *)idx
{
    if (RootSection_Common == idx.section) {
        return self.commonItems[idx.row];
    }else if (RootSection_Other == idx.section){
        return [self.otherItems objectAtIndex:idx.row];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuseIdentifier"];
    }
    
    FileItemModel *model = [self modelForIndexPath:indexPath];
    cell.textLabel.text = model.title;
    
    cell.detailTextLabel.text = [model formatterInfo];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FileItemModel *model = [self modelForIndexPath:indexPath];
    
    if ([QLFileManagerTool isFolder:model.absPath]) {
        SandBoxFolderDetailTableViewController *vc = [SandBoxFolderDetailTableViewController new];
        vc.contentModel = model;
        [self.navigationController pushViewController:vc
                                             animated:YES];
    }
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
