//
//  HLHJFactWantViewController.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJFactWantViewController.h"
#import "HLHJFactStartViewController.h"
#import "HLHJMoreViewController.h"

#import "HLHJFactCellModel.h"
#import "HLHJFactTableViewCell.h"

#import "HLHJFFactInputToolbar.h"
#import "UIView+HLHJExtension.h"

#import "MJRefresh.h"
#import "XLVideoPlayer.h"

///视频播放
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "ZFPlayerControlView.h"



@interface HLHJFactWantViewController ()<HLHJFactTableViewCellDelegate,UITableViewDelegate,UITableViewDataSource,HLHJFFactInputToolbarDelegate>

@property (nonatomic, strong) UIView  *topView;

@property (nonatomic, strong) UITableView  *hlhjTableView;

@property (nonatomic, strong) ZFPlayerController *player;

@property (nonatomic, strong) ZFPlayerControlView *controlView;

@property (nonatomic, strong) ZFAVPlayerManager *playerManager;

@property (nonatomic, strong) HLHJFFactInputToolbar *inputToolbar;

@property (nonatomic, strong) NSIndexPath *commentIndexPath;

@property (nonatomic, copy)   NSString  *commentId;

@property (nonatomic, assign) NSInteger  page;

///视频URL
@property (nonatomic, strong) NSMutableArray *urlsArr;

@property (nonatomic, strong) NSMutableArray  *dataArray;

@end

#define kTHLHJFactTableViewCellId @"HLHJFactTableViewCell"
@implementation HLHJFactWantViewController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    @weakify(self)
    [self.hlhjTableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        @strongify(self)
        [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
    }];
    ///NOTE.加载数据
    [self.hlhjTableView.mj_header beginRefreshing];
}
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.player stop];
    [self.player stopCurrentPlayingCell];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"爆料中心";
    ///NOTEUI.加载数据
    [self initUI];
    ///NOTE:视频设置
    [self videoInitUI];
    ///NOTE.评论框
    [self setTextViewToolbar];
  

    
}
-(void)initUI {
    __weak typeof(self) weakSelf = self;
    [self.view addSubview:self.topView];
    ///NOTE1.顶部我要爆料
     self.topView.sd_layout
    .leftEqualToView(self.view)
    .topSpaceToView(self.view, 0)
    .rightEqualToView(self.view)
    .heightIs(44);
     ///NOTE2.tableView
    [self.view addSubview:self.hlhjTableView];
    [self.hlhjTableView registerClass:[HLHJFactTableViewCell class] forCellReuseIdentifier:kTHLHJFactTableViewCellId];
     self.hlhjTableView.sd_layout
    .topSpaceToView(self.topView, 0)
    .leftEqualToView(self.view)
    .rightEqualToView(self.view)
    .bottomEqualToView(self.view);
    self.hlhjTableView.tableFooterView = [UIView new];
    
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
#pragma mark 视频播放设置
- (void)videoInitUI{
    /// playerManager
    self.playerManager = [[ZFAVPlayerManager alloc] init];
    
    /// player,tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithScrollView:self.hlhjTableView playerManager:self.playerManager containerViewTag:100000];
    self.player.controlView = self.controlView;
    self.player.shouldAutoPlay = NO;
    
    @weakify(self)
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        [self setNeedsStatusBarAppearanceUpdate];
        self.hlhjTableView.scrollsToTop = !isFullScreen;
    };
    
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
//        if (self.player.playingIndexPath.row < self.urlsArr.count - 1 && !self.player.isFullScreen) {
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.player.playingIndexPath.row+1 inSection:0];
//            [self playTheVideoAtIndexPath:indexPath scrollToTop:YES];
//        } else
        if (self.player.isFullScreen) {
            [self.player enterFullScreen:NO animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.player.orientationObserver.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.player stopCurrentPlayingCell];
             
            });
        }else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.player.orientationObserver.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.player stopCurrentPlayingCell];
                
            });
        }
    };
    
}

- (void)getDataSourcePage:(NSInteger)page {
    
    NSDictionary *prama = @{@"token":[TMHttpUser token].length > 0 ? [TMHttpUser token]:@"",
                            @"page":@(page)
                            };
    __weak typeof(self) weakSelf = self;
    [HLHJFactNetworkTool hlhjRequestWithType:GET requestUrl:@"/hlhjburst/api/my_report" parameter:prama successComplete:^(id  _Nullable responseObject) {
        BOOL success = [weakSelf responseObject:responseObject];
        if (!success) {
            return ;
        }
        if ([responseObject[@"code"] integerValue] == 1) {
            if (page == 1 && self.dataArray) {
                [weakSelf.dataArray removeAllObjects];
                [self.urlsArr removeAllObjects];
            }
            NSArray *arr = [NSArray yy_modelArrayWithClass:[HLHJListModel class] json:responseObject[@"data"]];
            if (arr.count > 0) {
                [weakSelf.dataArray addObjectsFromArray:arr];
                [weakSelf.hlhjTableView.mj_footer resetNoMoreData];
                [weakSelf endRefreshing];
                ///视频URL
                for (HLHJListModel *model in weakSelf.dataArray) {
                    if (model.source_type == 2) {
                        [weakSelf.urlsArr addObject:[NSURL URLWithString:model.source[0]]];
                    }
                }
                weakSelf.player.assetURLs = weakSelf.urlsArr;
                [weakSelf.hlhjTableView reloadData];
                
            }else {
                if ([weakSelf.hlhjTableView.mj_footer isRefreshing]) {
                    [weakSelf.hlhjTableView.mj_footer endRefreshing];
                }
            /// 变为没有更多数据的状态
                [weakSelf.hlhjTableView.mj_footer endRefreshingWithNoMoreData];
            }
       
        }else {
            [weakSelf endRefreshing];
        }
    } failureComplete:^(NSError * _Nonnull error) {
        [weakSelf endRefreshing];
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
#pragma mark - TextViewToolbar
-(void)setTextViewToolbar {
    
    self.inputToolbar = [[HLHJFFactInputToolbar alloc] initWithFrame:CGRectMake(0,self.view.height, self.view.width, 50)];
    self.inputToolbar.textViewMaxLine = 5;
    self.inputToolbar.delegate = self;
    self.inputToolbar.placeholderLabel.text = @"请输入...";
    [self.view addSubview:self.inputToolbar];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.inputToolbar.textInput resignFirstResponder];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.inputToolbar.textInput resignFirstResponder];
}

#pragma mark  -tableViewDadaSource/UItaleViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HLHJFactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTHLHJFactTableViewCellId];
    cell.indexPath = indexPath;
    [cell setDelegate:self withIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    if (!cell.moreButtonClickedBlock) {
        [cell setMoreButtonClickedBlock:^(NSIndexPath *indexPath) {
            HLHJListModel *model = weakSelf.dataArray[indexPath.row];
            model.isOpening = !model.isOpening;
            [weakSelf.hlhjTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
    [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // >>>>>>>>>>>>>>>>>>>>> * cell自适应 * >>>>>>>>>>>>>>>>>>>>>>>>
    id model = self.dataArray[indexPath.row];
    return [self.hlhjTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[HLHJFactTableViewCell class] contentViewWidth:[self cellContentViewWith]];
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

#pragma mark - hlhjTableViewDelegate
///评论
-(void)inputToolbar:(HLHJFFactInputToolbar *)inputToolbar sendContent:(NSString *)sendContent {
    
    HLHJListModel *model = self.dataArray[_commentIndexPath.row];
    NSDictionary *prama = @{@"token":[TMHttpUser token].length > 0 ? [TMHttpUser token]:@"",
                            @"burst_id":model.ID,
                            @"content":sendContent,
                            @"comment_id":_commentId.length > 0 ? _commentId : @"0"
                            };
    __weak typeof(self) weakSelf = self;
    [HLHJFactNetworkTool hlhjRequestWithType:GET requestUrl:@"/hlhjburst/api/public_comment" parameter:prama successComplete:^(id  _Nullable responseObject) {
        BOOL success = [weakSelf responseObject:responseObject];
        if (!success) {
            return ;
        }
        [self.view makeToast:responseObject[@"msg"]];
        
        HLHJFactCellCommentItemModel *commentModel = [[HLHJFactCellCommentItemModel alloc]init];
        commentModel.ID =  responseObject[@"data"];
        commentModel.create_at = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
//        if (_commentId.length > 0) { //2级
//            commentModel.member_name = [TMHttpUserInstance instance].mobile;
//            commentModel.member_nickname = [TMHttpUserInstance instance].member_name;
//            commentModel.content = sendContent;
//            commentModel.one_member_name =  model.member_name;
//            commentModel.one_member_nickname =  model.member_nickname;
//        }else {
//            commentModel.member_name = @"";
//            commentModel.member_nickname = @"";
//            commentModel.one_content = sendContent;
//            commentModel.one_member_name = [TMHttpUserInstance instance].mobile;
//            commentModel.one_member_nickname = [TMHttpUserInstance instance].member_name;
//        }
        
        if (_commentId.length > 0) { //2级
            commentModel.member_name = [TMHttpUserInstance instance].mobile;
            commentModel.member_nickname = [TMHttpUserInstance instance].member_name;
            commentModel.content = sendContent;
            commentModel.one_member_name =  model.member_name;
            commentModel.one_member_nickname =  model.member_nickname;
        }else {
            commentModel.member_name = @"";
            commentModel.member_nickname = @"";
            commentModel.content = sendContent;
            commentModel.one_member_name = [TMHttpUserInstance instance].mobile;
            commentModel.one_member_nickname = [TMHttpUserInstance instance].member_name;
        }
        
        [model.comment addObject:commentModel];
        [weakSelf.dataArray replaceObjectAtIndex:_commentIndexPath.row withObject:model];
        NSIndexPath *newindexPath=[NSIndexPath indexPathForRow:_commentIndexPath.row inSection:_commentIndexPath.section];
        [weakSelf.hlhjTableView reloadRowsAtIndexPaths:@[newindexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        _commentId = @"";
    } failureComplete:^(NSError * _Nonnull error) {
        
    }];
    // 清空输入框文字
    [self.inputToolbar sendSuccessEndEditing];
}

///点赞
- (void)didClickLikeButtonInCell:(NSIndexPath *)indexPath {
    
    HLHJListModel *model = self.dataArray[indexPath.row];
    NSDictionary *prama = @{@"token":[TMHttpUser token].length > 0 ? [TMHttpUser token]:@"",
                            @"burst_id":model.ID
                            };
    [HLHJFactNetworkTool hlhjRequestWithType:GET requestUrl:@"/hlhjburst/api/laud" parameter:prama successComplete:^(id  _Nullable responseObject) {
        BOOL success = [self responseObject:responseObject];
        if (!success) {
            return ;
        }
        [self.view makeToast:responseObject[@"msg"]];
        
        model.is_laud = !model.is_laud;
        model.laud_num = model.is_laud == YES ? model.laud_num+1 : model.laud_num-1;
        
        [self.dataArray replaceObjectAtIndex:indexPath.row withObject:model];
        NSIndexPath *newindexPath=[NSIndexPath indexPathForRow:indexPath.row inSection:0];
        [self.hlhjTableView reloadRowsAtIndexPaths:@[newindexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    } failureComplete:^(NSError * _Nonnull error) {
        
    }];

}

///评论
- (void)didClickcCommentButtonInCell:(NSIndexPath *)indexPath {
    
    _commentIndexPath = indexPath;
    [self.inputToolbar.textInput becomeFirstResponder];
}
///回复某条评论
-(void)didClickcCommentLabelInCell:(NSIndexPath *)indexPath commentId:(NSString *)commentId {
    
    _commentIndexPath = indexPath;
    _commentId = commentId;
    [self.inputToolbar.textInput becomeFirstResponder];
}
///分享
-(void)didClickShareButtoInCell:(NSIndexPath *)indexPath {
    
    HLHJListModel *model = self.dataArray[indexPath.row];
    TMShareConfig *config = [[TMShareConfig alloc] initWithTMBaseConfig];
    [[TMShareInstance instance] configWith:config];
    NSString *url = @"";
    if(model.source_type == 1){
        url = [NSString stringWithFormat:@"%@%@",BASE_URL,model.source.count > 0 ? model.source[0] :@"https://www.baidu.com/img/bd_logo1.png"];
    }else {
        [NSString stringWithFormat:@"%@%@",BASE_URL,model.video_thumb];
    }
    [[TMShareInstance instance]  showShare:[NSString stringWithFormat:@"%@/application/hlhjburst/asset/index.html?id=%@",BASE_URL,model.ID] thumbUrl:url title:model.content descr:model.content currentController:self finish:nil];
}
///查看更多评论
-(void)didClickSeeMoreButtoInCell:(NSIndexPath *)indexPath {
    HLHJListModel *model = self.dataArray[indexPath.row];
    HLHJMoreViewController *more = [[HLHJMoreViewController alloc]init];
    more.burst_id = model.ID;
    more.model = model;
    [self.navigationController pushViewController:more animated:YES];
}
#pragma mark - VideoTableViewCellDelegate
- (void)zf_playTheVideoAtIndexPath:(NSIndexPath *)indexPath {
    
    [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
    
}

/// play the video
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    
    HLHJListModel *model = self.dataArray[indexPath.row];
    if (model.source.count > 0) {
        
        NSURL *url =  [NSURL URLWithString:model.source[0]];
        
        [self.player playTheIndexPath:indexPath assetURL:url scrollToTop:scrollToTop];
        
        [self.controlView showTitle:@""
                     coverURLString:[NSString stringWithFormat:@"%@%@",BASE_URL,model.video_thumb]
                     fullScreenMode:ZFFullScreenModePortrait];
    }

}
#pragma 是否登陆
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

/**
 @brief 我要爆料

 @param sender <#sender description#>
 */
- (void)addFactAction:(UIButton *)sender {
    
    HLHJFactStartViewController *fact = [[HLHJFactStartViewController alloc]init];
    [self.navigationController pushViewController:fact animated:YES];
}
/**
 @brief tableView

 @return <#return value description#>
 */
- (UITableView *)hlhjTableView {
    if (!_hlhjTableView) {
        _hlhjTableView =[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _hlhjTableView.separatorColor = [UIColor groupTableViewBackgroundColor];
        _hlhjTableView.delegate = self;
        _hlhjTableView.dataSource = self;
        if (@available(ios 11.0,*)) {
            _hlhjTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _hlhjTableView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView  = [UIView new];
        _topView.backgroundColor = [UIColor whiteColor];
        
        UIView * lineView  = [UIView new];
        lineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_topView addSubview:lineView];
        lineView.sd_layout
        .leftEqualToView(_topView)
        .bottomEqualToView(_topView)
        .rightEqualToView(_topView)
        .heightIs(1);
        
       
        UILabel *label = [[UILabel alloc] init];
        label.text = @"    我的爆料";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1];
        [_topView addSubview:label];
        label.sd_layout.centerYEqualToView(_topView).leftSpaceToView(_topView, 0).heightIs(15).widthIs(100);
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"我要爆料" forState:UIControlStateNormal];
        [btn setTitleColor:[TMEngineConfig instance].themeColor forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.layer.cornerRadius = 13;
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor =  [TMEngineConfig instance].themeColor.CGColor;
        btn.layer.borderWidth = 1;
        [btn addTarget:self action:@selector(addFactAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:btn];
        btn.sd_layout.centerYEqualToView(_topView).rightSpaceToView(_topView, 5).heightIs(25).widthIs(80);
        
    }
    return _topView;
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)urlsArr {
    if (!_urlsArr) {
        _urlsArr = [NSMutableArray array];
    }
    return _urlsArr;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
    }
    return _controlView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
@end
