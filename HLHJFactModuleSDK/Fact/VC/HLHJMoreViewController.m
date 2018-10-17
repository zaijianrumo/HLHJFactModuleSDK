//
//  HLHJMoreViewController.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJMoreViewController.h"
#import "MJRefresh.h"
#import "HLHJCommenModel.h"
#import "HLHJCommenTableViewCell.h"
#import "HLHJFFactInputToolbar.h"
#import "IQKeyboardManager.h"
@interface HLHJMoreViewController ()<UITableViewDataSource,UITableViewDelegate,HLHJFFactInputToolbarDelegate>
@property (nonatomic, strong) UITableView  *hlhjTableView;
@property (nonatomic, assign) NSInteger  page;
@property (nonatomic, strong) NSMutableArray  *dataArray;
@property (nonatomic, strong) HLHJCommenModel  *commenModel;

@property (nonatomic, strong) UITextField  *textFiled;
@property (nonatomic, strong) UIButton  *sendBtn;
@end
#define kTHLHJFactTableViewCellId @"HLHJCommenTableViewCell"
@implementation HLHJMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"评论";
    ///NOTE1.setting UI
    [self initUI];
    ///NOTE2.load dataSource
    [self.hlhjTableView.mj_header beginRefreshing];
    
    ///键盘弹出时，点击背景，键盘收回
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    ///隐藏键盘上面的toolBar,
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;

}
- (void)initUI {
    
    ///NOTE5.评论框
    [self footView];
    
    [self.view addSubview:self.hlhjTableView];
    
    self.hlhjTableView.sd_layout.topSpaceToView(self.view, 0).leftEqualToView(self.view).rightEqualToView(self.view). bottomSpaceToView(self.view, 44);
    ///NOTE2.1 设置footerView
    self.hlhjTableView.tableFooterView = [UIView new];
    ///NOTE4.注册cell
    [self.hlhjTableView registerClass:[HLHJCommenTableViewCell class] forCellReuseIdentifier:kTHLHJFactTableViewCellId];
     __weak typeof(self) weakSelf = self;
    ///NOTE5:下拉刷新加载列表数据
    self.hlhjTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [weakSelf getDataSourcePage:self.page];
    }];
    ///NOTE6:上拉刷新加载列表数据
    self.hlhjTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.page ++;
        [weakSelf getDataSourcePage:self.page];
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLHJCommenTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTHLHJFactTableViewCellId];
    ////// 此步设置用于实现cell的frame缓存，可以让tableview滑动更加流畅 //////
    [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    
    ///////////////////////////////////////////////////////////////////////
   
    if (indexPath.section == 0) {
        cell.commenModel = _model;
    }else {
         cell.model = self.dataArray[indexPath.row];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应 * >>>>>>>>>>>>>>>>>>>>>>>>
    
    if (indexPath.section == 0) {
    
        if (_commenModel) {
                CGFloat height = [self.hlhjTableView cellHeightForIndexPath:indexPath model:_commenModel keyPath:@"model" cellClass:[HLHJCommenTableViewCell class] contentViewWidth:[self cellContentViewWith]];
               return height;
        }
        return 0;
    }
    CommentModel*model = self.dataArray[indexPath.row];
    CGFloat height = [self.hlhjTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[HLHJCommenTableViewCell class] contentViewWidth:[self cellContentViewWith]];
    return height;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return .01f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return .01f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     [self.textFiled resignFirstResponder];
}
- (CGFloat)cellContentViewWith
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    // 适配ios7横屏
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait && [[UIDevice currentDevice].systemVersion floatValue] < 8) {
        width = [UIScreen mainScreen].bounds.size.height;
    }
    return width;
}
///获取数据
- (void)getDataSourcePage:(NSInteger)page {
    
    NSDictionary *prama = @{
                            @"page":@(page),
                            @"burst_id":_burst_id
                            };
    __weak typeof(self) weakSelf = self;
    [HLHJFactNetworkTool hlhjRequestWithType:GET requestUrl:@"/hlhjburst/api/comment_detail" parameter:prama successComplete:^(id  _Nullable responseObject) {

        BOOL success = [weakSelf responseObject:responseObject];
        if (!success) {
            return ;
        }
        
        if ([responseObject[@"code"] integerValue] == 1) {
            _commenModel = [HLHJCommenModel yy_modelWithJSON:responseObject[@"data"]];
            if (page == 1 && self.dataArray) {
                [weakSelf.dataArray removeAllObjects];
            }
            if (_commenModel.comment.count > 0) {
                [weakSelf.dataArray addObjectsFromArray:_commenModel.comment];
                [weakSelf.hlhjTableView.mj_footer resetNoMoreData];
                [weakSelf endRefreshing];
            }else {
                /// 变为没有更多数据的状态
                [weakSelf.hlhjTableView.mj_footer endRefreshingWithNoMoreData];
            }
            [weakSelf.hlhjTableView reloadData];
        }else {
             [weakSelf endRefreshing];
        }
    } failureComplete:^(NSError * _Nonnull error) {
        [weakSelf endRefreshing];
    }];

}

-(void)sendAction:(UIButton *)sender {
    [self.textFiled resignFirstResponder];
    NSDictionary *prama = @{@"token":[TMHttpUser token].length > 0 ? [TMHttpUser token]:@"",
                            @"burst_id":_burst_id,
                            @"content":_textFiled.text,
                            @"comment_id":@"0"
                            };
    __weak typeof(self) weakSelf = self;
    [HLHJFactNetworkTool hlhjRequestWithType:GET requestUrl:@"/hlhjburst/api/public_comment" 
                               parameter:prama successComplete:^(id  _Nullable responseObject) {
                                   BOOL success = [weakSelf responseObject:responseObject];
                                   if (!success) {
                                       return ;
                                   }
        _textFiled.text = @"";
        [weakSelf.hlhjTableView.mj_header beginRefreshing];
    } failureComplete:^(NSError * _Nonnull error) {
        
    }];
}
- (void)endRefreshing {
    if ([self.hlhjTableView.mj_header isRefreshing]) {
        [self.hlhjTableView.mj_header endRefreshing];
    }
    if ([self.hlhjTableView.mj_footer isRefreshing]) {
        [self.hlhjTableView.mj_footer endRefreshing];
    }
}

- (UITableView *)hlhjTableView {
    if (!_hlhjTableView) {
        _hlhjTableView =[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _hlhjTableView.separatorColor = [UIColor whiteColor];
        _hlhjTableView.delegate = self;
        _hlhjTableView.dataSource = self;
        if (@available(ios 11.0,*)) {
            _hlhjTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _hlhjTableView.estimatedRowHeight = 0;
            _hlhjTableView.estimatedSectionHeaderHeight = 0;
            _hlhjTableView.estimatedSectionFooterHeight = 0;
        }else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _hlhjTableView;
}
- (BOOL)responseObject:(NSDictionary *)dict {
    
    [self endRefreshing];
    if ([dict[@"code"] integerValue] == 500 || [dict[@"code"] integerValue] == 100) {
        UIAlertController *alert = [HLHJFactAlertTool createAlertWithTitle:@"提示" message:@"请先登陆" preferred:UIAlertControllerStyleAlert confirmHandler:^(UIAlertAction *confirmAction) {
            SetI001LoginViewController *ctr = [SetI001LoginViewController new];
            ctr.edgesForExtendedLayout = UIRectEdgeNone;
            [self.navigationController pushViewController:ctr animated:YES];
        } cancleHandler:^(UIAlertAction *cancleAction) {
            
        }];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
    
}
#pragma mark -lazy
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (void)footView {
    
    _textFiled = [UITextField new];
    _textFiled.placeholder = @" 请输入";
    _textFiled.backgroundColor = [UIColor whiteColor];
    _textFiled.font = [UIFont systemFontOfSize:14];
    _textFiled.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    _textFiled.layer.borderWidth = 1;
    _textFiled.clipsToBounds = YES;
    _textFiled.layer.cornerRadius = 5;
    [self.view addSubview:_textFiled];
    _textFiled.sd_layout
    .leftSpaceToView(self.view, 5)
    .bottomSpaceToView(self.view, 4)
    .rightSpaceToView(self.view, 60)
    .heightIs(36);
    
    _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    _sendBtn.backgroundColor = [UIColor whiteColor];
    _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _sendBtn.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    [_sendBtn addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    _sendBtn.layer.borderWidth = 1;
    _sendBtn.clipsToBounds = YES;
    _sendBtn.layer.cornerRadius = 5;
    [self.view addSubview:_sendBtn];
    _sendBtn.sd_layout
    .rightSpaceToView(self.view, 5)
    .bottomSpaceToView(self.view, 4)
    .leftSpaceToView(_textFiled, 5)
    .heightIs(36);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
