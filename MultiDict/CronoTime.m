//
//  CronoTime.m
//  PusherGame
//
//  Created by Camilo Monteagudo Pena on 20/08/14.
//  Copyright (c) 2014 NiceGames. All rights reserved.
//

#import "CronoTime.h"

@implementation CronoTime

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un objeto y empieza a contar al tiempo a partir del momento de llamada
+ (CronoTime*) Now
  {
  CronoTime* crono = [CronoTime new];
  [crono Start];

  return crono;
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Inicia el conteo de tiempo
- (void) Start
	{
  TimeRef = [NSDate date];                                                            // Marca tiempo de inicio de la escena
  TimeSave = -1;
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el tiempo trascurrido desde el último Start
- (double) GetTime
  {
  return -[TimeRef timeIntervalSinceNow ];
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Detiene momentaneamente el conteo del tiempo
- (void) Pause
  {
  TimeSave = [self GetTime];
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Continua contando el tiempo a partir de momento que se llamo Pause
- (void) Restore
  {
  if( TimeSave == -1 ) return;
  
  double tmp = TimeSave;
  [self Start];
  
  TimeRef = [TimeRef dateByAddingTimeInterval:-tmp];
  }

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

@end
