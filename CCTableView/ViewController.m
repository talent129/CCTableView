//
//  ViewController.m
//  CCTableView
//
//  Created by luckyCoderCai on 2017/7/26.
//  Copyright © 2017年 luckyCoderCai. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"

typedef NS_ENUM(NSInteger, CCTableViewCellEditingStyle) {
    CCTableViewCellEditingStyleNone,
    CCTableViewCellEditingStyleDelete,
    CCTableViewCellEditingStyleInsert
};

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableDictionary *deleteDic;//记录多选删除数据
@property (nonatomic, strong) UIBarButtonItem *deleteBtn;

@property (nonatomic, assign) CCTableViewCellEditingStyle editingStyle;//编辑模式

@end

@implementation ViewController

#pragma mark -lazy load
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableDictionary *)deleteDic
{
    if (!_deleteDic) {
        _deleteDic = [NSMutableDictionary dictionary];
    }
    return _deleteDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"tableView";
    self.automaticallyAdjustsScrollViewInsets = NO;//取消自动偏移
    
    self.editingStyle = CCTableViewCellEditingStyleInsert | CCTableViewCellEditingStyleDelete;
    
    [self addItems];
    
    [self loadData];
    
    [self createUI];
    
}

#pragma mark -item
- (void)addItems
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItem)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark -load Data
- (void)loadData
{
    for (int i = 0; i < 20; i ++) {
        [self.dataArray addObject:[NSString stringWithFormat:@"%d", i]];
    }
}

- (void)rightBarButtonItem
{
    self.tableView.editing = !self.tableView.editing;
    
    if (self.tableView.editing) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItem)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }else {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItem)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
    
    [self.tableView setEditing:self.tableView.editing animated:YES];
    
    if (self.editingStyle == (CCTableViewCellEditingStyleInsert | CCTableViewCellEditingStyleDelete)) {
        
        [self.deleteDic removeAllObjects];
        
        self.deleteBtn = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(deleteBtnAction)];
        NSMutableArray *Items = [[NSMutableArray alloc]initWithObjects:self.deleteBtn, nil];
        
        if (self.tableView.editing) {
            [self.navigationController setToolbarHidden:NO animated:YES];
        }else {
            [self.navigationController setToolbarHidden:YES animated:YES];
        }
        
        [self setToolbarItems:Items];
        self.deleteBtn.enabled = NO;
    }
}

#pragma mark -createUI
- (void)createUI
{
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.equalTo(@0);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
    }];
}

#pragma mark -UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iden = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iden];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

//是否可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//编辑风格
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.editing) {
        //处于编辑状态 -多选
        if (self.editingStyle == (CCTableViewCellEditingStyleDelete | CCTableViewCellEditingStyleInsert)) {
            return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
        }else if (self.editingStyle == CCTableViewCellEditingStyleInsert) {
            return UITableViewCellEditingStyleInsert;
        }else if (self.editingStyle == CCTableViewCellEditingStyleDelete) {
            return UITableViewCellEditingStyleDelete;
        }
        
        return 0;
    }else {
        //左滑删除
        return UITableViewCellEditingStyleDelete;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.dataArray removeObjectAtIndex:indexPath.row];//删除数据源中相应数据
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self.dataArray insertObject:@"cc" atIndex:indexPath.row];//插入数据
        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if (editingStyle == (UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete)) {
        
    }
}

//可修改左滑删除 title
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"左滑删除";
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.deleteDic removeObjectForKey:indexPath];
    if (self.deleteDic.count == 0) {
        self.deleteBtn.enabled = NO;
    } else {
        self.deleteBtn.enabled = YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //indexPath为key 对应数据为值
    [self.deleteDic setObject:_dataArray[indexPath.row] forKey:indexPath];
    if (self.deleteDic.count == 0) {
        self.deleteBtn.enabled = NO;
    } else {
        self.deleteBtn.enabled = YES;
    }
}

- (void)deleteBtnAction
{
    //多选删除操作
    [_dataArray removeObjectsInArray:[self.deleteDic allValues]];
    [self.tableView deleteRowsAtIndexPaths:[self.deleteDic allKeys] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.deleteDic removeAllObjects];
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItem)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
