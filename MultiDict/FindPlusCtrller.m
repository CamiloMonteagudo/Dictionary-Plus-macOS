//===================================================================================================================================================
//  FindPlusCtrller.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 7/30/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import "FindPlusCtrller.h"
#import "TextQueryPlus.h"
#import "AppData.h"
#import "ConjCore.h"

//===================================================================================================================================================
@interface FindPlusCtrller ()
  {
  TextQueryPlus *Query;
  NSMutableArray<NSString*> *Words;
  BOOL InSel;
  }

@property (unsafe_unretained) IBOutlet NSTextView *txtQuery;
@property (weak) IBOutlet NSBox *boxDatos;

@property (weak) IBOutlet NSTableView *SinonTable;
@property (weak) IBOutlet NSTextField *ConjVerb;
@property (weak) IBOutlet NSTextField *NewWord;
@property (weak) IBOutlet NSButton *btnDelWords;
@property (weak) IBOutlet NSButton *btnAddWord;
@property (weak) IBOutlet NSButton *btnAddVeb;
@property (weak) IBOutlet NSTextField *lbAddWord;
@property (weak) IBOutlet NSTextField *lbAddVerb;

@property (weak) IBOutlet NSButton *FindAllWords;
@property (weak) IBOutlet NSButton *FindSamesWord;

- (IBAction)OnNextWord:(NSButton *)sender;
- (IBAction)OnPrevWord:(NSButton *)sender;
- (IBAction)OnDelSelected:(NSButton *)sender;
- (IBAction)OnAddConjs:(NSButton *)sender;
- (IBAction)OnAddNewWord:(NSButton *)sender;
- (IBAction)OnAplayQuery:(NSButton *)sender;
- (IBAction)OnReturnNewWord:(NSTextField *)sender;
- (IBAction)OnReturnVerb:(id)sender;
- (IBAction)OnActiveDatos:(NSButton *)sender;

@end

//===================================================================================================================================================
@implementation FindPlusCtrller

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
  {
  Words = [NSMutableArray new];

  [super viewDidLoad];

  _txtQuery.string =  _FindText;

  Query = [TextQueryPlus QueryWithText: _FindText ];                // Obtiene el query

  [self SelWord];

  [self.view.window makeFirstResponder:_NewWord ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnNextWord:(NSButton *)sender
  {
  if( Query->idxSel+1 < Query->Items.count ) ++Query->idxSel;
  else                                         Query->idxSel = 0;

  [self SelWord];                                       // Selecciona la palabra en el query
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnPrevWord:(NSButton *)sender
  {
  if( Query->idxSel-1 >= 0 ) --Query->idxSel;
  else                         Query->idxSel = Query->Items.count-1;

  [self SelWord];                                       // Selecciona la palabra en el query
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnDelSelected:(NSButton *)sender
  {
  [_SinonTable.selectedRowIndexes enumerateIndexesWithOptions:NSEnumerationReverse
                                                   usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop)
                                                        {
                                                        if( idx != 0 )
                                                          [Words removeObjectAtIndex:idx];
                                                        }];

  [_SinonTable reloadData];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir return en la edicción de un verbo
- (IBAction)OnReturnVerb:(id)sender
  {
  [self OnAddConjs:sender];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se activa/desactiva la sección de datos
- (IBAction)OnActiveDatos:(NSButton *)sender
  {
  _boxDatos.hidden = (_FindSamesWord.state != NSOnState );
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se al dar click sobre el botón para adicionar una nueva conjugación
- (IBAction)OnAddConjs:(NSButton *)sender
  {
  [ConjCore LoadConjLang: LGSrc];                           // Carga la conjugación para el idioma actual

  NSString* Verb = _ConjVerb.stringValue;

  if( [ConjCore ConjVerb:Verb ] )                              // Si la palabra se puede conjugar
    {
    NSArray<NSString*> * Wrds = [ConjCore GetConjsList];      // Obtiene la lista de palabras de la conjugacion

    for (NSString* wrd in Wrds)
      {
      if( ![Words containsObject:wrd] && [wrd characterAtIndex:0]!= '-' )
        [Words addObject:wrd];
      }

    [_SinonTable reloadData];
    _ConjVerb.stringValue = @"";
    }
  else
    {
    [self ShowMsg:@"WordNoVerb" WithTitle:@"TitleFindPlus"];
    [self.view.window makeFirstResponder:_ConjVerb ];
    }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama al oprimir return en la edicción de una palabra nueva
- (IBAction)OnReturnNewWord:(NSTextField *)sender
  {
  [self OnAddNewWord:nil];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se al dar click sobre el botón para adicionar una nueva palabra
- (IBAction)OnAddNewWord:(NSButton *)sender
  {
  NSString* Wrd = _NewWord.stringValue;
  if( Wrd.length == 0 )
    {
    [self ShowMsg:@"WriteNewWord" WithTitle:@"TitleFindPlus"];
    }
  else if( [Words containsObject:Wrd] )
    {
    [self ShowMsg:@"WordExist" WithTitle:@"TitleFindPlus"];
    }
  else
    {
    [Words addObject:Wrd];
    [_SinonTable reloadData];
    _NewWord.stringValue = @"";
    }

  [self.view.window makeFirstResponder:_NewWord ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)OnAplayQuery:(NSButton *)sender
  {
  int sw = 0;
  if( _FindAllWords.state == NSOnState ) sw |= FULL_FRASE;

  TextQueryPlus *RetQuery = Query;

  if( _FindSamesWord.state != NSOnState )
    {
    NSString *sQuery = [_FindText lowercaseString];                 // Lleva todas las palabras a minusculas
    RetQuery = [TextQueryPlus QuerySimpleWithText:sQuery ];         // Obtiene el query
    }

  [Ctrller FindFrasesWithQuery:RetQuery Options:sw];
  Ctrller.txtFrase.stringValue = _txtQuery.string;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca la palabra actual y la selecciona
- (void) SelWord
  {
  NSInteger idx = Query->idxSel;
  if( idx<0 || idx>=Query->Items.count )
    {
    [self clearList];
    return;
    }

  WrdQuery *wrdQ = Query->Items[idx];

  InSel = TRUE;
  _txtQuery.selectedRange = wrdQ->Pos;
  InSel = FALSE;

//  _boxDatos.hidden = false;
  [self DatosEnabled:TRUE];

  Words = wrdQ->Words;
  [_SinonTable reloadData];

  NSString *Verb = [ConjCore VerbInfinitive:Words[0] Lang:LGSrc];
  if( Verb.length > 0 )
    _ConjVerb.stringValue = Verb;
  else
    _ConjVerb.stringValue = @"";

//  [self.view.window makeFirstResponder:_NewWord ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Informa la cantidad de palabras resultado de la conjugación
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
  {
  _btnDelWords.hidden = TRUE;

  return Words.count;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para conecer la palabra que se corresponde con la fila 'row'
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
  {
  NSTableCellView* cel = [tableView makeViewWithIdentifier:@"WrdQuery" owner:tableView];

  cel.textField.stringValue = Words[row];

  return cel;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia la selección
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
  {
  NSInteger n = _SinonTable.selectedRowIndexes.count;

  if( n > 0 )
    {
    NSInteger idx0 = [_SinonTable.selectedRowIndexes firstIndex];

    if( n==1 && idx0==0 ) _btnDelWords.hidden = TRUE;
    else                  _btnDelWords.hidden = FALSE;
    }
  else                    _btnDelWords.hidden = TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada vez que cambia la selección del texto
- (void)textViewDidChangeSelection:(NSNotification *)notification
  {
  if( InSel ) return;

  NSTextView* NowText = notification.object;                  // Toma el texto donde cambio la selección

  Query = [TextQueryPlus QueryWithText:NowText.string];       // Reanaliza la consulta

  NSRange range = NowText.selectedRange;                      // Obtiene el rango de caracteres seleccionados
  if( range.length == 0 )                                     // Si no se selecciono ningún caracter
    {
    if( Words.count!=0 ) [self clearList];                    // Si la lista de palabras similares no esta vacia
    return;                                                   // Termina
    }

  Query->idxSel = -1;                                         // Quita la selección
  for( int i=0; i<Query->Items.count; ++i )                   // Busca por todas las palabras de la consulta
    {
    WrdQuery *wrdQ = Query->Items[i];                         // Toma los datos de la palabra actual
    if( NSEqualRanges(wrdQ->Pos, range) )                     // Si el rango marcado es la palabra
      {
      Query->idxSel = i;                                      // La marca como seleccionada
      break;                                                  // Termina la busqueda
      }
    }

  [self SelWord];                                             // Selecciona la palabra en el query
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Limpia la lista de sinonimos
- (void) clearList
  {
  Words = [NSMutableArray new];                           // La pone en blanco
  [_SinonTable reloadData];                               // Manda a mostra la tabla vacia

//  _boxDatos.hidden = TRUE;
  [self DatosEnabled:FALSE];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Habilita/Desabilita la edicción de los datos
- (void) DatosEnabled:(BOOL) val
  {
  _SinonTable.enabled = val;
  _ConjVerb.enabled = val;
  _NewWord.enabled = val;
  _btnDelWords.enabled = val;
  _btnAddWord.enabled = val;
  _btnAddVeb.enabled = val;
  _lbAddWord.enabled = val;
  _lbAddVerb.enabled = val;
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


@end
//===================================================================================================================================================
