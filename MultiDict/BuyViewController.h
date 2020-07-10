//=========================================================================================================================================================
//  BuyViewController.h
//  Dictionary Plus (English Pack)
//
//  Created by Admin on 16/2/18.
//  Copyright © 2018 BigXSoft. All rights reserved.
//=========================================================================================================================================================

#import <Cocoa/Cocoa.h>
#import "AppPurchases.h"

@interface BuyViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, ShowPurchaseUI>

@property int Mode;
@property int NowDir;

@end
//=========================================================================================================================================================
