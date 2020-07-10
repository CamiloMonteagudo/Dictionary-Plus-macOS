 //=========================================================================================================================================================
//  ConjCtrller.m
//  TrdMac
//
//  Created by Camilo on 2/26/16.
//  Copyright (c) 2016 BigXSoft. All rights reserved.
//=========================================================================================================================================================

#import "ConjCtrller.h"
#import "AppData.h"
#import "ConjCore.h"

#define BY_WORDS   0
#define BY_MODES   1
#define BY_PERSONS 2

static NSArray<NSString*> *ModeIds = @[ @"ConjViewWords", @"ConjViewModes", @"ConjViewPersons" ];

//=========================================================================================================================================================
@interface ConjCtrller ()
  {
  int showMode;
  
  NSArray* CnjCells;

  NSString* IniVerb;
  int       IniLng;
  }

@property (weak) IBOutlet NSSearchField *cnjVerb;
@property (weak) IBOutlet NSTableView *lstConjs;
@property (weak) IBOutlet NSTextField *lbCnjMode;
@property (weak) IBOutlet NSTextField *CnjHdr;
@property (weak) IBOutlet NSButton *btnCnjMode;

- (IBAction)OnChangeConj:(NSSearchField *)sender;
- (IBAction)OnChangeShowMode:(id)sender;

@end

//=========================================================================================================================================================
@implementation ConjCtrller

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama después de haber cargado la vista
- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  [self setShowMode:BY_MODES];

  self.ConjLang = IniLng;
  self.Verb = IniVerb;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambio de la propiedad que establece el verbo actual
- (void)setVerb:(NSString *)Verb
 {
 IniVerb = Verb;
 if( Verb!=nil && _cnjVerb.stringValue != Verb )
   {
   _cnjVerb.stringValue = Verb;
   [self ConjugateVerbAlways:NO];
   }
 }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Propiedad que retorna el verbo actual
- (NSString *)Verb
  {
  return _cnjVerb.stringValue;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada ves que se cambia el verbo manualmente
- (IBAction)OnChangeConj:(NSSearchField *)sender
  {
  [self ConjugateVerbAlways:NO];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambia el idioma de la conjugación
- (void)setConjLang:(int)ConjLang
  {
  IniLng = ConjLang;
  NSSearchFieldCell* cell = _cnjVerb.cell;                      // Obtiene la celda del campo de buscar conjugaciones

  _ConjLang = ConjLang;                                         // Cambia idioma actual para aconjugaciones

  [cell resetSearchButtonCell];                                 // Reaestablece sus valores

  NSButtonCell *btn = cell.searchButtonCell;                    // Obtiene el boton para icono de buscar

  btn.type = NSTextCellType;                                    // Lo pone del tipo texto
  btn.imagePosition = NSNoImage;                                // No tiene imagenes

  btn.title = LGFlag(ConjLang);                                 // Pone la bandera del idioma
  btn.tag   = ConjLang;                                         // Pone una etiqueta del idioma al boton

  btn.target = self;                                            // Pone metodo a ejecutar cuando se hace click sobre él
  btn.action = @selector(OnSelConjLang:);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama oprime el la bandera que aparece en el campo de encontrar conjugaciones
- (void)OnSelConjLang:(id) sender
  {
  NSMenu* Mnu = [[NSMenu alloc] init];                                  // Crea el menu
  [Mnu addItem: [NSMenuItem separatorItem]];                            // Para Pulls Down menu, el primer item se ignora

  for( int i=0; i<CNJCount(); ++i )                                     // Recorre todas las conjugaciones instaladas
    {
    NSMenuItem* Item = [[NSMenuItem alloc] init ];                      // Crea un item de menu

    Item.title  = CNJTitle(i);                                          // Pone el nombre del items
    Item.target = self;                                                 // Pone objeto donde se atiende la accion
    Item.action = @selector(OnSelectLang:);                             // Pone procedimiento para atender la accion
    Item.tag = i;                                                       // Marca el item con el idioma que representa

    if( CNJLang(i)==_ConjLang ) [Item setState:1];                      // Si es el idioma actual le pone un checkmark

    [Mnu addItem:Item];                                                 // Adiciona el item al menu
    }

  NSPopUpButtonCell* cel = [[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:YES];    // Crea un PopUp
  cel.menu = Mnu;                                                                         // La asocia el menú

  NSSize szBtn = _cnjVerb.frame.size;
  NSRect rc = NSMakeRect(0, 0, 120, szBtn.height);              // Calcula la ubicación

  [cel performClickWithFrame:rc inView:_cnjVerb];                        // Lo manda a mostrar
 }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se selecciona un idioma
- (void)OnSelectLang:(NSMenuItem*) Item
  {
  self.ConjLang = CNJLang((int)Item.tag);

  [self ConjugateVerbAlways:NO];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se oprime el boton para cambiar el modo de mostrar las conjugaciones
- (IBAction)OnChangeShowMode:(id)sender
  {
  NSMenu* Mnu = [[NSMenu alloc] init];                                  // Crea el menu
  [Mnu addItem: [NSMenuItem separatorItem]];                            // Para Pulls Down menu, el primer item se ignora

  for( int i=0; i<ModeIds.count; ++i )                                  // Recorre todos los modos definidos
    {
    NSMenuItem* Item = [[NSMenuItem alloc] init ];                      // Crea un item de menu

    Item.title  = NSLocalizedString(ModeIds[i], @"");                   // Pone el nombre del items
    Item.target = self;                                                 // Pone objeto donde se atiende la accion
    Item.action = @selector(OnSelShowMode:);                            // Pone procedimiento para atender la accion
    Item.tag = i;                                                       // Marca el item con el modo que representa

    if( i==showMode ) [Item setState:1];                                // Si es el modo actual le pone un checkmark

    [Mnu addItem:Item];                                                 // Adiciona el item al menu
    }

  NSPopUpButtonCell* cel = [[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:YES];    // Crea un PopUp
  cel.menu = Mnu;                                                                         // La asocia el menú

  NSSize szBtn = _btnCnjMode.frame.size;
  NSRect rc = NSMakeRect(0, 0, 150, szBtn.height);                      // Calcula la ubicación

  [cel performClickWithFrame:rc inView:_btnCnjMode];                    // Lo manda a mostrar
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambia el modo como se van a mostrar los datos
- (void) setShowMode:(int) mode
  {
  if( mode<0 || mode>=ModeIds.count ) return;

  showMode = mode;

  NSString* sLabel =  NSLocalizedString(@"ConjLabel", @"");
  NSString* sMode  =  NSLocalizedString(ModeIds[mode], @"");

  _lbCnjMode.stringValue = [NSString stringWithFormat:@"%@ (%@)", sLabel, sMode ];

  CnjCells = nil;
  [_lstConjs reloadData];

  if( [ConjCore IsLastConjOk] )                           // Si la última conjugación fue correcta
    [self UpdateConjugate];                               // Actualiza los datos de la conjución
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se selecciona un modo para mostrar los datos
- (void)OnSelShowMode:(NSMenuItem*) Item
  {
  [self setShowMode:(int)Item.tag];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Conjuga el verbo actual
- (void) ConjugateVerbAlways:(BOOL) alway
  {
  if( [ConjCore nowLang] != _ConjLang )                         // Si cambio el idioma de conjugación
    [ConjCore LoadConjLang:_ConjLang];                          // Carga la conjugacion para el idiom actual

  NSString* sVerb = _cnjVerb.stringValue;                       // Toma el contenido del editor
  
  BOOL IsVerb = [ConjCore IsVerbWord:sVerb InLang:_ConjLang];   // Determina si el texto es un verbo o alguna conjugación
  
  if( IsVerb || alway) [self ConjugateVerb:sVerb];
  else                 [self ClearConjData];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Conjuga la palabra actual
- (void)ConjugateVerb:(NSString*) sVerb
  {
  if( [ConjCore ConjVerb:sVerb] )                          // Si se puedo obtener las conjugaciones
    [self UpdateConjugate];                                // Actualiza los datos de la conjución
  else                                                     // No se puedo obtener las conjugaciones
    [self ClearConjData];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita los datos de las conjugaciones
- (void) ClearConjData
  {
  _CnjHdr.stringValue = @"";
  
  CnjCells = nil;
  [_lstConjs reloadData];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Actualiza el listado de conjugaciones, según el modo vigente
- (void) UpdateConjugate
  {
  if( showMode == BY_WORDS )
    {
    CnjCells = [ConjCore GetConjsByWord];
    CnjCells = [ConjCore SortByConjList:CnjCells];
    }
  else if( showMode == BY_MODES )
    {
    CnjCells = [ConjCore GetConjsByMode];
    }
  else if( showMode == BY_PERSONS )
    {
    CnjCells = [ConjCore GetConjsByPersons];
    }
  else return;
  
  _CnjHdr.attributedStringValue = [ConjCore GetConjHeaderInMode:showMode];
  
  float h = ConjCore.HMax;
  
  _lstConjs.rowHeight = (h>15)? h:15;
  [_lstConjs reloadData];
  }


//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para saber el número de palabras de la lista de palabras del diccionario
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
  {
  if( CnjCells==nil ) return 0;
  
  return CnjCells.count;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para conecer la palabra que se corresponde con la fila 'row'
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
  {
  NSTableCellView* cel = [tableView makeViewWithIdentifier:@"ConjWrd" owner:tableView];
  
  ConjAndTxt* data = CnjCells[row];                                // Obtiene los datos

  cel.textField.attributedStringValue = data.AttrText;
  
  return cel;
  }

//- (NSView *)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
//  {
//  
//  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia la selección de la palabra actual en la lista de palabras del diccionario
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
  {
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end

//=========================================================================================================================================================
