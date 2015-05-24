//
//  RMUniversalAlert.m
//  RMUniversalAlert
//
//  Created by Ryan Maxwell on 19/11/14.
//  Copyright (c) 2014 Ryan Maxwell. All rights reserved.
//

#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>

#import "RMUniversalAlert.h"
#import "UIActionSheet+BlocksKit.h"

static NSInteger const RMUniversalAlertNoButtonExistsIndex = -1;

static NSInteger const RMUniversalAlertCancelButtonIndex = 0;
static NSInteger const RMUniversalAlertDestructiveButtonIndex = 1;
static NSInteger const RMUniversalAlertFirstOtherButtonIndex = 2;

@interface RMUniversalAlert ()

@property (nonatomic) UIAlertController *alertController;
@property (nonatomic) UIAlertView *alertView;
@property (nonatomic) UIActionSheet *actionSheet;

@property (nonatomic, assign) BOOL hasCancelButton;
@property (nonatomic, assign) BOOL hasDestructiveButton;
@property (nonatomic, assign) BOOL hasOtherButtons;

@end

@implementation RMUniversalAlert

+ (instancetype)showAlertInViewController:(UIViewController *)viewController
                                withTitle:(NSString *)title
                                  message:(NSString *)message
                        cancelButtonTitle:(NSString *)cancelButtonTitle
                   destructiveButtonTitle:(NSString *)destructiveButtonTitle
                        otherButtonTitles:(NSArray *)otherButtonTitles
                                 tapBlock:(RMUniversalAlertCompletionBlock)tapBlock
{
    RMUniversalAlert *alert = [[RMUniversalAlert alloc] init];

    alert.hasCancelButton = cancelButtonTitle != nil;
    alert.hasDestructiveButton = destructiveButtonTitle != nil;
    alert.hasOtherButtons = otherButtonTitles.count > 0;

    if ([UIAlertController class]) {
        alert.alertController = [UIAlertController showAlertInViewController:viewController
                                                                   withTitle:title message:message
                                                           cancelButtonTitle:cancelButtonTitle
                                                      destructiveButtonTitle:destructiveButtonTitle
                                                           otherButtonTitles:otherButtonTitles
                                                                    tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                                                        if (tapBlock) {
                                                                            tapBlock(alert, buttonIndex);
                                                                        }
                                                                    }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title
                                                           message:message
                                                          delegate:viewController
                                                 cancelButtonTitle:cancelButtonTitle
                                                 otherButtonTitles:nil];
        [alertView show];
    }

    return alert;
}

+ (instancetype)showActionSheetInViewController:(UIViewController *)viewController
                                      withTitle:(NSString *)title
                                        message:(NSString *)message
                              cancelButtonTitle:(NSString *)cancelButtonTitle
                         destructiveButtonTitle:(NSString *)destructiveButtonTitle
                              otherButtonTitles:(NSArray *)otherButtonTitles
             popoverPresentationControllerBlock:(void(^)(RMPopoverPresentationController *popover))popoverPresentationControllerBlock
                                       tapBlock:(RMUniversalAlertCompletionBlock)tapBlock
{
    RMUniversalAlert *alert = [[RMUniversalAlert alloc] init];

    alert.hasCancelButton = cancelButtonTitle != nil;
    alert.hasDestructiveButton = destructiveButtonTitle != nil;
    alert.hasOtherButtons = otherButtonTitles.count > 0;

    if ([UIAlertController class]) {

        alert.alertController = [UIAlertController showActionSheetInViewController:viewController
                                                                         withTitle:title
                                                                           message:message
                                                                 cancelButtonTitle:cancelButtonTitle
                                                            destructiveButtonTitle:destructiveButtonTitle
                                                                 otherButtonTitles:otherButtonTitles
                                                popoverPresentationControllerBlock:^(UIPopoverPresentationController *popover){
                                                    if (popoverPresentationControllerBlock) {
                                                        RMPopoverPresentationController *configuredPopover = [RMPopoverPresentationController new];

                                                        popoverPresentationControllerBlock(configuredPopover);

                                                        popover.sourceView = configuredPopover.sourceView;
                                                        popover.sourceRect = configuredPopover.sourceRect;
                                                        popover.barButtonItem = configuredPopover.barButtonItem;
                                                    }
                                                }
                                                                          tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                                                              if (tapBlock) {
                                                                                  tapBlock(alert, buttonIndex);
                                                                              }
                                                                          }];
    } else {

        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.delegate = viewController;
        actionSheet.title = message;

        int btnCount = 0;

        if (otherButtonTitles != nil) {
            btnCount = otherButtonTitles.count;
            for (int i = 0; i < otherButtonTitles.count; i++) {
                [actionSheet addButtonWithTitle:otherButtonTitles[i]];
            }
        }

        if (destructiveButtonTitle != nil) {
            [actionSheet addButtonWithTitle:destructiveButtonTitle];
            actionSheet.destructiveButtonIndex = btnCount;
            btnCount += 1;
        }

        if (cancelButtonTitle != nil) {
            [actionSheet addButtonWithTitle:cancelButtonTitle];
            actionSheet.cancelButtonIndex = btnCount;
        }

        [actionSheet showInView:viewController.view];
        alert.actionSheet = actionSheet;
    }

    return alert;
}

#pragma mark -

- (BOOL)visible
{
    if (self.alertController) {
        return self.alertController.visible;
    } else if (self.alertView) {
        return self.alertView.visible;
    } else if (self.actionSheet) {
        return self.actionSheet.visible;
    }
    NSAssert(false, @"Unsupported alert.");
    return NO;
}

- (NSInteger)cancelButtonIndex
{
    if (!self.hasCancelButton) {
        return RMUniversalAlertNoButtonExistsIndex;
    }

    return RMUniversalAlertCancelButtonIndex;
}

- (NSInteger)firstOtherButtonIndex
{
    if (!self.hasOtherButtons) {
        return RMUniversalAlertNoButtonExistsIndex;
    }

    return RMUniversalAlertFirstOtherButtonIndex;
}

- (NSInteger)destructiveButtonIndex
{
    if (!self.hasDestructiveButton) {
        return RMUniversalAlertNoButtonExistsIndex;
    }

    return RMUniversalAlertDestructiveButtonIndex;
}


@end
