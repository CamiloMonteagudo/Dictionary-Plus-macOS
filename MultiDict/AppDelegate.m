//===================================================================================================================================================
//  AppDelegate.m
//  MultiDict
//
//  Created by Camilo Monteagudo on 1/12/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import "AppDelegate.h"
#import "AppData.h"
#import "ViewController.h"
#import "AppPurchases.h"
#import "ProdsData.h"

//===================================================================================================================================================
@interface AppDelegate ()
  {
  id Observer;
  }

@end

//===================================================================================================================================================
@implementation AppDelegate

- (instancetype)init
  {
  ReadAppData();
  
  return [super init];
  }
//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
  {
  [Purchases Initialize];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillTerminate:(NSNotification *)aNotification
  {
  [Purchases Remove];  // Evita que iOS mande mensajes a la aplicacion desdpues de terminada
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames
  {
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cierra la ultima ventana de la aplicación, para confirmar que se cierre la aplicación
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
  {
  return YES;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama después de cargar el XIB files
- (void)awakeFromNib
  {
  iUser = NSLocalizedString(@"UILang", nil).intValue;
  
  [self LoadUserDefaults ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga los valores por defecto de algunos parametros
-(void) LoadUserDefaults
  {
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];

  NSNumber* pDir = [UserDef objectForKey:@"lastDir"];       // Última dirección de traducción utilizada
  if( pDir != nil )                                         // Si se obtuvo la dirección
    {
    int iDir = pDir.intValue;                               // Obtiene el valor

    LGSrc = DIRSrc(iDir);                                   // Obtiene el idioma fuente de la dirección
    LGDes = DIRDes(iDir);                                   // Obtiene el idioma destino de la dirección

    //NSLog(@"Dirección guardada src=%d dest=%d", LGSrc, LGDes);
    }
  else DIRFirst();                                          // Obtiene la primera dirección de traducción instalada
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra el dialogo de About
- (IBAction)ShowStandarAbout:(id)sender
  {
//  NSString *AppName = [[NSProcessInfo processInfo] processName];
  
  NSDictionary *Options = @{ @"ApplicationName":@"Dictionary Plus"};
  
  [NSApp orderFrontStandardAboutPanelWithOptions:Options];
  }
  
  
//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//===================================================================================================================================================

