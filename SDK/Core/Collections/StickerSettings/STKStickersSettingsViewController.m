//
//  STKStickersSettingsViewController.m
//  StickerPipe
//
//  Created by Vadim Degterev on 05.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersSettingsViewController.h"
#import "STKStickersEntityService.h"
#import "STKStickersApiService.h"
#import "STKTableViewDataSource.h"
#import "STKStickerPackObject.h"
#import "STKUtility.h"
#import "STKStickerSettingsCell.h"

#import "STKStickersShopViewController.h"
#import "STKStickersConstants.h"

#import "STKStickerController.h"

@interface STKStickersSettingsViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) STKStickersEntityService *service;
@property (strong, nonatomic) STKStickersApiService *apiService;
@property (strong, nonatomic) STKTableViewDataSource *dataSource;
@property (strong, nonatomic) UIBarButtonItem *editBarButton;

@end

@implementation STKStickersSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STKStickerSettingsCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"STKStickerSettingsCell"];
    
    
    self.dataSource = [[STKTableViewDataSource alloc] initWithItems:nil cellIdentifier:@"STKStickerSettingsCell" configureBlock:^(STKStickerSettingsCell *cell, STKStickerPackObject *item) {
        [cell configureWithStickerPack:item];
    }];
    
    self.service = [STKStickersEntityService new];
    self.apiService = [STKStickersApiService new];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    
    self.navigationItem.title = NSLocalizedString(@"Settings", nil);
    
    [self setUpButtons];
    
    __weak typeof(self) wself = self;
    
    self.dataSource.deleteBlock = ^(NSIndexPath *indexPath,STKStickerPackObject* item) {
        [wself.apiService deleteStickerPackWithName:item.packName success:^(id response) {
           
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.service togglePackDisabling:item];

                [wself.tableView setEditing:NO animated:NO];
                [wself.dataSource.dataSource removeObject:item];
                //      [wself updateStickerPacks];
                
                [wself.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                [wself.tableView setEditing:YES animated:NO];
            });
            
        } failure:^(NSError *error) {
            
        }];
    };
    
    self.dataSource.moveBlock = ^(NSIndexPath *fromIndexPath, NSIndexPath *toIndexPath) {
        
        [wself reorderPacks];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"settings" forKey:@"viewController"];
    [userDefaults synchronize];
    
    [self updateStickerPacks];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"currentVC" forKey:@"viewController"];
    [userDefaults synchronize];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSString *)getImageName:(NSString *)imName {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ResBundle" ofType:@"bundle"];
    NSString *imageName = [[NSBundle bundleWithPath:bundlePath] pathForResource:imName ofType:@"png"];
    
    return imageName;
}

- (void)setUpButtons {
    
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"STKBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(closeAction:)];
    
    self.navigationItem.leftBarButtonItem = closeBarButton;
    
    self.editBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)];
    
    self.navigationItem.rightBarButtonItem = self.editBarButton;
    
}

- (void)reorderPacks {
    NSMutableArray *dataSoruce = [self.dataSource dataSource];
    [dataSoruce enumerateObjectsUsingBlock:^(STKStickerPackObject* obj, NSUInteger idx, BOOL *stop) {
        obj.order = @(idx);
    }];
    NSArray *reorderedPacks = [NSArray arrayWithArray:dataSoruce];
    self.service.stickersArray = reorderedPacks;
    [self.service saveStickerPacks:reorderedPacks];
}

- (void) updateStickerPacks {
    __weak typeof(self) wself = self;
    
    [self.service getStickerPacksIgnoringRecentWithType:nil completion:^(NSArray *stickerPacks) {
        [wself.dataSource setDataSourceArray:stickerPacks];
        [wself.tableView reloadData];
    } failure:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STKStickerPackObject *stickerPack = [self.dataSource itemAtIndexPath:indexPath];
    
    STKStickersShopViewController *shopViewController = [[STKStickersShopViewController alloc] initWithNibName:@"STKStickersShopViewController" bundle:[NSBundle mainBundle]];
    shopViewController.stickerController = self.stickerController;
    shopViewController.packName = stickerPack.packName;
    [self.navigationController pushViewController:shopViewController animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Actions

- (IBAction)editAction:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    self.editBarButton.title = (self.tableView.editing) ? NSLocalizedString(@"Done", nil) : NSLocalizedString(@"Edit", nil);
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter]postNotificationName:STKStickersReorderStickersNotification object:self userInfo:@{@"packs": self.dataSource.dataSource}];
        [[NSNotificationCenter defaultCenter] postNotificationName:STKCloseModalViewNotification object:self];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@"currentVC" forKey:@"viewController"];
        [userDefaults synchronize];
        
        [self.stickerController showStickersView];
    }];
}

@end
