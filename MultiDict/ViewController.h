//===================================================================================================================================================
//  ViewController.h
//  MultiDict
//
//  Created by Camilo Monteagudo on 1/12/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import <Cocoa/Cocoa.h>
#import "TextQueryPlus.h"
#import "AppPurchases.h"

@interface ViewController : NSViewController <ShowPurchaseUI>

@property (weak) IBOutlet NSSearchField *txtFrase;
@property (weak) IBOutlet NSTableView *tableFrases;

@property (weak) IBOutlet NSButton *btnDelAllDatos;

//- (void) EnableBtns:(int) sw;
//- (void) DisenableBtns:(int) sw;

- (void) ShowMsg:(NSString*) msg WithTitle:(NSString*) title;
- (void) ShowHeaderMsg:(NSString*) locMsg;
- (void) ShowPurchsesForDir:(int) iDir;

- (void) FindFrasesWithQuery:(TextQueryPlus*) query Options:(int) sw;

- (void) DelEntry;
- (void) ConjWordOnData;
- (void) TrdWordOnData;
- (void) HidePurchaseMsg;

@end
//===================================================================================================================================================

