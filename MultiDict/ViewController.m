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

//===================================================================================================================================================
@interface ViewController()
  {
  SortedIndexs* SortEntries;

  ConjSimple* Conjs;
  TextQuery* Query;
  }

@property (weak) IBOutlet NSPopUpButton *CbLangs;
@property (weak) IBOutlet NSProgressIndicator *WaitForDict;
@property (weak) IBOutlet NSProgressIndicator *WaitFind;
@property (weak) IBOutlet ZoneDatosView *ZonaDatos;

@property (weak) IBOutlet MyButton *btnSwapDict;
@property (weak) IBOutlet MyButton *btnDelAllDatos;
@property (weak) IBOutlet MyButton *btnDelSelDato;
@property (weak) IBOutlet MyButton *btnCopyTrd;
@property (weak) IBOutlet MyButton *btnConjPanel;
@property (weak) IBOutlet MyButton *btnConjWrd;
@property (weak) IBOutlet MyButton *btnTrdWrd;
@property (weak) IBOutlet NSTableView *lstConjugates;
@property (weak) IBOutlet NSView *ConjPanel;
@property (weak) IBOutlet NSSearchField *FindConj;

- (IBAction)OnChangeFrase:(NSSearchField *)sender;
- (IBAction)OnDelAllDatos:(NSButton *)sender;
- (IBAction)DelEntry:(NSButton *)sender;
- (IBAction)CopyTrd:(NSButton *)sender;
- (IBAction)OnSwapDict:(MyButton *)sender;
- (IBAction)OnConjQuery:(MyButton *)sender;
- (IBAction)OnCloseConjPanel:(id)sender;
- (IBAction)OnConjWord:(MyButton *)sender;
- (IBAction)OnTrdWord:(MyButton *)sender;

- (IBAction)OnShowCojugator:(MyButton *)sender;
- (IBAction)OnShowAvancedFind:(MyButton *)sender;

@end

//===================================================================================================================================================
@implementation ViewController

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  Ctrller = self;

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
- (void)setRepresentedObject:(id)representedObject
  {
  [super setRepresentedObject:representedObject];

  // Update the view, if already loaded.
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Llena el combo de idiomas con los idiomas disponible
- (void) FillLanguajesCombo
  {
  [_CbLangs removeAllItems];                                  // Borra todos los items del combo de idioma

  for(int iDir=0; iDir<DIRCount(); iDir++)                    // Recorre todas las direcciones de traducción
    {
    NSString* sDir = DIRName(iDir);                           // Obtiene el nombre de la dirección

    [_CbLangs addItemWithTitle:sDir];                         // La adicona al combo de idiomas

    NSMenuItem* Item = _CbLangs.lastItem;                     // Obtiene el item añadido al menú
    Item.tag = iDir;                                          // Le pone la dirección que representa

    Item.target = self;                                       // Pone objeto para reportar las acciones
    Item.action = @selector(OnSelDir:);                       // Pone la función a la que se reporta la acción
    }

  [self LoadDictionary];                                      // Carga el diccionario para los idiomas seleccionados
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se selecciona una dirección de traducción
- (void)OnSelDir:(id)sender
  {
  int iDir = (int)((NSMenuItem*)sender).tag;                // Obtiene dirección del item seleccionado

  LGSrc = DIRSrc(iDir);                                     // Obtiene idioma fuente de la dirección
  LGDes = DIRDes(iDir);                                     // Obtiene idioma destino de la dirección

  [self LoadDictionary];                                    // Carga el diccionario para los idiomas seleccionados
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga el diccionario para los idiomas activos
- (void) LoadDictionary
  {
  [_WaitForDict startAnimation:self];

  int iDir = DIRFromLangs( LGSrc, LGDes );                    // Toma la dirección actual
  [_CbLangs selectItemWithTag:iDir];                          // La selecciona en combo

  // Guarda dirección seleccionada en los datos del usuario
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  [UserDef setObject:[NSNumber numberWithInt:iDir] forKey:@"lastDir"];

  [DictMain    LoadWithSrc:LGSrc AndDes:LGDes ];
  [DictIndexes LoadWithSrc:LGSrc AndDes:LGDes ];

  [self SetTitle];
  [self FindFrases];

  [_WaitForDict stopAnimation:self];
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

  [Ctrller DisenableBtns:All_BTNS];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Borra la entrada seleccionada
- (IBAction)DelEntry:(NSButton *)sender
  {
  [_ZonaDatos DeleteSelectedDatos];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Copia al portapapeles el texto seleccionado o el texto traducido
- (IBAction)CopyTrd:(NSButton *)sender
  {
  DatosView* sel = ZoneDatosView.SelectedDatos;
  if( sel==nil ) return;
  
  [sel CopyText];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Intercambia la fuente y origen del diccionario
- (IBAction)OnSwapDict:(MyButton *)sender
  {
  int tmp = LGDes;
  LGDes   = LGSrc;
  LGSrc   = tmp;

  [self LoadDictionary];                                    // Carga el diccionario para los idiomas seleccionados
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

    [self ShowMsg:@"NoVerbInQuery" WithTitle:@"TitleConj"];
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
// Se llama para conjugar una palabra en la vista de datos
- (IBAction)OnConjWord:(MyButton *)sender
  {
  DatosView* selDatos = [ZoneDatosView SelectedDatos];

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
- (IBAction)OnTrdWord:(MyButton *)sender
  {
  [_WaitFind startAnimation:self];

  DatosView* selDatos = [ZoneDatosView SelectedDatos];

  int src = selDatos.src;
  int des = selDatos.des;

  _btnTrdWrd.title = @"";
  _btnTrdWrd.enabled = FALSE;
  
  int lang;
  NSString* selWrd = [selDatos getSelWordAndLang:&lang];
  if( lang==des )
    {
    if( ![self GetViewDataForWord:selWrd Src:des Des:src] )
      {
      NSString* rootWrd = [ConjCore FindRootWord:selWrd Lang:des];
      
      if( ![self GetViewDataForWord:rootWrd Src:des Des:src] )
        {
        [self ShowMsg:@"NoFindWrd" WithTitle:@"TitleFindMeans"];
        _btnTrdWrd.enabled = TRUE;
        }
      }
    }

  [_WaitFind stopAnimation:self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca el la palabra en el diccionario y agrega una vista con sus datos
- (BOOL) GetViewDataForWord:(NSString*) sWord Src:(int)src Des:(int)des
  {
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
// Se llama para conecer la palabra que se corresponde con la fila 'row'
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
// Habilita los botones especificados en 'sw'
- (void) EnableBtns:(int) sw
  {
  if( sw & DEL_ALL   ) _btnDelAllDatos.enabled = TRUE;
  if( sw & DEL_SEL   ) _btnDelSelDato.enabled  = TRUE;
  if( sw & COPY_TEXT ) _btnCopyTrd.enabled     = TRUE;
  if( sw & CONJ_WRD  ) _btnConjWrd.enabled     = TRUE;
  if( sw & TRD_WRD   )
    {
    int lng = [ZoneDatosView SelectedDatos].src;
    _btnTrdWrd.title = LGFlag(lng);                                 // Pone la bandera del idioma
    _btnTrdWrd.enabled = TRUE;
    }
  
  [_btnConjWrd.window invalidateCursorRectsForView:_btnConjWrd];
  }
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Deshabilita los botones especificados en 'sw'
- (void) DisenableBtns:(int) sw
  {
  if( sw & DEL_ALL   ) _btnDelAllDatos.enabled = FALSE;
  if( sw & DEL_SEL   ) _btnDelSelDato.enabled  = FALSE;
  if( sw & COPY_TEXT ) _btnCopyTrd.enabled     = FALSE;
  if( sw & CONJ_WRD  ) _btnConjWrd.enabled     = FALSE;
  if( sw & TRD_WRD   )
    {
    _btnTrdWrd.title = @"";
    _btnTrdWrd.enabled   = FALSE;
    }
  
  [_btnConjWrd.window invalidateCursorRectsForView:_btnConjWrd];
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

- (IBAction)OnShowCojugator:(MyButton *)sender;
  {
  [self performSegueWithIdentifier:@"Conjugator" sender:self];
  }

- (IBAction)OnShowAvancedFind:(MyButton *)sender;
  {
  [self performSegueWithIdentifier:@"FindPlus" sender:self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama antes de llamar otro viewController validar si se debe mostrar
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
  {
  if( [identifier isEqualToString:@"FindPlus"] && _txtFrase.stringValue.length==0 )
    {
    [self ShowMsg:@"NoStringFind" WithTitle:@"TitleFindPlus"];
    return FALSE;
    }

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

  }
  
@end
//===================================================================================================================================================
