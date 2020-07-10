//===================================================================================================================================================
//  MarkView.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 6/30/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import "MarkView.h"
#import "MngMarks.h"
#import "AppData.h"
#import "DatosView.h"
#import "FindMeans.h"

#define WCOMBO      100
#define WPOPUP      120
#define WFIELDTXT   100
#define WFIELDNUM    50
#define WSTEP        19

#define HINPUT       22

//===================================================================================================================================================
@interface MarkView()
  {
  DatosView* box;                                   // Cuadro que enecierra todos los datos de la llave
  NSString* mrkCode;                                // Código de la marca que la vista representa
  MarkNum*  numMak;

  NSString* KeyTxt;                                 // Texto de la marca de sustitución para la llave
  NSString* DatTxt;                                 // Texto de la marca de sustitución para los datos

  NSTextField* TxtSrc;
  NSTextField* TxtDes;
  NSStepper*   Stepper;
  NSComboBox*  Combo;
  MyButton* FindTrdBtn;

  int Src;
  int Des;
  }

@end

//===================================================================================================================================================
// Implementa la creacion de vistas para mostrar y cambiar las marcas
@implementation MarkView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea una vista con todos los controles necesarios para modificar la marca
+(MarkView*) CreateWithMark:(NSString*) code MarkNum:(MarkNum*) mk InView:(DatosView*) parent
  {
  MarkView* view = [[MarkView alloc] init];

  view->mrkCode = code;
  view->box     = parent;
  view->numMak  = mk;

  [view AddControls];

  return view;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona todo los controles necesarios a la vista de acuero al tipo de marca a editar
-(void) AddControls
  {
  Src = box.src;
  Des = box.des;

  KeyTxt = [box TextInKeyForMark:mrkCode];
  DatTxt = [box TextInDataForMark:mrkCode];

  CGFloat x = [self CreateMarkTitle];

       if( [mrkCode hasPrefix:@"NM"] ) x = [self GetNameMesInPos: x];
  else if( [mrkCode hasPrefix:@"NN"] ) x = [self GetNumberInPos: x];
  else if( [mrkCode hasPrefix:@"NP"] ) x = [self GetNamePersonInPos: x];
  else if( [mrkCode hasPrefix:@"NL"] ) x = [self GetNameLangInPos: x];
  else if( [mrkCode hasPrefix:@"NS"] ) x = [self GetNameWeekInPos: x];
  else if( [mrkCode hasPrefix:@"DD"] ) x = [self GetStringInPos: x];
  else if( [mrkCode hasPrefix:@"LL"] ) x = [self GetNumRomInPos: x];
  else if( [mrkCode hasPrefix:@"GY"] ) x = [self GetNameYearInPos: x];
  else if( [mrkCode hasPrefix:@"CD"] ) x = [self GetMonyCountInPos: x];
  else if( [mrkCode hasPrefix:@"WD"] ) x = [self GetStringInPos: x];
  else if( [mrkCode hasPrefix:@"HR"] ) x = [self GetHourInPos: x];
//  else if( [mrkCode hasPrefix:@"LN"] ) x = [self GetSiteInPos: x];
  else if( [mrkCode hasPrefix:@"PN"] ) x = [self GetApellidoInPos: x];
  else if( [mrkCode hasPrefix:@"FC"] ) x = [self GetFechaInPos: x];
  else if( [mrkCode hasPrefix:@"CS"] ) x = [self GetNumberInPos: x];
  else if( [mrkCode hasPrefix:@"NA"] ) x = [self GetStringInPos: x];
  else if( [mrkCode hasPrefix:@"NO"] ) x = [self GetStringInPos: x];
  else                                 x = [self GetStringInPos: x];

  self.frame = NSMakeRect(0, 0, x, HSUST_DATA);
  }

//===================================================================================================================================================
// Permite mostrar y cambiar un número
-(CGFloat) GetNumberInPos:(CGFloat) x
  {
  TxtSrc = [self CreateFieldText:KeyTxt InXPos:x AndWidth:WFIELDNUM ];
  TxtSrc.action = @selector(OnChangeNumber:);

  [self CreateStepperInXPos: x+WFIELDNUM IniVal:TxtSrc.intValue ];
  Stepper.action = @selector(OnStep:);

  return x + WFIELDNUM + WSTEP;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada vez que se oprime le stepper para incementar o decrementar un valor
- (void)OnChangeNumber:(NSTextField*)sender
  {
  NSString* sSrc = TxtSrc.stringValue;
  NSString* sDes = sSrc;

  Stepper.intValue = TxtSrc.intValue;

  [box ResplaceMark:mrkCode TextSrc:sSrc TextDes:sDes ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada vez que se oprime le stepper para incementar o decrementar un valor
- (void)OnStep:(NSStepper*)sender
  {

  TxtSrc.intValue = sender.intValue;
  [self OnChangeNumber:TxtSrc];
  }

//===================================================================================================================================================
NSArray<NSString*> *MesesEs = @[@"Enero"  , @"Febrero" , @"Marzo", @"Abrir" , @"Mayo"  , @"Junio" , @"Julio"  , @"Agosto", @"Septiembre", @"Octubre", @"Noviembre", @"Diciembre"];
NSArray<NSString*> *MesesEn = @[@"January", @"February", @"March", @"April" , @"May"   , @"June"  , @"July"   , @"August", @"September" , @"October", @"November" , @"December" ];
NSArray<NSString*> *MesesIt = @[@"Gennaio", @"Febbraio", @"Marzo", @"Aprile", @"Maggio", @"Giugno", @"Juglio" , @"Agosto", @"Settembre" , @"Ottobre", @"Novembre" , @"Dicembre" ];
NSArray<NSString*> *MesesFr = @[@"Janvier", @"Février" , @"Marzs", @"Abvril", @"Mai"   , @"Juin"  , @"Juillet", @"Août"  , @"Septembre" , @"Octobre", @"Novembre" , @"Décembre" ];

NSArray<NSString*> *Meses[] = {MesesEs, MesesEn, MesesIt, MesesFr};

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Permite obtener el nombre de un mes
-(CGFloat) GetNameMesInPos:(CGFloat) x
  {
  NSPopUpButton* PopUp = [self CreatePopUpX:x Width:WPOPUP Items:Meses[Src] AndSel:KeyTxt];

  PopUp.action = @selector(OnChangeMes:);

  return x + WPOPUP;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cambia un mes en el PopUp
- (void)OnChangeMes:(NSPopUpButton*)sender
  {
  NSInteger idx = sender.indexOfSelectedItem;

  NSString* sSrc = Meses[Src][idx];
  NSString* sDes = Meses[Des][idx];

  [box ResplaceMark:mrkCode TextSrc:sSrc TextDes:sDes ];
  }

//===================================================================================================================================================
// Crea dos campos de edicción para captar una cadena de texto en ambos idiomas
-(CGFloat) GetNamePersonInPos:(CGFloat) x
  {
  TxtSrc = [self CreateFieldText:KeyTxt InXPos:x AndWidth:WFIELDTXT ];
  TxtSrc.action = @selector(OnNPersonChaged:);

  x += WFIELDTXT + SEP;

  TxtDes = [self CreateFieldText:DatTxt InXPos:x AndWidth:WFIELDTXT ];
  TxtDes.action = @selector(OnNPersonChaged:);

  return x + WFIELDTXT;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia el texto de un cuadro de texto
- (void)OnNPersonChaged:(id)sender
  {
  NSString* sSrc = TxtSrc.stringValue;

  if( sender==TxtSrc ) TxtDes.stringValue = sSrc;

  NSString* sDes = TxtDes.stringValue;

  [box ResplaceMark:mrkCode TextSrc:sSrc TextDes:sDes ];
  }

//===================================================================================================================================================
NSArray<NSString*> *LangsEs = @[@"Español" , @"Inglés" , @"Francés" , @"Italiano", @"Alemán"  , @"Portugués"  , @"Japonés"   , @"Chino"   , @"Arabe" , @"Ruso"   , @"Catalán" , @"Castellano"  , @"Latin"  ];
NSArray<NSString*> *LangsEn = @[@"Spanish" , @"English", @"French"  , @"Italian" , @"German"  , @"Portuguese" , @"Japanese"  , @"Chinese" , @"Arabic", @"Russian", @"Catalan" , @"Castilian"   , @"Latin"  ];
NSArray<NSString*> *LangsIt = @[@"Spagnolo", @"Inglese", @"Francese", @"Italiano", @"Tedesco" , @"Portogghese", @"Giapponese", @"Cinese"  , @"Arabo" , @"Russo"  , @"Catalano", @"Castigliano" , @"Latino" ];
NSArray<NSString*> *LangsFr = @[@"Espagnol", @"Anglais", @"Français", @"Italien" , @"Allemand", @"Portugais"  , @"Japonais"  , @"Chinoise", @"Arabe" , @"Russe"  , @"Catalan" , @"Castillan"   , @"Latine" ];

NSArray<NSString*> *Langs[] = {LangsEs, LangsEn, LangsIt, LangsFr};
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone la interface para cambiar los idiomas
-(CGFloat) GetNameLangInPos:(CGFloat) x
  {
  Combo = [self CreateComboX:x Width:WCOMBO Items:Langs[Src] AndSel:KeyTxt];
  Combo.action = @selector(OnChangeLangs:);

  x += WCOMBO;

  TxtDes = [self CreateFieldText:DatTxt InXPos:x AndWidth:WFIELDTXT ];
  TxtDes.action = @selector(OnDesLangChaged:);
  
  return x + WFIELDTXT;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cambia un mes en el PopUp
- (void)OnChangeLangs:(NSComboBox*)sender
  {
  NSInteger idx = sender.indexOfSelectedItem;
  if( idx!=-1 )
    TxtDes.stringValue = Langs[Des][idx];

  [self OnDesLangChaged:TxtSrc ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cambia un mes en el PopUp
- (void)OnDesLangChaged:(NSTextField*)sender
  {
  NSString* sSrc = Combo.stringValue;
  NSString* sDes = TxtDes.stringValue;

  [box ResplaceMark:mrkCode TextSrc:sSrc TextDes:sDes ];
  }

//===================================================================================================================================================
NSArray<NSString*> *DiasEs = @[@"Lunes" , @"Martes" , @"Miércoles", @"Jueves"  , @"Viernes" , @"Sábado"  , @"Domingo" ];
NSArray<NSString*> *DiasEn = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday"  , @"Saturday", @"Sunday"  ];
NSArray<NSString*> *DiasIt = @[@"Lunedì", @"Martedì", @"Mercoledì", @"Giovedí" , @"Venerdì" , @"Sabato"  , @"Domenica"];
NSArray<NSString*> *DiasFr = @[@"Lundi" , @"Mandi"  , @"Mercredi" , @"Jeudi"   , @"Vendredi", @"Samedi"  , @"Dimanche"];

NSArray<NSString*> *Dias[] = {DiasEs, DiasEn, DiasIt, DiasFr};
//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone interface para cambiar el dia de la semana
-(CGFloat) GetNameWeekInPos:(CGFloat) x
  {
  NSPopUpButton* PopUp = [self CreatePopUpX:x Width:WPOPUP Items:Dias[Src] AndSel:KeyTxt];

  PopUp.action = @selector(OnChangeDia:);

  return x + WPOPUP;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cambia un mes en el PopUp
- (void)OnChangeDia:(NSPopUpButton*)sender
  {
  NSInteger idx = sender.indexOfSelectedItem;

  NSString* sSrc = Dias[Src][idx];
  NSString* sDes = Dias[Des][idx];

  [box ResplaceMark:mrkCode TextSrc:sSrc TextDes:sDes ];
  }

////===================================================================================================================================================
////
//-(CGFloat) GetAdverbioInPos:(CGFloat) x
//  {
//  return x + 50;
//  }

//===================================================================================================================================================
NSArray<NSString*> *NumsRom = @[@"I", @"II", @"III", @"IV", @"V", @"VI", @"VII", @"VII", @"IX", @"X", @"XV", @"XX", @"XXX",
                               @"XL", @"L", @"C", @"D", @"M", @"MMXVII", @"MMXVIII", @"MMXVIV", @"MMXX"];
// Pone interface para cambiar los números romanos
-(CGFloat) GetNumRomInPos:(CGFloat) x
  {
  Combo = [self CreateComboX:x Width:WCOMBO Items:NumsRom AndSel:KeyTxt];
  Combo.action = @selector(OnChangeNumRom:);

  return x + WCOMBO;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cambia le número en el PopUp
- (void)OnChangeNumRom:(NSComboBox*)sender
  {
  NSString* sSrc = Combo.stringValue;
  NSString* sDes = sSrc;

  [box ResplaceMark:mrkCode TextSrc:sSrc TextDes:sDes ];
  }

//===================================================================================================================================================
NSArray<NSString*> *Years = @[@"1980", @"1990", @"2000", @"2005", @"2010", @"2015", @"2016", @"2017", @"2018", @"2019", @"2020", @"2025", @"2030", @"2035", @"2040", @"2045", @"2050"];
// Pone la interfase para cambiar el año
-(CGFloat) GetNameYearInPos:(CGFloat) x
  {
  Combo = [self CreateComboX:x Width:WCOMBO Items:Years AndSel:KeyTxt];
  Combo.action = @selector(OnChangeYear:);

  [self CreateStepperInXPos: x+WCOMBO IniVal:Combo.intValue];
  Stepper.action = @selector(OnStepYear:);

  return x + WCOMBO + WSTEP;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se cambia el año en el PopUp
- (void)OnChangeYear:(NSComboBox*)sender
  {
  NSString* sSrc = Combo.stringValue;
  NSString* sDes = sSrc;

  Stepper.intValue = Combo.intValue;

  [box ResplaceMark:mrkCode TextSrc:sSrc TextDes:sDes ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cada vez que se oprime le stepper para incementar o decrementar un valor
- (void)OnStepYear:(NSStepper*)sender
  {
  Combo.stringValue = sender.stringValue;
  [self OnChangeYear:Combo];
  }

//===================================================================================================================================================
//
-(CGFloat) GetMonyCountInPos:(CGFloat) x
  {
  TxtSrc = [self CreateFieldText:KeyTxt InXPos:x AndWidth:WFIELDTXT ];
  TxtSrc.action = @selector(OnNameChaged:);

  return x + WFIELDTXT;
  }

////===================================================================================================================================================
////
//-(CGFloat) GetWordInPos:(CGFloat) x
//  {
//  return x + 50;
//  }
//
//===================================================================================================================================================
//
-(CGFloat) GetHourInPos:(CGFloat) x
  {
  TxtSrc = [self CreateFieldText:KeyTxt InXPos:x AndWidth:WFIELDTXT ];
  TxtSrc.action = @selector(OnNameChaged:);

  return x + WFIELDTXT;
  }

//===================================================================================================================================================
//
-(CGFloat) GetSiteInPos:(CGFloat) x
  {
  TxtSrc = [self CreateFieldText:KeyTxt InXPos:x AndWidth:WFIELDTXT ];
  TxtSrc.action = @selector(OnNameChaged:);

  return x + WFIELDTXT;
  }

//===================================================================================================================================================
//
-(CGFloat) GetApellidoInPos:(CGFloat) x
  {
  TxtSrc = [self CreateFieldText:KeyTxt InXPos:x AndWidth:WFIELDTXT ];
  TxtSrc.action = @selector(OnNameChaged:);

  return x + WFIELDTXT;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia el texto de un cuadro de texto
- (void)OnNameChaged:(id)sender
  {
  NSString* sSrc = TxtSrc.stringValue;
  NSString* sDes = sSrc;

  [box ResplaceMark:mrkCode TextSrc:sSrc TextDes:sDes ];
  }

//===================================================================================================================================================
//
-(CGFloat) GetFechaInPos:(CGFloat) x
  {
  NSRect frm = NSMakeRect(x,0, WFIELDTXT, HSUST_DATA );

  NSDatePicker* date = [[NSDatePicker alloc] initWithFrame:frm];
  date.bezeled = true;
  date.drawsBackground = true;
  date.font = [NSFont systemFontOfSize:12.5];
  date.cell.sendsActionOnEndEditing = YES;
  date.datePickerElements = NSYearMonthDayDatePickerElementFlag;
  date.backgroundColor = [NSColor whiteColor];

  [self addSubview:date];

  date.dateValue = [self DateFromString:KeyTxt ForLang:Src];

  date.target = self;
  date.action = @selector(OnDateChaged:);

  return x + WFIELDTXT;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia la fecha
- (void)OnDateChaged:(NSDatePicker*)sender
  {
  NSString* sSrc = [self FormatterDate:sender.dateValue ForLang:Src];
  NSString* sDes = [self FormatterDate:sender.dateValue ForLang:Des];

  [box ResplaceMark:mrkCode TextSrc:sSrc TextDes:sDes ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la cadena que representa una fecha de acuerdo al idioma
- (NSString*) FormatterDate:(NSDate*) date ForLang:(int) lang
  {
  NSDateFormatter* frm = [NSDateFormatter new];

  if( lang == 0 ) [frm setDateFormat:@"dd-MM-yyyy"];
  else            [frm setDateFormat:@"MM-dd-yyyy"];

  return [frm stringFromDate: date];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene un dato fecha desde una cadena en un idioma dado
- (NSDate*) DateFromString:(NSString*) str ForLang:(int) lang
  {
  NSDateFormatter* frm = [NSDateFormatter new];

  if( lang == 0 ) [frm setDateFormat:@"dd-MM-yyyy"];
  else            [frm setDateFormat:@"MM-dd-yyyy"];

  return [frm dateFromString: str];
  }

//===================================================================================================================================================
//
//-(CGFloat) GetSizeInPos:(CGFloat) x
//  {
//  return x + 50;
//  }

////===================================================================================================================================================
////
//-(CGFloat) GetNameAnimalInPos:(CGFloat) x
//  {
//  return x + 50;
//  }
//
////===================================================================================================================================================
////
//-(CGFloat) GetNameObjectInPos:(CGFloat) x
//  {
//  return x + 50;
//  }
//

//===================================================================================================================================================
// Crea dos campos de edicción para captar una cadena de texto en ambos idiomas
-(CGFloat) GetStringInPos:(CGFloat) x
  {
  TxtSrc = [self CreateFieldText:KeyTxt InXPos:x AndWidth:WFIELDTXT ];
  TxtSrc.action = @selector(OnTextChaged:);

  x += WFIELDTXT + SEP;

  TxtDes = [self CreateFieldText:DatTxt InXPos:x AndWidth:WFIELDTXT ];
  TxtDes.action = @selector(OnTextChaged:);

  [self CreateFindTrdBtnInPos:x + WFIELDTXT];
  return x + WFIELDTXT + 30;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia el texto de un cuadro de texto
- (void)OnTextChaged:(id)sender
  {
  NSString* sSrc = TxtSrc.stringValue;
  NSString* sDes = TxtDes.stringValue;

  [box ResplaceMark:mrkCode TextSrc:sSrc TextDes:sDes ];
  }

//===================================================================================================================================================
// Crea un botón para buscar la tradicción en la posicion x
- (void) CreateFindTrdBtnInPos:(CGFloat) x
 {
  NSRect frm = NSMakeRect(x, 0, 17, 22 );                   // Rectangulo para los botones

  FindTrdBtn = [[MyButton alloc] initWithFrame:frm];

  FindTrdBtn.ButtonType = NSMomentaryPushInButton;
  FindTrdBtn.bordered = FALSE;
  FindTrdBtn.image = [NSImage imageNamed:@"TrdBtn"];

  FindTrdBtn.target = self;
  FindTrdBtn.action = @selector(OnFindMeans:);

  [self addSubview:FindTrdBtn];
 }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se oprime el boton de buscar significados
- (void)OnFindMeans:(id)sender
  {
  NSArray<NSString*> *Means;

  if( LGSrc!=Src || LGDes!=Des )
    {
    Means = @[TxtSrc.stringValue, NSLocalizedString(@"DictChaged", nil) ];
    }
  else
    {
    Means = FindMeansOf( TxtSrc.stringValue );

    if( Means.count == 0 )
      Means = @[TxtSrc.stringValue,  NSLocalizedString(@"NoInDict", nil) ];
    }

  [self CreateMenuMeans:Means];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un menu con todos los significados encontrados
- (void) CreateMenuMeans:(NSArray*) Items
  {
  NSMenu* Mnu = [[NSMenu alloc] init];                                  // Crea el menu
  [Mnu addItem: [NSMenuItem separatorItem]];                            // Para Pulls Down menu, el primer item se ignora

  for( int i=0; i<Items.count; ++i )                                    // Recorre todas las raices
    {
    NSMenuItem* Item = [[NSMenuItem alloc] init ];                      // Crea un item de menu

    Item.title  = Items[i];                                             // Le pone la raiz en item del menu

    if( [Items[i] characterAtIndex:0] != '*' )
      {
      Item.target = self;                                               // Pone objeto donde se atiende la accion
      Item.action = @selector(OnSelectMean:);                           // Pone procedimiento para atender la accion
      }
    else
      Item.enabled = FALSE;

    [Mnu addItem:Item];                                                 // Adiciona le item con la raiza al menu
    }

  [self ShowMenu:Mnu AtButton:FindTrdBtn];                              // Manda a poner el menu, debajo de bonton
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Muestra el menú 'Mnu' debajo del boton 'Bnt'
- (void)ShowMenu:(NSMenu*) Mnu AtButton:(NSView*) Bnt
  {
  NSPopUpButtonCell* cel = [[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:YES];
  cel.menu = Mnu;

  NSSize szBtn = Bnt.frame.size;
  NSRect rc = NSMakeRect(-Mnu.size.width+(2*szBtn.width), 0, szBtn.width, szBtn.height);

  [cel performClickWithFrame:rc inView:Bnt];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se selecciona mostrar una raiz de una palabra
- (void)OnSelectMean:(NSMenuItem*) Item
  {
  TxtDes.stringValue = Item.title;

  [self OnTextChaged:TxtDes];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------


//===================================================================================================================================================
// Crea un label con el titulo de la marca de sustitución
-(CGFloat) CreateMarkTitle
  {
  NSString* Title;
  MarkDatos* info = [[MngMarks Get] Info:mrkCode];
  if( info==nil ) Title = NSLocalizedString( @"SustWord", nil);
  else
    {
    NSString* locDesc = NSLocalizedString(info.Desc, nil);
    if( numMak.Count>1 )
      {
      NSString* sNum = [NSString stringWithFormat:@" %d", numMak.Now ];
      locDesc = [locDesc stringByAppendingString:sNum];
      
      ++numMak.Now;
      }
    
    Title = [locDesc stringByAppendingString:@": "];
    }

  NSTextField* lb = [[NSTextField alloc] init];
  lb.bordered = FALSE;
  lb.stringValue = Title;
  lb.editable = false;
  lb.drawsBackground = false;

  CGSize sz = CGSizeMake( 2000, 20 );
  CGFloat w = [lb.attributedStringValue boundingRectWithSize:sz options:0 context:nil].size.width+3;

  lb.frame = NSMakeRect(0, 0, w, 20);

  [self addSubview:lb];
  return w;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un combobox en una posición y con un tamaño dado
-(NSPopUpButton*) CreatePopUpX:(CGFloat) x Width:(CGFloat) w Items:(NSArray<NSString*>*) List AndSel:(NSString*) sSel
  {
  NSRect frm = NSMakeRect(x,0, w, HSUST_DATA );

  NSPopUpButton* popup = [[NSPopUpButton alloc] initWithFrame:frm];

  [popup addItemsWithTitles:List];

  int idx =[self IndexForStr:sSel In:List ];
  [popup selectItemAtIndex: idx];

  popup.target = self;

  [self addSubview:popup];

  return popup;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca la cadena 'mes' en el areglo 'Array' y retorna su indice, si no la encuantra retorna -1
-(int) IndexForStr:(NSString*) str In:(NSArray<NSString*>*) Array
 {
  str = [str lowercaseString];

  for( int i=0; i<Array.count; ++i )
    {
    NSString* item = [Array[i] lowercaseString];

    if( [item isEqualToString:str] )
      return i;
    }

  return -1;
 }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un combobox en una posición y con un tamaño dado
-(NSComboBox*) CreateComboX:(CGFloat) x Width:(CGFloat) w Items:(NSArray<NSString*>*) List AndSel:(NSString*) sSel
  {
  NSRect frm = NSMakeRect(x,0, w, HSUST_DATA );

  NSComboBox* combo = [[NSComboBox alloc] initWithFrame:frm];
  combo.buttonBordered = FALSE;
  combo.bordered = true;
  combo.font = [NSFont systemFontOfSize:13];
  combo.target = self;
  combo.cell.sendsActionOnEndEditing = YES;

  [self addSubview:combo];

  [combo addItemsWithObjectValues:List];

  int idx =[self IndexForStr:sSel In:List ];

  if( idx==-1 ) combo.stringValue = KeyTxt;
  else         [combo selectItemAtIndex: idx];
  
  return combo;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un campo del texto en una posición y con un tamaño dado
-(NSTextField*) CreateFieldText:(NSString*) txt InXPos:(CGFloat) x AndWidth:(CGFloat) w
  {
  NSRect frm = NSMakeRect(x,0, w, HINPUT );

  NSTextField* Text = [[NSTextField alloc] initWithFrame:frm];
  Text.stringValue = txt;

  Text.cell.usesSingleLineMode = TRUE;
  Text.cell.lineBreakMode = NSLineBreakByClipping;
  Text.cell.scrollable = TRUE;
  Text.cell.sendsActionOnEndEditing = YES;

  Text.target = self;                                       // Pone objeto para reportar las acciones

  [self addSubview:Text];

  return Text;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un stepper para cambiar el valor dado en 'TxtSrc'
-(void) CreateStepperInXPos:(CGFloat) x IniVal:(int) val
  {
  NSRect frm = NSMakeRect(x,0, WSTEP, HINPUT );

  Stepper = [[NSStepper alloc] initWithFrame:frm];

  Stepper.target = self;                                       // Pone objeto para reportar las acciones

  Stepper.maxValue = NSIntegerMax;
  Stepper.valueWraps = FALSE;
  Stepper.intValue = val;

  [self addSubview:Stepper];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja el fondo de la zona
//- (void)drawRect:(NSRect)dirtyRect
//  {
//  [super drawRect:dirtyRect];
//
//  NSRect rc = self.bounds;
//
//  [[NSColor redColor] set];
//  [[NSBezierPath bezierPathWithRoundedRect:rc xRadius:0 yRadius:0 ] fill];
//  }

@end

//===================================================================================================================================================
