//
//  CronoTime.h
//  PusherGame
//
//  Created by Camilo Monteagudo Pena on 20/08/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CronoTime : NSObject
  {
  NSDate *TimeRef;
  double TimeSave;
  }

+ (CronoTime*)  Now;
- (void)   Start;
- (double) GetTime;
- (void)   Pause;
- (void)   Restore;

@end
