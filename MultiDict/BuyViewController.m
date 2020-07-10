//=========================================================================================================================================================
//  BuyViewController.m
//  Dictionary Plus (English Pack)
//
//  Created by Admin on 16/2/18.
//  Copyright © 2018 BigXSoft. All rights reserved.
//=========================================================================================================================================================

#import "BuyViewController.h"
#import "AppData.h"
#import "ProdsData.h"

//=========================================================================================================================================================
@interface BuyViewController ()

@property (weak) IBOutlet NSScrollView *BoxDicts;
@property (weak) IBOutlet NSScrollView *BoxProds;

@property (weak) IBOutlet NSTableView *TableDicts;
@property (weak) IBOutlet NSTableView *TableProds;

@property (weak) IBOutlet NSButton *btnAtras;
@property (weak) IBOutlet NSButton *btnRestaurar;

@property (weak) IBOutlet NSBox *CoverScreen;
@property (weak) IBOutlet NSProgressIndicator *WaitAppStore;

- (IBAction)OnAtras:(id)sender;
- (IBAction)OnRestaurarCompras:(id)sender;

@end

//=========================================================================================================================================================
@implementation BuyViewController

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se carga la vista
- (void)viewDidLoad
  {
  [Purchases SetNotify:self];                                   // Se registra para recibir informacion sobre InApp Purchase
  
  [super viewDidLoad];
  
  [self ShowMode: _Mode Anim:FALSE];
  
  if( [Purchases IsProdInfo] ) _CoverScreen.hidden = TRUE;
  else                         [self RequestProdInfo];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cierra la vista
- (void)viewWillDisappear
  {
  [Purchases SetNotify:Ctrller];                    // Restaura el anterior
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se obtiene la informacion de los productos desde App Store
- (void) UpdatePurchaseInfo
  {
  [_TableDicts reloadData];                         // Actualiza los costos de los productos
  
  if( [Purchases IsProdInfo] )                      // Si se completo la obtención de la información de los productos
    [self HideCover];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se completa la compra de un producto
- (void) PurchaseCompleted
  {
  [_TableDicts reloadData];                         // Actualiza el estado de los productos
  
  if(_Mode!=1 )                                     // Si esta el modo diccionario
    _btnRestaurar.hidden = IsAllPurchases();        // Muestra al botón restaurar si es necesario
  
  [Ctrller PurchaseCompleted];                      // Notifica el controlador principal
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se produce un error en el mecanismo de compra
- (void) PurchaseError:(NSString*) locMsg
  {
  NSAlert *alert = [[NSAlert alloc] init];

  [alert setMessageText:     NSLocalizedString(@"TitleError", nil)];
  [alert setInformativeText: NSLocalizedString(locMsg       , nil)];

  if( [locMsg isEqualToString:@"RequestInfoError"] )
    {
    [alert addButtonWithTitle: NSLocalizedString(@"No", nil)];
    [alert addButtonWithTitle: NSLocalizedString(@"Si", nil)];
    }
  
  [alert setAlertStyle:NSWarningAlertStyle];

  [self HideCover];
  WaitMsg();
   
  [alert beginSheetModalForWindow: self.view.window
                completionHandler:^(NSModalResponse returnCode)
                                      {
                                      [alert.window orderOut:nil];
                                      
                                      if( returnCode==NSAlertSecondButtonReturn )
                                        [self RequestProdInfo];
                                      }  ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Solicita información sobre los productos
- (void) RequestProdInfo
  {
  if( ![Purchases RequestProdInfo] )               // Solicita información sobre los productos a App Store
     {
      _CoverScreen.hidden = FALSE;                    // Pone una cubierta sobre la pantalla para desabiliatar la compra de diccionarios
      
     [_WaitAppStore startAnimation:self];             // Pone a girar el control de espera
  
     _btnRestaurar.hidden = TRUE;                     // Oculta el boton de restaurar compras
     }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cierra la ventana de compras
- (void)HideView
  {
  [self dismissViewController:self];                      // Cierra la vista de compras
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Oculta la cubierta de espera mientras se conecta
- (void) HideCover
  {
  _CoverScreen.hidden = TRUE;                     // Habilita la interface para seleccionar los productos a comprar
    
  if( _Mode!=1 ) _btnRestaurar.hidden = IsAllPurchases();   // Muestra el botón de restaurar compras, si corresponde
  }


//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para saber el número de palabras de la lista de palabras del diccionario
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
  {
  if( tableView == _TableDicts )  return 12;
  else                            return 4;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para conocer la palabra que se corresponde con la fila 'row'
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
  {
  NSTableCellView* cel;
  
  if( tableView == _TableDicts )
    {
    if( [tableColumn.identifier isEqualToString:@"DictCol"] )
      {
      cel = [tableView makeViewWithIdentifier:@"DictCell" owner:tableView];
      cel.textField.stringValue = DIRName( (int)row, FALSE, FALSE );
      }
    else
      {
      cel = [tableView makeViewWithIdentifier:@"IconCell" owner:tableView];
  
      NSString* IcoName = IsBuyDir((int)row)? @"BuyOK" : @"BuyItem";
      
      NSImageView* imgCell = cel.subviews[0];
    
      imgCell.image = [NSImage imageNamed:IcoName];
      }
    }
  else
    {
    int idxProd = ProdWithDirAndPos( _NowDir, (int)row );
    
    if( [tableColumn.identifier isEqualToString:@"ProdCol"] )
      {
      cel = [tableView makeViewWithIdentifier:@"ProdCell" owner:tableView];
      cel.textField.attributedStringValue = GetProdDesc( idxProd );
      }
    else
      {
      cel = [tableView makeViewWithIdentifier:@"PrecioCell" owner:tableView];
      cel.textField.stringValue = GetPrecio(idxProd);
      }
    }
  
  return cel;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
static int Heigths[] = { 168, 116, 116, 80, 60, 60,};
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina la altura de las filas de la tabla
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
  {
  if( tableView == _TableDicts ) return 40;
  else                           return Heigths[row];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia la selección
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
  {
  NSTableView* table = aNotification.object;
  
  int row = (int)table.selectedRow;                           // Obtiene la fila seleccionada
  if( row==-1 ) return;
  
  if( table ==  _TableDicts )                                 // Se selecciono un diccionario
    {
    _NowDir = row;                                            // Pone el diccionario seleccionado como el actual
    [_TableProds reloadData];                                 // Refresca la tabla de productos para el diccionario actual
    
    [self ShowMode:1 Anim:TRUE];                              // Cambia el modo de la vista para mostrar los productos
    }
  else                                                        // Se selecciono una compra
    {
    int idxProd = ProdWithDirAndPos( _NowDir, (int)row );     // Obtiene el indice del producto seleccionado
    NSString* idProd = getIdProdAt( idxProd );                // Obtiene el identificador del producto en App Store
    
    if( [Purchases PurchaseProd: idProd] )                    // Inicia el proceso de compra
      [self HideView];                                        // Cierra la vista de compras
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si la fila se puede seleccionar o no
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
  {
  if( !_CoverScreen.hidden ) return NO;
  
  if( tableView == _TableDicts && IsBuyDir((int)row) ) return NO;
  
  return YES;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambia el modo de la ventana de compras 0 - Muestra diccionarios comprados, 1 - Muestra ventas que icluyen diccionario seleccionado
- (void) ShowMode:(int) newMode Anim:(BOOL) anim
  {
  _Mode = newMode;
  
  //if( !anim ) return;
  
  NSRect rcD = _BoxDicts.frame;
  NSRect rcP = _BoxProds.frame;
  
  if( newMode == 1 )
    {
    rcP.origin.x = 10;
    rcD.origin.x = -(rcD.origin.x + rcD.size.width);
    
    _btnAtras.hidden = false;
    _btnRestaurar.hidden = true;
    }
  else
    {
    rcD.origin.x = 10;
    rcP.origin.x = self.view.frame.size.width;
    
    _btnAtras.hidden = true;
    _btnRestaurar.hidden = IsAllPurchases();
    }
  
  if( anim )
    {
    [[_BoxProds animator] setFrame:rcP];
    [[_BoxDicts animator] setFrame:rcD];
    }
  else
    {
    [_BoxProds setFrame:rcP];
    [_BoxDicts setFrame:rcD];
    
    //NSRect rcCv = _CoverScreen.frame;
    //rcCv.origin.x = 10;
    
    ///_CoverScreen.frame = rcCv;
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Regresa al modo donde se muestran los diccionarios comprados
- (IBAction)OnAtras:(id)sender
  {
  if( !_CoverScreen.hidden ) return;
  
//  #ifdef DEBUG
//    ClearPurchase();
//  #endif
  
  [self ShowMode:0 Anim:TRUE];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Restaura todas las compar realizadas con el Apple ID actual
- (IBAction)OnRestaurarCompras:(id)sender
  {
  if( !_CoverScreen.hidden ) return;
  
  [Purchases RestorePurchases];
  [self HideView];
  }


@end
//=========================================================================================================================================================

