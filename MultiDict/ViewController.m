//===================================================================================================================================================
//  ViewController.m
//  MultiDict
//
//  Created by Camilo Monteagudo on 1/12/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import "ViewController.h"
#import "EntryDict.h"
#import "ZoneDatosView.h"
#import "CronoTime.h"
#import "SortedIndexs.h"
#import "ConjCore.h"
#import "ConjSimple.h"
#import "FindMeans.h"
#import "ConjCtrller.h"
#import "FindPlusCtrller.h"
#import "BtnsData.h"
#import "BuyViewController.h"
#import "ProdsData.h"

//===================================================================================================================================================
@interface ViewController()
  {
  SortedIndexs* SortEntries;

  ConjSimple* Conjs;
  TextQuery* Query;
  
  int PurchDir;
  }

@property (weak) IBOutlet NSPopUpButton *CbLangs;
@property (weak) IBOutlet NSProgressIndicator *WaitForDict;
@property (weak) IBOutlet ZoneDatosView *ZonaDatos;

@property (weak) IBOutlet MyButton *btnSwapDict;
@property (weak) IBOutlet MyButton *btnConjPanel;
@property (weak) IBOutlet NSTableView *lstConjugates;
@property (weak) IBOutlet NSView *ConjPanel;
@property (weak) IBOutlet NSSearchField *FindConj;
@property (weak) IBOutlet NSLayoutConstraint *HeaderHeight;
@property (weak) IBOutlet NSView *HeaderBox;
@property (weak) IBOutlet NSBox *DictBox;
@property (weak) IBOutlet NSTextField *txtHeaderMsg;
@property (weak) IBOutlet NSBox *boxHeaderMsg;
@property (weak) IBOutlet NSButton *btnComprar;

- (IBAction)OnChangeFrase:(NSSearchField *)sender;
- (IBAction)OnDelAllDatos:(NSButton *)sender;
- (IBAction)OnSwapDict:(MyButton *)sender;
- (IBAction)OnConjQuery:(MyButton *)sender;
- (IBAction)OnCloseConjPanel:(id)sender;
- (IBAction)OnCloseMsg:(MyButton *)sender;

- (IBAction)OnShowCojugator:(MyButton *)sender;
- (IBAction)OnShowAvancedFind:(MyButton *)sender;
- (IBAction)OnShowCompras:(NSView *)sender;
- (IBAction)OnComprarDir:(id)sender;

@end

//===================================================================================================================================================
@implementation ViewController

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  Ctrller = self;
  PurchDir = -1;
  [Purchases SetNotify:self];                                   // Se registra para recibir informacion sobre InApp Purchase

  SortEntries = [SortedIndexs Empty];

  [super viewDidLoad];

  Conjs = [ConjSimple CreateForTable:_lstConjugates Query:_txtFrase FindConj:_FindConj];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear
  {
  [self FillLanguajesCombo];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se obtiene la informacion de los productos desde App Store
- (void) UpdatePurchaseInfo
  {
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se completa la compra de un producto
- (void) PurchaseCompleted
  {
  if( IsBuyDir(PurchDir) )
    [self HidePurchaseMsg];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se produce un error en el mecanismo de compra
- (void) PurchaseError:(NSString*) locMsg
  {
  if( ![locMsg isEqualToString:@"RequestInfoError"] )
    [self ShowMsg:locMsg WithTitle:@"TitleError"];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Llena el combo de idiomas con los idiomas disponible
- (void) FillLanguajesCombo
  {
  [_CbLangs removeAllItems];                                  // Borra todos los items del combo de idioma

  for(int iDir=0; iDir<DIRCount(); iDir++)                    // Recorre todas las direcciones de traducción
    {
    NSString* sDir = DIRName(iDir,FALSE,FALSE);               // Obtiene el nombre de la dirección

    [_CbLangs addItemWithTitle:sDir];                         // La adicona al combo de idiomas

    NSMenuItem* Item = _CbLangs.lastItem;                     // Obtiene el item añadido al menú
    Item.tag = iDir;                                          // Le pone la dirección que representa

    Item.target = self;                                       // Pone objeto para reportar las acciones
    Item.action = @selector(OnSelDir:);                       // Pone la función a la que se reporta la acción
    }
  
  [self LoadDictWithSrc:LGSrc AndDes:LGDes];                  // Carga el diccionario para los idiomas por defecto
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se selecciona una dirección de traducción
- (void)OnSelDir:(id)sender
  {
  int iDir = (int)((NSMenuItem*)sender).tag;                  // Obtiene dirección del item seleccionado

  int src = DIRSrc(iDir);                                     // Obtiene idioma fuente de la dirección
  int des = DIRDes(iDir);                                     // Obtiene idioma destino de la dirección

  [self LoadDictWithSrc:src AndDes:des];                      // Carga el diccionario para los idiomas seleccionados
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga el diccionario para los idiomas activos
- (void) LoadDictWithSrc:(int) src AndDes:(int) des
  {
  int iDir = DIRFromLangs( src, des );                         // Toma la dirección seleccionada
  
  if( ![self CheckPurchase:iDir] )                             // Chequea que el diccionarios este comprado o en modo prueba
     return;                                                   // No lo carga hasta que no sea comprado
  
  LGSrc = src;
  LGDes = des;
  [_CbLangs selectItemWithTag:iDir];                          // Selecciona el diccionario actual
  
  [_WaitForDict startAnimation:self];

  // Guarda dirección seleccionada en los datos del usuario
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  [UserDef setObject:[NSNumber numberWithInt:iDir] forKey:@"lastDir"];

  BOOL ret1 = [DictMain    LoadWithSrc:LGSrc AndDes:LGDes ];
  BOOL ret2 = [DictIndexes LoadWithSrc:LGSrc AndDes:LGDes ];

  if( ret1 && ret2 )
    {
    [self SetTitle];
    [self FindFrases];
    }
  else
    [self ShowHeaderMsg:@"NoLoadDict"];

  [_WaitForDict stopAnimation:self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone un mensaje en la parte de arriba de la ventana principal
- (void) ShowHeaderMsg:(NSString*) locMsg
  {
  NSString* msg  = NSLocalizedString(locMsg, nil);
  
  _boxHeaderMsg.fillColor = MsgSelColor;
  _txtHeaderMsg.textColor = MsgTxtColor;
  
  _txtHeaderMsg.stringValue = msg;
  
  _HeaderHeight.constant = 60;
  _btnComprar.hidden = true;
  
  PurchDir = -1;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone un mensaje de compra en la parte de arriba
- (void) ShowPurchaseMsgForDir:(int) iDir
  {
  PurchDir = iDir;
  
  _boxHeaderMsg.fillColor = MsgSelColor;
  _txtHeaderMsg.attributedStringValue = MsgForDir( @"DictBuyMsg1", iDir);
  
  _HeaderHeight.constant = 60;
  _btnComprar.hidden = false;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Oculata el de compra en la parte de arriba
- (void) HidePurchaseMsg
  {
  _HeaderHeight.constant = 32;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Chequea que el dicionario 'iDir' este comprado o se pueda usar en modo de prueba
- (BOOL) CheckPurchase:(int) iDir
  {
  if( IsBuyDir(iDir) )                                          // Si el diccionario ya esta comprado
    {
    nBuyDays = -1;                                              // Muestra todas las llaves
    [self HidePurchaseMsg];                                     // Oculta el mensaje de la parte de arriba si esta puesto
    return TRUE;                                                // Retorna que el diccionario se puede usar
    }
  
  BOOL ret = TRUE;
  nBuyDays = GetDayCount();                                     // Obtiene los días trascurridos desde la primera corrida
  
//  if( nDay>15 )                                                 // Si pasaron más de 15 dias
//    {
//    int iDirNow = DIRFromLangs( LGSrc, LGDes );                 // Toma la dirección actual
//    [_CbLangs selectItemWithTag:iDirNow];                       // Selecciona el diccionario anterior
//    
//    NSNumber *dir = [NSNumber numberWithInt: iDir ];
//    [self performSegueWithIdentifier:@"Purchases" sender:dir];  // Muestra la vista de compra
//
//    ret = FALSE;                                                // El dicionario no paso el chequeo y no se puede usar
//    }
  
  [self ShowPurchaseMsgForDir: iDir];                             // Muestra un mensaje en la parte de arriba
  return ret;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el titulo de la ventana principal
-(void) SetTitle
  {
  NSString* sSrc = [LGName(LGSrc) stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet] ];
  NSString* sDes = [LGName(LGDes) stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet] ];


  NSWindow* win = self.view.window;
  win.title = [NSString stringWithFormat: @"%@ (%@-%@)", NSLocalizedString(@"WinTitle", nil), sSrc, sDes ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada vez que se cambia la frase que se esta buscando
- (IBAction)OnChangeFrase:(NSSearchField *)sender
  {
  [self FindFrases];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Borra todos los datos que hay en la lista
- (IBAction)OnDelAllDatos:(NSButton *)sender
  {
  [_ZonaDatos ClearDatos];

  [ZoneDatosView SelectDatos:nil];
  
  _btnDelAllDatos.hidden = true;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Borra la entrada seleccionada
- (void) DelEntry
  {
  [_ZonaDatos DeleteSelectedDatos];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Intercambia la fuente y origen del diccionario
- (IBAction)OnSwapDict:(MyButton *)sender
  {
  [self LoadDictWithSrc:LGDes AndDes:LGSrc];                // Carga el diccionario inverso
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Trata de conjugar el primer verbo que encuentre en el query o la palabra seleccionada
- (IBAction)OnConjQuery:(MyButton *)sender
  {
  if( [Conjs FindConjQuery: Query] )
    {
    _ConjPanel.hidden = false;
    }
  else
    {
    _ConjPanel.hidden = TRUE;

    [self OnShowCojugator:nil ];
//    [self ShowMsg:@"NoVerbInQuery" WithTitle:@"TitleConj"];
    }
  
  [self SetPanelIcon];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cierra el panel de conjugaciones
- (IBAction)OnCloseConjPanel:(id)sender
  {
  _ConjPanel.hidden = !_ConjPanel.hidden;
  [self SetPanelIcon];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Oculta la franja de arriba donde se muestran los mensajes
- (IBAction)OnCloseMsg:(MyButton *)sender
  {
//  NSSize sz1 = _HeaderBox.frame.size;
//  
//  CGFloat dif = sz1.height-32;
//  sz1.height = 32;
//  
//  //[[_HeaderBox animator] setFrameSize:sz1];
//
//  NSSize sz2 = _DictBox.frame.size;
//  sz2.height += dif;
//  
//  //[[_DictBox animator] setFrameSize:sz2];
//  [_HeaderBox setWantsLayer:YES];
//  [_DictBox   setWantsLayer:YES];
//
//  [NSAnimationContext beginGrouping ];
//  [NSAnimationContext currentContext].allowsImplicitAnimation = YES;
//  [NSAnimationContext currentContext].duration = 10;

  //[[_HeaderBox animator] setFrameSize:sz1];
  //[[_DictBox animator] setFrameSize:sz2];
  
  //[_HeaderBox setFrameSize:sz1];
 // [_DictBox   setFrameSize:sz2];
  
   [self HidePurchaseMsg];                                     // Oculta el mensaje de la parte de arriba si esta puesto
  
//  [NSAnimationContext endGrouping];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para conjugar una palabra en la vista de datos
- (void) ConjWordOnData
  {
  DatosView* selDatos = [ZoneDatosView SelectedDatosView];
  if( !selDatos ) return;
  
  int lang;
  NSString* selWrd = [selDatos getSelWordAndLang:&lang];
  
  Conjs.Verb = selWrd;
  Conjs.ConjLang = lang;
  
  [Conjs FindConjs];
  _ConjPanel.hidden = false;
  [self SetPanelIcon];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para buscar las traducciones de una palabra en la vista de datos
- (void) TrdWordOnData
  {
  DatosView* selDatos = [ZoneDatosView SelectedDatosView];
  if( !selDatos ) return;
  
  int src = selDatos.src;
  int des = selDatos.des;
  
  NSButton* btn = BtnsData.BtnFindWord;
  btn.title = @"";
  btn.enabled = FALSE;
  
  int lang;
  NSString* selWrd = [selDatos getSelWordAndLang:&lang];
  if( lang==des )
    {
    if( ![self GetViewDataForWord:selWrd Src:des Des:src] )
      {
      NSString* rootWrd = [ConjCore FindRootWord:selWrd Lang:des];
      
      if( rootWrd==nil || ![self GetViewDataForWord:rootWrd Src:des Des:src] )
        [self ShowMsg:@"NoFindWrd" WithTitle:@"TitleFindMeans"];
      }
    }
  
  btn.enabled = TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca el la palabra en el diccionario y agrega una vista con sus datos
- (BOOL) GetViewDataForWord:(NSString*) sWord Src:(int)src Des:(int)des
  {
  //if( sWord==nil ) return FALSE;
  
  EntryIndex* idx = FindIndexsForWord(sWord, src, des);
  if( idx == nil ) return FALSE;
  
  EntryDict* entry = FindWordEntry(idx, src, des);
  if( entry == nil ) return FALSE;
      
  [_ZonaDatos AddAfterSelDatos:entry Src:src Des:des ];
  return TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone el icono correspondiente para abrir o cerrar el panel de conjugaciones
- (void) SetPanelIcon
  {
  if( _ConjPanel.hidden ) _btnConjPanel.image = [NSImage imageNamed:@"OpenPanel"];
  else                    _btnConjPanel.image = [NSImage imageNamed:@"ClosePanel"];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para saber el número de palabras de la lista de palabras del diccionario
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
  {
  return SortEntries.Count;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
static CGFloat FontSize   = [NSFont systemFontSize];                            // Tamaño de la letras estandard del sistema

static NSFont* fontReg   = [NSFont systemFontOfSize:     FontSize];             // Fuente para los significados
static NSFont* fontBold  = [NSFont boldSystemFontOfSize: FontSize];             // Fuente para los textos resaltados dentro del significado

static NSDictionary* attrKey = @{ NSFontAttributeName:fontReg };
static NSDictionary* attrWrd = @{ NSFontAttributeName:fontBold };

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para conocer la palabra que se corresponde con la fila 'row'
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
  {
  NSTableCellView* cel = [tableView makeViewWithIdentifier:@"DictKey" owner:tableView];

  EntrySort* entry = SortEntries->Entries[row];

  int idx = entry->Index;
  NSString* key = Dict.Items[idx].Key;

  NSInteger PosLst[50];
  NSInteger LenLst[50];
  NSInteger pos = 0;

  NSScanner* sc = [NSScanner scannerWithString:key];
  while( !sc.isAtEnd && pos<50 )
    {
    [sc scanCharactersFromSet:wrdSep intoString:nil];

    NSInteger IniWrd = sc.scanLocation;

    [sc scanUpToCharactersFromSet:wrdSep intoString:nil];

    PosLst[pos] = IniWrd;
    LenLst[pos] = sc.scanLocation-IniWrd;

    ++pos;
    }

  NSMutableAttributedString* TxtKey  = [[NSMutableAttributedString alloc] initWithString:key attributes:attrKey  ];

  NSInteger nPos = entry->WrdsPos.count;
  for( int i=0; i<nPos; ++i )
    {
    NSInteger wPos = entry->WrdsPos[i].integerValue;
    if( wPos>=pos ) continue;

    NSRange rg = NSMakeRange( PosLst[wPos], LenLst[wPos] );

    [TxtKey setAttributes:attrWrd range:rg];
    }

  cel.textField.attributedStringValue = TxtKey;

  return cel;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia la selección de la palabra actual en la lista de palabras del diccionario
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
  {
  int row = (int)_tableFrases.selectedRow;
  if( row==-1 ) return;
  
  int idx = SortEntries->Entries[row]->Index;

  [_ZonaDatos AddDatosAtIndex:idx];

  [_ZonaDatos scrollPoint:NSMakePoint(0, 0)];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Encuentra todas las palabras frases y oraciones que cumplen el criterio de busqueda
- (void) FindFrases
  {
  Query = [TextQuery QueryWithText: _txtFrase.stringValue ];                // Obtiene el query

  FOUNDS_ENTRY* FoundEntries = [Query FindWords];                           // Busca las palabras

  SortEntries = [SortedIndexs SortEntries:FoundEntries Query:Query];        // Organiza las palabras por su ranking

  [_tableFrases reloadData];                                                // Actualiza el contenido de la lista
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Realiza una busqueda avanzada de palabras y frases, según los datos suministrados en 'Query' y 'sw'
- (void) FindFrasesWithQuery:(TextQueryPlus*) query Options:(int) sw
  {
  FOUNDS_ENTRY* FoundEntries = [query FindWords];                           // Busca las palabras

  SortEntries = [SortedIndexs SortEntries:FoundEntries QueryPlus:query Options:sw];    // Organiza las palabras por su ranking

  [_tableFrases reloadData];                                                // Actualiza el contenido de la lista
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra un mensaje con el titulo 'title' y el contenido 'msg'
- (void) ShowMsg:(NSString*) msg WithTitle:(NSString*) title
  {
  NSAlert *alert = [[NSAlert alloc] init];

  [alert setMessageText:     NSLocalizedString(title, @"")];
  [alert setInformativeText: NSLocalizedString(msg  , @"")];

  [alert setAlertStyle:NSWarningAlertStyle];

  [alert beginSheetModalForWindow: self.view.window
                completionHandler:^(NSModalResponse returnCode)
                                      {
                                      [alert.window orderOut:nil];
                                      }  ];

  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra la ventana de del conjugador
- (IBAction)OnShowCojugator:(MyButton *)sender;
  {
  [self performSegueWithIdentifier:@"Conjugator" sender:self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra la ventana de búquedas avanzadas
- (IBAction)OnShowAvancedFind:(MyButton *)sender;
  {
  [self performSegueWithIdentifier:@"FindPlus" sender:self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se primer el boton de mostrar compras
- (IBAction)OnShowCompras:(NSView *)sender
  {
  NSNumber *dir = [NSNumber numberWithInt:-1];
  [self performSegueWithIdentifier:@"Purchases" sender:dir];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra la ventana de búquedas avanzadas
- (IBAction)OnComprarDir:(id)sender
  {
  int iDir = IsBuyDir(PurchDir)? -1 : PurchDir;                 // Mustra todos los diccionarios
  [self ShowPurchsesForDir:iDir];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra la vista de compras para la dirección 'Dir'
- (void) ShowPurchsesForDir:(int) iDir
  {
  NSNumber *dir = [NSNumber numberWithInt: iDir ];
  [self performSegueWithIdentifier:@"Purchases" sender:dir];    // Muestra la vista de compras dentro de la aplicación
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama antes de llamar otro viewController validar si se debe mostrar
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
  {
//  if( [identifier isEqualToString:@"FindPlus"] && _txtFrase.stringValue.length==0 )
//    {
//    [self ShowMsg:@"NoStringFind" WithTitle:@"TitleFindPlus"];
//    return FALSE;
//    }

  return TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama antes de llamar otro viewController para pasarle información
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
  {
  NSString* sID = segue.identifier;

  if( [sID isEqualToString:@"Conjugator"] )
   {
   ConjCtrller* cnjCtrller = segue.destinationController;

   cnjCtrller.ConjLang = Conjs.ConjLang;
   cnjCtrller.Verb = Conjs.Verb;
   }
  else if( [sID isEqualToString:@"FindPlus"] )
   {
   FindPlusCtrller* findCtrller = segue.destinationController;

   findCtrller.FindText = _txtFrase.stringValue;
   }
  else if( [sID isEqualToString:@"Purchases"] )
    {
    BuyViewController* Ctrller = segue.destinationController;
    
    int dir =  [(NSNumber *)sender intValue];
  
    Ctrller.NowDir = dir;
    Ctrller.Mode   = (dir>=0)? 1 : 0;
    }
  }
  
@end
//===================================================================================================================================================
