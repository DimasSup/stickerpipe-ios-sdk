//
//  STKStickersSettingsViewController.m
//  StickerPipe
//
//  Created by Vadim Degterev on 05.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "STKStickersSettingsViewController.h"
#import "STKStickersEntityService.h"
#import "STKTableViewDataSource.h"
#import "STKStickerPackObject.h"
#import "STKStickerSettingsCell.h"
#import "STKStickersShopViewController.h"
#import "STKStickerController.h"
#import "STKWebserviceManager.h"
#import "UIImage+CustomBundle.h"
#import "UIView+ActivityIndicator.h"

@interface STKStickersSettingsViewController () <UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic) STKStickersEntityService* service;
@property (nonatomic) STKTableViewDataSource* dataSource;
@property (nonatomic) UIBarButtonItem* editBarButton;

@end

@implementation STKStickersSettingsViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	if (FRAMEWORK) {
		[self.tableView registerNib: [UINib nibWithNibName: @"STKStickerSettingsCell" bundle: [self getResourceBundle]] forCellReuseIdentifier: @"STKStickerSettingsCell"];
	} else {
		[self.tableView registerNib: [UINib nibWithNibName: @"STKStickerSettingsCell" bundle: [NSBundle mainBundle]] forCellReuseIdentifier: @"STKStickerSettingsCell"];
	}

	self.dataSource = [[STKTableViewDataSource alloc] initWithItems: nil cellIdentifier: @"STKStickerSettingsCell" configureBlock: ^ (STKStickerSettingsCell* cell, STKStickerPackObject* item) {
		[cell configureWithStickerPack: item];
	}];

	self.service = [STKStickersEntityService new];

	self.tableView.dataSource = self.dataSource;
	self.tableView.delegate = self;

	self.navigationItem.title = NSLocalizedString(@"Settings", nil);

	[self setUpButtons];

	typeof(self) __weak weakSelf = self;

	self.dataSource.deleteBlock = ^ (NSIndexPath* indexPath, STKStickerPackObject* item) {
		MBProgressHUD* hud = [weakSelf.view showActivityIndicator];

		[[STKWebserviceManager sharedInstance] deleteStickerPackWithName: item.packName success: ^ (id response) {
			dispatch_async(dispatch_get_main_queue(), ^ {
				[weakSelf.service togglePackDisabling: item];

				[weakSelf.tableView setEditing: NO animated: NO];
				[weakSelf.dataSource.dataSource removeObject: item];

				[weakSelf.tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationTop];
				[weakSelf.tableView setEditing: YES animated: NO];

				[hud hideAnimated: YES];
			});
		}                                                        failure: nil];
	};

	self.dataSource.moveBlock = ^ (NSIndexPath* fromIndexPath, NSIndexPath* toIndexPath) {
		[weakSelf reorderPacks];
	};
}

- (void)viewWillAppear: (BOOL)animated {
	[super viewWillAppear: animated];

	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject: @"settings" forKey: @"viewController"];
	[userDefaults synchronize];

	[self updateStickerPacks];
}

- (void)viewDidDisappear: (BOOL)animated {
	[super viewDidDisappear: animated];

	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject: @"currentVC" forKey: @"viewController"];
	[userDefaults synchronize];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSString*)getImageName: (NSString*)imName {
	NSString* bundlePath = [[NSBundle mainBundle] pathForResource: @"ResBundle" ofType: @"bundle"];
	NSString* imageName = [[NSBundle bundleWithPath: bundlePath] pathForResource: imName ofType: @"png"];

	return imageName;
}

- (void)setUpButtons {
	UIBarButtonItem* closeBarButton = nil;
	if (FRAMEWORK) {
		closeBarButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamedInCustomBundle: @"STKBackIcon"] style: UIBarButtonItemStylePlain target: self action: @selector(closeAction:)];
	} else {
		closeBarButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"STKBackIcon"] style: UIBarButtonItemStylePlain target: self action: @selector(closeAction:)];
	}

	self.navigationItem.leftBarButtonItem = closeBarButton;

	self.editBarButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Edit", nil) style: UIBarButtonItemStylePlain target: self action: @selector(editAction:)];

	self.navigationItem.rightBarButtonItem = self.editBarButton;

}

- (void)reorderPacks {
	NSMutableArray* dataSource = [self.dataSource dataSource];
	[dataSource enumerateObjectsUsingBlock: ^ (STKStickerPackObject* obj, NSUInteger idx, BOOL* stop) {
		obj.order = @(idx);
	}];
	NSArray* reorderedPacks = [NSArray arrayWithArray: dataSource];
	self.service.stickersArray = reorderedPacks;
	[self.service saveStickerPacks: reorderedPacks];
}

- (void)updateStickerPacks {
	typeof(self) __weak weakSelf = self;

	[self.service getStickerPacksIgnoringRecentWithType: nil completion: ^ (NSArray* stickerPacks) {
		[weakSelf.dataSource setDataSourceArray: stickerPacks];
		[weakSelf.tableView reloadData];
	}                                           failure: nil];
}


#pragma mark - UITableViewDelegate

- (void)tableView: (UITableView*)tableView didSelectRowAtIndexPath: (NSIndexPath*)indexPath {
	STKStickerPackObject* stickerPack = [self.dataSource itemAtIndexPath: indexPath];

	STKStickersShopViewController*shopViewController=nil;
	if (FRAMEWORK) {
		shopViewController = [[STKStickersShopViewController alloc] initWithNibName:@"STKStickersShopViewController" bundle:[self getResourceBundle]];
	} else {
		shopViewController = [[STKStickersShopViewController alloc] initWithNibName: @"STKStickersShopViewController" bundle: [NSBundle mainBundle]];
	}

	[self saveReorderings];
	shopViewController.delegate = self.delegate;
    [self.delegate showStickersView];
	shopViewController.packName = stickerPack.packName;
	[self.navigationController pushViewController: shopViewController animated: YES];
	[self.tableView deselectRowAtIndexPath: indexPath animated: YES];
}


#pragma mark - Actions

- (IBAction)editAction: (id)sender {
	[self.tableView setEditing: !self.tableView.editing animated: YES];
	self.editBarButton.title = (self.tableView.editing) ? NSLocalizedString(@"Done", nil) : NSLocalizedString(@"Edit", nil);
}

- (IBAction)closeAction: (id)sender {
	[self dismissViewControllerAnimated: YES completion: ^ {
		[self saveReorderings];

		NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject: @"currentVC" forKey: @"viewController"];
		[userDefaults synchronize];

		[self.delegate showStickersView];
	}];
}

- (void)saveReorderings {
	[[NSNotificationCenter defaultCenter] postNotificationName: STKStickersReorderStickersNotification object: self userInfo: @{@"packs" : self.dataSource.dataSource}];
	[[NSNotificationCenter defaultCenter] postNotificationName: STKCloseModalViewNotification object: self];

	[self.delegate stickersReorder: self packs: self.dataSource.dataSource];
}

- (NSBundle*)getResourceBundle {
	NSString* bundlePath = [[NSBundle mainBundle] pathForResource: @"ResBundle" ofType: @"bundle"];
	NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];

	return bundle;
}

@end
