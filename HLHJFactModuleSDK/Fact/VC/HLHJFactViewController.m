//
//  HLHJFactViewController.m
//  HLHJFactModuleSDK
//
//  Created by mac on 2018/5/11.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "HLHJFactViewController.h"

#import "HLHJFactTableViewHeaderView.h"
#import "HLHJFactTableViewCell.h"
#import "HLHJFactCellModel.h"
#import "HLHJFactWantViewController.h"

#import "HLHJFFactInputToolbar.h"
#import "UIView+HLHJExtension.h"
#import "MJRefresh.h"
#import "HLHJMoreViewController.h"
#import "XLVideoPlayer.h"

#import <TMSDK/TMHttpUser.h>
#import <TMSDK/TMHttpUserInstance.h>
#import <TMShare/TMShare.h>
#import <SetI001/SetI001LoginViewController.h>



///视频播放
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "ZFPlayerControlView.h"



#define kTHLHJFactTableViewCellId @"HLHJFactTableViewCell"


@interface HLHJFactViewController ()<HLHJFactTableViewCellDelegate,UITableViewDataSource,UITableViewDelegate,HLHJFFactInputToolbarDelegate>

@property (nonatomic, strong) UITableView  *hlhjTableView;

@property (nonatomic, strong) HLHJFFactInputToolbar *inputToolbar;

@property (nonatomic, strong) HLHJFactTableViewHeaderView *headerView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) NSInteger  page;

@property (nonatomic, strong) NSIndexPath *commentIndexPath;

@property (nonatomic, strong) XLVideoPlayer *videoPlayer;

@property (nonatomic, copy) NSString  *commentId;

@property (nonatomic, strong) ZFPlayerController *player;

@property (nonatomic, strong) ZFPlayerControlView *controlView;

@property (nonatomic, strong) ZFAVPlayerManager *playerManager;
///视频URL
@property (nonatomic, strong) NSMutableArray *urlsArr;


@end
@implementation HLHJFactViewController
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    @weakify(self)
    [self.hlhjTableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        @strongify(self)
        [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];   
    }];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player stop];
    [self.player stopCurrentPlayingCell];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    ///NOTE1.setting UI
    [self initUI];
    ///NOTE5.评论框
    [self setTextViewToolbar];
    
    ///NOTE:视频设置
    [self videoInitUI];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}
#pragma mark 视频播放设置
- (void)videoInitUI{
    /// playerManager
   
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
        @strongify(self) ///此处打开注释可以自动播放下一条
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
#pragma mark UI 设置
- (void)initUI {

    [self.view addSubview:self.hlhjTableView];
    self.hlhjTableView.sd_layout.topSpaceToView(self.view,0).leftEqualToView(self.view).rightEqualToView(self.view). bottomEqualToView(self.view);
     ///NOTE2.设置heaeView(轮播图)
    _headerView = [[HLHJFactTableViewHeaderView alloc]initWithFrame:CGRectMake(0, 0, 0, 220)];
     self.hlhjTableView.tableHeaderView = _headerView;
    ///NOTE2.1 设置footerView
    self.hlhjTableView.tableFooterView = [UIView new];
    ///NOTE3.我要爆料
    __weak typeof(self) weakSelf = self;
    _headerView.WantReportBlock = ^{
    HLHJFactWantViewController *factWant = [HLHJFactWantViewController new];
    factWant.hidesBottomBarWhenPushed  = YES;
    [weakSelf.navigationController pushViewController:factWant animated:YES];
    };
    ///NOTE4.注册cell
    [self.hlhjTableView registerClass:[HLHJFactTableViewCell class] forCellReuseIdentifier:kTHLHJFactTableViewCellId];
    ///NOTE5:下拉刷新加载列表数据
    self.hlhjTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.page = 1;
        [weakSelf getDataSourcePage:weakSelf.page token:[TMHttpUser token].length > 0 ?  [TMHttpUser token]:@""];
    }];
    ///NOTE6:上拉刷新加载列表数据
    self.hlhjTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
         weakSelf.page ++;
         [weakSelf getDataSourcePage:weakSelf.page token:[TMHttpUser token].length > 0 ?  [TMHttpUser token]:@""];
    }];
    ///NOTE2.load dataSource
    [self.hlhjTableView.mj_header beginRefreshing];
    
}
#pragma mark - 加载数据
- (void)getDataSourcePage:(NSInteger)page token:(NSString *)token {
    
    NSDictionary *prama = @{@"page":@(page),
                            @"token":token
                            };
    
    __weak typeof(self) weakSelf = self;
    [HLHJFactNetworkTool hlhjRequestWithType:GET requestUrl:@"/hlhjburst/api/report_list" parameter:prama successComplete:^(id  _Nullable responseObject) {
        NSInteger stateCode = [responseObject[@"code"] integerValue];
        if (stateCode == 500) {
            [weakSelf getDataSourcePage:1 token:@""];
            return ;
        }
 
        [weakSelf tableVieweEndRefreshing];
        if (page == 1) {
            [self.urlsArr removeAllObjects];
        }
        if ([responseObject[@"code"] integerValue] == 1) {
            HLHJFactCellModel *model = [HLHJFactCellModel yy_modelWithJSON:responseObject[@"data"]];
            if (page == 1 && weakSelf.dataArray) {
                [weakSelf.dataArray removeAllObjects];
            }
            if (model.list.count > 0) {
                
                [weakSelf.dataArray addObjectsFromArray:model.list];
                [weakSelf.hlhjTableView.mj_footer resetNoMoreData];
            }else {
                /// 变为没有更多数据的状态
                [weakSelf.hlhjTableView.mj_footer endRefreshingWithNoMoreData];
            }
            /// 轮播图
            NSMutableArray *bannerArr = [NSMutableArray array];
            for (HLHJBannerModel *bannerModel in  model.banner) {
                [bannerArr addObject:[NSString stringWithFormat:@"%@%@",BASE_URL,bannerModel.banner_img]];
            }
            
            ///视频URL
            for (HLHJListModel *model in weakSelf.dataArray) {
                if (model.source_type == 2 && model.source.count > 0) {
                    if (model.source.count > 0) {
                        [weakSelf.urlsArr addObject:[NSURL URLWithString:model.source[0]]];
                    }
                }
            }
            weakSelf.player.assetURLs = weakSelf.urlsArr;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _headerView.sdCycleScrollView.imageURLStringsGroup = bannerArr;
            });
            [weakSelf.hlhjTableView reloadData];
        }else {
            [weakSelf tableVieweEndRefreshing];
        }
    } failureComplete:^(NSError * _Nonnull error) {
        [weakSelf tableVieweEndRefreshing];
    }];
}
- (void)tableVieweEndRefreshing {
    [self.hlhjTableView.mj_header endRefreshing];
    [self.hlhjTableView.mj_footer endRefreshing];
}

#pragma mark - ZInputToolbarDelegate
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

        
         _commentId = @"";
        [model.comment addObject:commentModel];
        [weakSelf.dataArray replaceObjectAtIndex:_commentIndexPath.row withObject:model];
        NSIndexPath *newindexPath=[NSIndexPath indexPathForRow:_commentIndexPath.row inSection:_commentIndexPath.section];
        [weakSelf.hlhjTableView reloadRowsAtIndexPaths:@[newindexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    } failureComplete:^(NSError * _Nonnull error) {
        
    }];
    // 清空输入框文字
    [self.inputToolbar sendSuccessEndEditing];
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
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
            [weakSelf.hlhjTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    cell.model = self.dataArray[indexPath.row];
    // 此步设置用于实现cell的frame缓存，可以让tableview滑动更加流畅 //////
    [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];
    ///////////////////////////////////////////////////////////////////////

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.inputToolbar.textInput resignFirstResponder];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   //  >>>>>>>>>>>>>>>>>>>>> * cell自适应 * >>>>>>>>>>>>>>>>>>>>>>>>
    HLHJListModel *model = self.dataArray[indexPath.row];
    CGFloat height = [self.hlhjTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[HLHJFactTableViewCell class] contentViewWidth:[self cellContentViewWith]];
    return height;  
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
#pragma mark -HLHJFactTableViewCellDelagete
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
    
    if(model.source_type == 1) {
        
         url = [NSString stringWithFormat:@"%@%@",BASE_URL,model.source.count > 0 ? model.source[0] :@"https://www.baidu.com/img/bd_logo1.png"];
    }else {
        
        url = [NSString stringWithFormat:@"%@%@",BASE_URL,model.video_thumb];
    }
    [[TMShareInstance instance]  showShare:[NSString stringWithFormat:@"%@/application/hlhjburst/asset/index.html?id=%@",BASE_URL,model.ID] thumbUrl:url title:model.content descr:model.content currentController:self finish:nil];
}
///查看更多评论
-(void)didClickSeeMoreButtoInCell:(NSIndexPath *)indexPath {
    
    HLHJListModel *model = self.dataArray[indexPath.row];
    HLHJMoreViewController *more = [[HLHJMoreViewController alloc]init];
    more.burst_id = model.ID;
    more.model = model;
    more.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:more animated:YES];    
}


#pragma mark - ZFTableViewCellDelegate
- (void)zf_playTheVideoAtIndexPath:(NSIndexPath *)indexPath {

    [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
}

/// play the video
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    
    HLHJListModel *model = self.dataArray[indexPath.row];
    NSURL *url =  [NSURL URLWithString:model.source[0]];
    [self.player playTheIndexPath:indexPath assetURL:url scrollToTop:scrollToTop];
    [self.controlView showTitle:@""
                 coverURLString:[NSString stringWithFormat:@"%@%@",BASE_URL,model.video_thumb]
                 fullScreenMode:ZFFullScreenModePortrait];
}

#pragma 是否登陆
- (BOOL)responseObject:(NSDictionary *)dict {
    
    [self tableVieweEndRefreshing];
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
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UITableView *)hlhjTableView {
    
    if (!_hlhjTableView) {
        _hlhjTableView =[[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _hlhjTableView.separatorColor = [UIColor groupTableViewBackgroundColor];
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
