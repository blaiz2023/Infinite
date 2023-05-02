unit infinite2;
//##############################################################################
//## Name......... Infinite
//## Type......... User Program
//## Desciption... Writing management system
//## Version...... 1.00.830
//## Date......... 02may2023
//## Lines........ 2,253
//## Copyright.... (c) 1997-2023 Blaiz Enterprises and www.BlaizEnterprises.com
//##############################################################################

interface

uses
{$ifdef D3}
   Windows, Forms, Controls, SysUtils, Classes, ShellApi, ShlObj, Graphics, Clipbrd,
   messages, math, extctrls{tpanel}, filectrl{tdrivetype}, ActiveX, ComObj, registry,
   gosscore, gossdat;
{$endif}
{$ifdef D10}
   System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
   FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.surfaces,
   system.dateutils, gosscore, gossdat;
{$endif}

type
{tdoceditor}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//eeeeeeeeeeeeeeeeeeeeeee
   tdoceditor=class;
   tdoccheck=procedure(xdoc:tdoceditor;xfilename:string) of object;
   tdoceditor=class(tbasiccols)
   private
    itimerAutosave,itimer100:comp;
    icansave,iloaded,ibuildingcontrol:boolean;
    inav:tbasicnav;
    inavtitle:tbasictitle;
    ilastfilename,ilastsyncREF,imustsetnavvalue,iextref,isettingsref:string;
    ilogbuffer:tstr8;
    //.edit support
    ilogbase:tbasicscroll;
    itexttitle:tbasictitle;
    itext,ilog:tbasicbwp;
    iimagelist,ilist:tbasicmenu;
    iimage:tbasiccontrol;
    isplit,irows,ishownav,ishowlog:boolean;
    imodifiedid,istyle,iscrollv_px,iscrollh,ipos,ipos2:longint;
    ic2pref,ic2pref_mask,inavref,ifilename,isyncref,iinforef:string;
    function getcore:pwordcore;
    function getcpos:longint;
    procedure xtextfont;//30dec2021
    procedure nav__showmenuFill(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
    function nav__showmenuClick(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
    function xcmd(sender:tobject;xcode:longint;xcode2:string):boolean;//true=handled
    procedure _ontimer(sender:tobject); override;
    function getbackup:boolean;
    procedure setbackup(x:boolean);
    procedure xresetAutosave;
    procedure xbackup_viaformatlevel(xfilename:string);
   public
    //vars
    xbutcap:string;//read by host
    xbuttep:longint;
    ondoccheck:tdoccheck;
    host:tobject;//optional
    //create
    constructor create(xparent:tobject); virtual;
    constructor create2(xparent:tobject;xstart:boolean); virtual;
    destructor destroy; override;
    //information
    property split:boolean read isplit write isplit;
    property style:longint read istyle write istyle;//0=no wrap, 1=wrap to window, 2=wrap to page, 3=wrap to page + 200% line spacing
    property rows:boolean read irows write irows;
    property shownav:boolean read ishownav write ishownav;
    property showlog:boolean read ishowlog write ishowlog;
    property backup:boolean read getbackup write setbackup;
    property core:pwordcore read getcore;
    property cpos:longint read getcpos;
    property _text:tbasicbwp read itext;//use with care
    property cansave:boolean read icansave;
    //edit support
    function popfav:string;
    procedure logclear;
    procedure logadd(x:string);
    function xnavvalue(xportable:boolean):string;
    procedure xsetnavvalue(x:string);
    function xnavfolder:string;
    function xnavfile:string;
    procedure xclear;
    procedure xsmartsync;
    procedure xsync;
    procedure xsync2(xinfo_mustload,xinfo_mustsave,xdata_mustload,xdata_mustsave:boolean);
    function xnav:tbasicnav;
    procedure xclose;
    procedure xshowmenu(xname:string);
    procedure xreload;
    //text support - 19apr2022
    function textshowing:boolean;
    function canpastetext:boolean;
    function pastetext:boolean;
    //spell
    function xcanspell:boolean;
    procedure xspell;
    function xcanspelladd:boolean;
    procedure xspelladd;
    //find
    function xcanfind:boolean;
    //save support
    procedure xsave;
    procedure xsaveas;
    //last support
    function canlast:boolean;
    procedure lasttoggle;
    //settings
    function xloadsettings(xname:string;dvars:tvars8):boolean;//prgsettings -> control -> dvars (allows for filtering of value) - 25mar2021
    function xsavesettings(xname:string;dvars:tvars8):boolean;//prgsettings -> control -> dvars (allows for filtering of value) - 25mar2021
    function xmustsavesettings:boolean;
    //modified
    function modified:boolean;
    procedure modifiedoff;
    //other
    procedure xshowhide;
   end;


{tprogram}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxx//sssssssssssssssssssssssssssssssssss
   tprogram=class(tbasicprg2)
   private
    idocindex:longint;
    idoclist:array[0..9] of tdoceditor;
    icols,icols2:tbasiccols;
    ishownav,iautoview,ibuildingcontrol,iloaded,ibackup,ishowlog:boolean;
    iwritingtime,iwritingwords,iwritingwordsREF,istatusref64,iinfotimer,itimer100,itimer250,itimer500,itimerslow:comp;
    ibackupfolder,iwritingwordsREF2:string;
    //.log support
    ilognamelist:array[0..199] of string;
    ilognamecount:longint;
    //.build support
    ifiletime:string;
    itexttime,iimgtime,icleantime,iiotime,iiotimeCOPYFILE,iiotimeFROMFILE,iiotimeTOFILE,icodetime:comp;
    ircode10:byte;
    iruncodeCOUNT,ifilecount,ifilebytes,idepthcount,ierrorcount,iwarncount:longint;
    ilastfilecount:array[0..3] of longint;
    iparsep:char;// "|"
    //.status support
    isettingsref,isettingsref2:string;
    iinfoid,idownindex,inavindex,ifolderindex,ifileindex:longint;
    iisnav,iisfolder,iisfile:boolean;
    procedure __onclick(sender:tobject);
    procedure __ontimer(sender:tobject); override;
    procedure xloadsettings;
    procedure xsavesettings;
    procedure xautosavesettings(xfull:boolean);
    procedure xfillinfo;
    procedure xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
    function xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
    procedure xshowpage(x:longint);
    //edit support
    procedure xclosesamefiles(x:tdoceditor;xfilename:string);
    function xdoc:tdoceditor;
    function xdocindex:longint;
    procedure xsync;
    //build support
    procedure xshow(xmsg:string);
    function xshowinfo(xmsg,xmorechain:string):boolean;
    function xshowwarn(xmsg,xmorechain:string):boolean;
    function xshowerror(xmsg,xmorechain:string):boolean;
    function xfindformat(x:tstr8):string;
    //log support
    procedure xlognameclear;
    procedure xlognameadd(xlogname:string);
    procedure xlognamedel;
    //backup support
    function canbackup:boolean;
    procedure backup;
    //other
    procedure xsplitnameonlastdash(x:string;var v1,v2:string);//07oct2022
    procedure xclickcell(sender:tobject);
    procedure xwritingreset;
    function xonshortcut(sender:tobject):boolean;
    procedure xunpackdic(xforce:boolean);
   public
    //create
    constructor create(xminsysver:longint;xhost:tobject;dwidth,dheight:longint); override;
    destructor destroy; override;
    //support
    procedure xcmd(sender:tobject;xcode:longint;xcode2:string);
   end;

function low__createprogram(xhost:tobject):tbasicprg1;


//suport procs - 24dec2021
function low__chapterfileOK(xfilename:string):boolean;
function low__lastfoldername(xfolder,xdefaultname:string):string;

//support for Gossamer
procedure program__init;
procedure program__close;

implementation

uses infinite1;

//## low__datestr0 ##
function low__datestr0(x:tdatetime):string;
var
    yy,mm,dd,hh,min,ss,ms:word;
begin
try
result:='';
low__decodedate2(x,yy,mm,dd);
low__decodetime2(x,hh,min,ss,ms);
result:=inttostr(yy)+'y-'+inttostr(mm)+'m-'+inttostr(dd)+'d-'+inttostr(hh)+'h-'+inttostr(min)+'m-'+inttostr(ss)+'s-'+inttostr(ms)+'ms';
except;end;
end;

//## low__createprogram ##
function low__createprogram(xhost:tobject):tbasicprg1;
begin
try
result:=tprogram.create(0,xhost,1350,800);
result.createfinish;//perform form and POST create operations like sync main form's help visible state - 30jul2021
except;end;
end;
//## program__init ##
procedure program__init;
begin
//nil
end;
//## program__close ##
procedure program__close;
begin
//nil
end;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx//eeeeeeeeeeeeeeeeeeeeeee
//## create ##
constructor tdoceditor.create(xparent:tobject);
begin
create2(xparent,true);
end;
//## create ##
constructor tdoceditor.create2(xparent:tobject;xstart:boolean);
begin
inherited create2(xparent,false);

//vars
ibuildingcontrol:=true;
iloaded:=false;
itimer100:=ms64;
itimerAutosave:=ms64;
ilastsyncREF:='';
host:=nil;
ilogbase:=nil;
icansave:=false;
ondoccheck:=nil;
xbutcap:='';
xbuttep:=tepEdit20;
style:=bcVertical;
ishownav:=true;
ishowlog:=true;
isplit:=false;
ilogbuffer:=bnew;
imodifiedid:=0;
ilastfilename:='*';//means none - empty - disabled
//nav
with cols2[0,20,false] do
begin
xcols.style:=bcHorizontal;

//xcols.visible:=false;

with xcols.cols2[1,50,false] do
begin
inavtitle:=ntitle(false,ntranslate('Product Files'),'');
inav:=nnav.makenavlist2;
inav.hisname:='fileeditor';
inav.omasklist:='*.dic;*.txt;*.bwd;*.bwp;*.gif;*.png;*.jpg;*.jpeg;*.bmp;*.ico;*.cur;*.tea;';
inav.oemasklist:='.be.tea;';
inav.oautoheight:=true;
inav.sortstyle:=nlName;//nlSize;
end;

end;


//edit
with cols2[1,70,false].ncols do
begin
makeautoheight;
visible:=true;
style:=bcHorizontal;

//.text editor
 with cols2[0,76,false] do
 begin
 itexttitle:=ntitle(false,'Editor','Editor');
 //.editor support
 itext:=nbwp4('Edit text document',nil,0,true,true,false,false,false);
 itext.omenustyles:=true;
 itext.undoenabled:=true;
 itext.core.oviewurl:=false;//disable click to view http:// urls
 itext.core.onefontname:='$fontname2';//05feb2022
 itext.core.onefontsize:=1;//viFontsize2 - system size - 05feb2022
 itext.core.odic:=true;//04feb2023
 itext.core.obackup:=true;//04feb2023
 itext.olivewordcount:=true;//05feb2023
 itext.vsmooth:=true;

 ilist:=nlist('','',nil,10);
 ilist.otab:=tbL250_R100_L300;//tbL120_L120_L300;

 iimagelist:=nlist('','',nil,3);
 iimagelist.otab:=tbL250_R100_L300;

 iimage:=nimageviewer(nil,'');
 end;

//.log viewer
 ilogbase:=cols2[1,24,false];
 with ilogbase do
 begin
 ntitle(false,'Build Log','Build Log');
 ilog:=nbwp4('Build Log',nil,0,true,true,false,false,false);
 ilog.oreadonly:=true;
 ilog.oshowcursor:=false;
 ilog.core.oviewurl:=false;//disable click to view http:// urls
 ilog.core.defFontname:='Courier new';
 end;
 ilogbase.visible:=false;//hide - not yet used - 04feb2023

end;

//events
inav.showmenuFill1:=nav__showmenuFill;
inav.showmenuClick2:=nav__showmenuClick;;

//defaults
xresetAutosave;
modifiedoff;

//finished building
ibuildingcontrol:=false;
//start
if xstart then start;
end;
//## destroy ##
destructor tdoceditor.destroy;
begin
try
//control
bfree(ilogbuffer);
//self
inherited destroy;
except;end;
end;
//## xbackup_viaformatlevel ##
procedure tdoceditor.xbackup_viaformatlevel(xfilename:string);
var
   e,dext,aext:string;
   a:tstr8;
begin
try
//defaults
a:=nil;
//check
if not itext.visible then exit;
//init
aext:='';
xfilename:=low__extractfilename(xfilename);
dext:=lowercase__readfileext(xfilename);
//get
case low__wordcore__findformatlevel(itext.core^) of
1:if (dext<>'bwd') and (dext<>'bwp') then aext:='bwd';
2:if (dext<>'bwp') then aext:='bwp';
end;
//set
if (aext<>'') then
   begin
   a:=bnew;
   itext.ioget(a,aext);
   low__tofile(low__backupfilename(remlastext(xfilename)+'.'+aext),a,e);
   low__iroll(systrack_backupcount,1);//12feb2023
   end;
except;end;
try;bfree(a);except;end;
end;
//## getbackup ##
function tdoceditor.getbackup:boolean;
begin
try;result:=itext.core.obackup;except;end;
end;
//## setbackup ##
procedure tdoceditor.setbackup(x:boolean);
begin
try;itext.core.obackup:=x;except;end;
end;
//## xshowhide ##
procedure tdoceditor.xshowhide;
begin
try
vis[0]:=ishownav;
except;end;
end;
//## _ontimer ##
procedure tdoceditor._ontimer(sender:tobject);//._ontimer
begin
try
//timer100
if (ms64>=itimer100) and iloaded then
   begin
   //sync
   xshowhide;
   //reset
   itimer100:=ms64+100;
   end;
//itimerAutosave
if (ms64>=itimerAutosave) and iloaded then
   begin
   xresetAutosave;
   if backup and cansave and modified then xsave;
   end;
except;end;
end;
//## xresetAutosave ##
procedure tdoceditor.xresetAutosave;//autosave backup every 5 min - 12feb2023
begin
try;itimerAutosave:=low__add64(ms64,300000);except;end;
end;
//## popfav ##
function tdoceditor.popfav:string;
begin
try
result:=inav.popfav;
xsetnavvalue(result);
except;end;
end;
//## nav__showmenuFill##
procedure tdoceditor.nav__showmenuFill(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
var
   xok:boolean;
   //## dwords ##
   function dwords(x:longint):string;
   begin
   result:='  ( '+low__64(dic_wordcount(x))+' w )';
   end;
begin
try
//check
if zznil(xmenudata,2318) then exit;
//get
//.new document
xok:=(xnavfolder<>'');
low__menutitle(xmenudata,tepnone,'New Document','Select document format');
low__menuitem2(xmenudata,tepTXT20,'Text Document','TXT document','new.txt',100,aknone,xok);
low__menuitem2(xmenudata,tepBWD20,'Enhanced Text Document','BWD document','new.bwd',100,aknone,xok);
low__menuitem2(xmenudata,tepBWP20,'Advanced Text Document','BWP document','new.bwp',100,aknone,xok);
//.options
xok:=(xnavfile<>'');
low__menutitle(xmenudata,tepnone,'Options','Display options');
low__menuitem2(xmenudata,tep__yes(rows),'Color Rows','Color rows','toggle.rows',100,aknone,xok);
low__menuitem2(xmenudata,tepRefresh20,'Reset Writing Counter...','Reset writing counter','host.time.reset',100,aknone,true);
//.spelling
low__menutitle(xmenudata,tepnone,'Spelling','Spelling options');
low__menuitem2(xmenudata,tep__yes(sysdic_main_use),'Main'+dwords(0),'Use dictionary: main.dic','toggle.main',100,aknone,true);
low__menuitem2(xmenudata,tep__yes(sysdic_sup1_use),'Supplementary 1'+dwords(1),'Use dictionary: sup1.dic','toggle.sup1',100,aknone,true);
low__menuitem2(xmenudata,tep__yes(sysdic_sup2_use),'Supplementary 2'+dwords(2),'Use dictionary: sup2.dic','toggle.sup2',100,aknone,true);
low__menusep(xmenudata);
low__menuitem2(xmenudata,tepEdit20,'Edit Main','Edit dictionary: main.dic','edit.main',100,aknone,true);
low__menuitem2(xmenudata,tepEdit20,'Edit Supplementary 1','Edit dictionary: sup1.dic','edit.sup1',100,aknone,true);
low__menuitem2(xmenudata,tepEdit20,'Edit Supplementary 2','Edit dictionary: sup2.dic','edit.sup2',100,aknone,true);
low__menusep(xmenudata);
low__menuitem2(xmenudata,tepRefresh20,'Reload Dictionaries','Reload dictionaries','reload.dics',100,aknone,true);
low__menuitem2(xmenudata,tepSave20,'Restore Main Dictionary...','Restore main dictionary to default','host.restore.maindic',100,aknone,true);
//.backup`
low__menutitle(xmenudata,tepnone,'Backup','Backup options');
low__menuitem2(xmenudata,tep__yes(backup),'Make Backups','A backup is written each time the document is significantly changed','host.backup.toggle',100,aknone,true);
low__menuitem2(xmenudata,tepFolder20,'Show Folder','Show the backups storage folder','host.backup.showfolder',100,aknone,true);
except;end;
end;
//## nav__showmenuClick ##
function tdoceditor.nav__showmenuClick(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin
try;result:=xcmd(self,xcode,xcode2);except;end;
end;
//## xcmd ##
function tdoceditor.xcmd(sender:tobject;xcode:longint;xcode2:string):boolean;//true=handled
label
   skipend,redonew;
var
   e,str1,str2:string;
begin
try
//defaults
result:=false;
//get
if (xcode2='refresh') then xreload
else if (xcode2='toggle.rows') then rows:=not rows
else if low__comparetext(strcopy1(xcode2,1,4),'new.') then
   begin
   str1:=strcopy1(xcode2,5,length(xcode2));
   if (xnavfolder<>'') then
      begin
      str2:=low__extractfilepath(xnavfolder)+'.'+str1;
      redonew:
      if sysprogram.rootwin.gui.popsave(str2,str1,'') then
         begin
         if low__fileexists(str2) then
            begin
            gui.popquery('File already exists.  Use another name.');
            goto redonew;
            end
         else
            begin
            low__tofilestr(str2,'',e);
            xcmd(nil,0,'refresh');
            end;
         end;
      end;
   end
else if (xcode2='toggle.main') then low__toggle(sysdic_main_use)
else if (xcode2='toggle.sup1') then low__toggle(sysdic_sup1_use)
else if (xcode2='toggle.sup2') then low__toggle(sysdic_sup2_use)
else if (xcode2='edit.main') then dic_edit(0)
else if (xcode2='edit.sup1') then dic_edit(1)
else if (xcode2='edit.sup2') then dic_edit(2)
else if (xcode2='reload.dics') then dic_reload(-1)
else if (strcopy1(xcode2,1,5)='host.') then
   begin
   if (host<>nil) and (host is tprogram) then (host as tprogram).xcmd(sender,xcode,strcopy1(xcode2,6,length(xcode2)));//pass onto our host
   end
else goto skipend;//not handled
//successful
result:=true;
skipend:
except;end;
end;
//## modified ##
function tdoceditor.modified:boolean;
begin
try;result:=(imodifiedid<>itext.core.dataid3);except;end;
end;
//## modifiedoff ##
procedure tdoceditor.modifiedoff;
begin
try;imodifiedid:=itext.core.dataid3;except;end;
end;
//## xreload ##
procedure tdoceditor.xreload;
begin
try;inav.reload;except;end;
end;
//## xtextfont ##
procedure tdoceditor.xtextfont;//30dec2021
begin
try
//text
with itext.core^ do
begin
defFontname   :='Default 2';//courier new
defFontsize   :=vifontsize__root+low__insint(2,vifontsize__root<=10);//non-zoomed version
defFontcolor  :=vinormal.font;
pagecolor     :=vinormal.background;
pageselcolor  :=vinormal.highlight;
pagefontselcolor:=vinormal.fonthighlight;
viewcolor     :=low__dc(pagecolor,50);
cfontname     :=defFontname;
cfontsize     :=defFontsize;
cbold         :=false;
citalic       :=false;
cunderline    :=false;
cstrikeout    :=false;
end;
//log
with ilog.core^ do
begin
cfontname     :='Courier New';
cfontsize     :=9;
cbold         :=false;
citalic       :=false;
cunderline    :=false;
cstrikeout    :=false;
end;

except;end;
end;
//## logclear ##
procedure tdoceditor.logclear;
begin
try
ilogbuffer.clear;
low__wordcore(ilog.core^,'clear',nil);
except;end;
end;
//## logadd ##
procedure tdoceditor.logadd(x:string);
begin
if (ilogbase<>nil) then
   begin
   xtextfont;
   low__wordcore_str(ilog.core^,'ins2',x);//ins2 overrides readonly
   end;
end;
//## getcore ##
function tdoceditor.getcore:pwordcore;
begin
try;result:=itext.core;except;end;
end;
//## getcpos ##
function tdoceditor.getcpos:longint;
begin
try;result:=itext.cpos;except;end;
end;
//## xmustsavesettings ##
function tdoceditor.xmustsavesettings:boolean;
begin
try;result:=(not ibuildingcontrol) and low__setstr(isettingsref,bnc(isplit)+'|'+inttostr(inav.sortstyle)+'|'+xnavvalue(false));except;end;
end;
//## xloadsettings ##
function tdoceditor.xloadsettings(xname:string;dvars:tvars8):boolean;//prgsettings -> control -> dvars (allows for filtering of value) - 25mar2021
begin
try
//defaults
result:=false;
//check
if (dvars=nil) then exit;
//get
dvars.b[xname+'.split']:=prgsettings.bdef(xname+'.split',false);
dvars.s[xname+'.value']:=prgsettings.sdef(xname+'.value','');
dvars.s[xname+'.value0']:=prgsettings.sdef(xname+'.value0','');

isplit:=dvars.b[xname+'.split'];
dvars.b[xname+'.split']:=isplit;

xsync;//update for "isplit" immediately - 12jan2022

inav.xfromprg2(xname+'.nav',dvars);//prg -> nav -> a

xsetnavvalue(dvars.s[xname+'.value']);

dvars.s[xname+'.value']:=xnavvalue(true);

//set
iloaded:=true;
result:=true;
except;end;
end;
//## xsavesettings ##
function tdoceditor.xsavesettings(xname:string;dvars:tvars8):boolean;//prgsettings -> control -> dvars (allows for filtering of value) - 25mar2021
begin
try
//defaults
result:=false;
//check
if (dvars=nil) then exit;
//get
dvars.b[xname+'.split']:=isplit;
dvars.s[xname+'.value']:=xnavvalue(true);
inav.xto(inav,dvars,xname+'.nav');
//set
result:=true;
except;end;
end;
//## xnav ##
function tdoceditor.xnav:tbasicnav;
begin
try;result:=inav;except;end;
end;
//## xshowmenu ##
procedure tdoceditor.xshowmenu(xname:string);
begin
try
if (xname='edit') then
   begin
   if itext.visible then itext.showmenu;
   end;
except;end;
end;
//## xcanfind ##
function tdoceditor.xcanfind:boolean;
begin
try;result:=itext.visible and itext.canfind;except;end;
end;
//## xcanspell ##
function tdoceditor.xcanspell:boolean;
begin
try;result:=itext.visible and itext.canspell;except;end;
end;
//## xspell ##
procedure tdoceditor.xspell;
begin
try
if xcanspell then
   begin
   itext.spell;
   itext.setfocus;
   end;
except;end;
end;
//## xcanspelladd ##
function tdoceditor.xcanspelladd:boolean;
begin
try;result:=itext.visible and itext.canspell and ( (sysdic_sup1_use and (sysdic_sup1<>nil)) or (sysdic_sup2_use and (sysdic_sup2<>nil)) ) and (itext.core.dic_addword<>'');except;end;
end;
//## xspelladd ##
procedure tdoceditor.xspelladd;
var
   i:longint;
begin
try
i:=0;
if xcanspelladd then
   begin
   //init
   if (i<1) and sysdic_sup1_use and (sysdic_sup1<>nil) then i:=1;
   if (i<1) and sysdic_sup2_use and (sysdic_sup2<>nil) then i:=2;
   //get
   if (i>=1) then
      begin
      if pop_query2('Add word "'+itext.core.dic_addword+'" to supplementary dictionary '+inttostr(i)+' ?','','Add Word') then dic_addword(itext.core.dic_addword,i);
      itext.core.dic_addword:='';
      end;
   xspell;
   end;
except;end;
end;
//## xsave ##
procedure tdoceditor.xsave;
begin
try
if (ifilename<>'') then xsync2(false,true,false,true);
except;end;
end;
//## xsaveas ##
procedure tdoceditor.xsaveas;
begin
try
//xxxxxxxxxxxxxxx if (ifilename<>'') then xsync2(false,true,false,true);
except;end;
end;
//## xclose ##
procedure tdoceditor.xclose;
begin
try
inav.xlist.itemindex:=0;
xsync;
except;end;
end;
//## xnavfolder ##
function tdoceditor.xnavfolder:string;
begin
try;result:=inav.folder;except;end;
end;
//## xnavfile ##
function tdoceditor.xnavfile:string;
begin
try
if (inav.valuestyle=nltFile) then result:=inav.value else result:='';
except;end;
end;
//## canlast ##
function tdoceditor.canlast:boolean;
begin
try;result:=(ilastfilename<>'*');except;end;
end;
//## lasttoggle ##
procedure tdoceditor.lasttoggle;
var
   str1:string;
begin
try
if canlast then
   begin
   str1:=xnavfile;
   inav.value:=ilastfilename;
   ilastfilename:=str1;
   end;
except;end;
end;
//## xnavvalue ##
function tdoceditor.xnavvalue(xportable:boolean):string;
begin
try
if (inav.valuestyle=nltFile) then result:=inav.value
else if xportable            then result:=low__makeportablefilename(inav.folder)
else                              result:=inav.folder;
except;end;
end;
//## xsetnavvalue ##
procedure tdoceditor.xsetnavvalue(x:string);
begin
try
if (x='')                                      then inav.folder:=''
else if (strlastx(x)='\') or (strlastx(x)='/') then inav.folder:=low__readportablefilename(asfolderNIL(x))
else                                                inav.value:=x;
except;end;
end;
//## xclear ##
procedure tdoceditor.xclear;
begin
try
imustsetnavvalue:='';
ic2pref:='';
ic2pref_mask:='';
inavref:='';
iinforef:='';
isyncref:='';
ifilename:='';
isplit:=false;
istyle:=0;
irows:=false;
ishowlog:=false;
iscrollv_px:=0;
iscrollh:=0;
ipos:=0;
ipos2:=0;
itext.visible:=false;
ilist.visible:=false;
iimage.visible:=false;
iimagelist.visible:=false;
except;end;
end;
//xxxxxxxxxxxxxxxxxxx//eeeeeeeeeeeeeeeeeeeeeee
//## textshowing ##
function tdoceditor.textshowing:boolean;
begin
try;result:=(itext<>nil) and itext.visible;except;end;
end;
//## canpastetext ##
function tdoceditor.canpastetext:boolean;
begin
try;result:=textshowing and low__canpastetxt;except;end;
end;
//## pastetext ##
function tdoceditor.pastetext:boolean;
var
   a,b:tstr8;
   int1:longint;
begin
try
//defaults
result:=false;
a:=nil;
b:=nil;
//get
if canpastetext then
   begin
   a:=bnew;
   b:=bnew;
   if low__pastetxt(a) then
      begin
      itext.iogetbwp(b);
      itext.revertinit(b,true);
      int1:=itext.vpos;
      itext.ioset2(a,-1,int1);
      result:=true;
      end;
   end;
except;end;
try
bfree(a);
bfree(b);
except;end;
end;
//##xsmartsync ##
procedure tdoceditor.xsmartsync;
begin
try
//check
if ibuildingcontrol or (not iloaded) then exit;
//smart check -> limit syncing to visible TAB and those tabs that need startup or current sync BUT NO ongoing syncing - 12jan2022
if (not low__setstr(ilastsyncREF,bnc(iloaded)+'|'+inav.folder+'|')) and (not visible) then exit;
//get
xsync;
except;end;
end;
//## xsync ##
procedure tdoceditor.xsync;
begin
try;xsync2(false,false,false,false);except;end;
end;
//## xsync2 ##
procedure tdoceditor.xsync2(xinfo_mustload,xinfo_mustsave,xdata_mustload,xdata_mustsave:boolean);
var
   str2,str1,xnavext,xext,anavfolder,xnavfilename,xfilename,e:string;
   xstatus_loadeddata,bol1,xmustpaint,xmustdata,xmustinfo,xsplit,xrows:boolean;
   int1,p,xpos,xpos2,xscrollv_px,xscrollh:longint;
   xstyle,sbits,sw,sh,scellcount,scellw,scellh,sdelay:longint;
   shasai,stransparent:boolean;
   xvars:tvars8;
   xtmp,xdata:tstr8;
   //## xshow ##
   procedure xshow(x:tbasiccontrol;xvisible:boolean);
   begin
   try
   if (x<>nil) and (x.visible<>xvisible) then
      begin
      x.visible:=xvisible;
      xmustpaint:=true;
      end;
   except;end;
   end;
   //## xsubname ##
   function xsubname(xname:string):string;
   begin
   result:=xname+'.*;'+xname+'-*.*;';
   end;
   //## xneedtmp ##
   function xneedtmp:boolean;
   begin
   result:=true;
   if (xtmp=nil) then xtmp:=bnew else xtmp.clear;
   end;
   //## xfindwrap ##
   function xfindwrap:longint;
   begin
   case xstyle of
   0:result:=wwsNone;
   1:result:=wwsWindow;
   2:result:=wwsPage;
   3:result:=wwsPage;
   4:result:=wwsPage2
   else result:=wwsNone;
   end;//case
   end;
   //## xfindlinespacing ##
   function xfindlinespacing:longint;
   begin
   case xstyle of
   3..4:result:=2;
   else result:=1;
   end;//case
   end;
begin
try
//defaults
xdata:=nil;
xtmp:=nil;
xmustpaint:=false;
xstatus_loadeddata:=false;
//disable this, was used for Claude only - xsplit:=isplit;
xsplit:=false;

//check
if ibuildingcontrol or (ilogbase=nil) then exit;
//nav - switch display modes
bol1:=low__setstr(inavref,bnc(xsplit));
inav.ocansort:=not xsplit;
case xsplit of
false:begin
   if bol1 or (inav.style<>bnNavlist) then
      begin
      inavtitle.visible:=false;
      //inav.omasklist:='*';
      inav.style:=bnNavlist;
      xmustpaint:=true;
      end;
   end;
true:begin
   if bol1 or (inav.style=bnNavlist) then
      begin
      inavtitle.visible:=true;
      inav.style:=bnNamelist;
      xmustpaint:=true;
      end;
   //mask
   //if (inav.omasklist<>str1) then inav.omasklist:=str1;
   if (imustsetnavvalue<>'') then
      begin
      str1:=imustsetnavvalue;
      imustsetnavvalue:='';
      xsetnavvalue(str1);
      end;
   end;
end;

//init
anavfolder:=xnavfolder;
xnavfilename:=xnavfile;

//.special check -> remove all instances of the same file being editing by other tabs - 19dec2021
if (xnavfilename<>'') and assigned(ondoccheck) and visible then ondoccheck(self,xnavfilename);
xfilename:=ifilename;
xstyle:=frcrange(istyle,0,4);
xrows:=irows;
if itext.visible then
   begin
   iscrollv_px:=low__wordcore_str2(itext.core^,'vpos.px','');
   iscrollh:=itext.hpos;
   ipos:=itext.cpos;
   ipos2:=itext.cpos2;
   end
else
   begin
   iscrollv_px:=0;
   iscrollh:=0;
   ipos:=0;
   ipos2:=0;
   end;
xscrollv_px:=iscrollv_px;
xscrollh:=iscrollh;
xpos:=ipos;
xpos2:=ipos2;
xmustdata:=low__setstr(isyncref,xnavfilename);
xmustinfo:=low__setstr(iinforef,inttostr(xstyle)+'_'+bnc(xrows)+'_'+inttostr(xscrollv_px)+'_'+inttostr(xscrollh)+'_'+inttostr(xpos)+'_'+inttostr(xpos2)+'_') or xmustdata;

//init continued
xnavext:=lowercase__readfileext(xnavfilename);
xext:=lowercase__readfileext(xfilename);
xvars:=vnew;
xdata:=bnew;

//save previous
//.info
if (xfilename<>'') and (xmustinfo or xinfo_mustsave) then
   begin
   xvars.i['style']:=frcrange(xstyle,0,4);
   xvars.b['rows']:=xrows;
   xvars.i['pos']:=xpos;
   xvars.i['pos2']:=xpos2;
   xvars.i['scrollv.px']:=xscrollv_px;
   xvars.i['scrollh']:=xscrollh;
   low__tofile(xfilename+'.ini',xvars.data,e);
   end;
//.data
if (xfilename<>'') and (xmustdata or xdata_mustsave) and itext.visible and cansave and modified then
   begin
   //init
   xdata.clear;
   xstatus_loadeddata:=false;
   bol1:=false;
   //backup - take file on disk and copy to backup folder
   if backup and low__fileexists(xfilename) then
      begin
      low__copyfile(xfilename,low__backupfilename('__'+low__extractfilename(xfilename)),e);
      low__iroll(systrack_backupcount,1);//12feb2023
      end;
   //backup - take current document and  copy to backup when formatting WILL be lost - 12feb2023
   if backup then xbackup_viaformatlevel('__'+low__extractfilename(xfilename));
   //get
   if (xext='txt') or (xext='ini') or (xext='c2v') or (xext='footnote') then
      begin
      itext.ioget(xdata,'txt');
      bol1:=low__tofile(xfilename,xdata,e);
      end
   else if (xext='bwd') then
      begin
      itext.ioget(xdata,'bwd');
      bol1:=low__tofile(xfilename,xdata,e);
      end
   else if (xext='bwp') then
      begin
      itext.ioget(xdata,'bwp');
      bol1:=low__tofile(xfilename,xdata,e);
      end
   else if (xext='xml') then
      begin
      itext.ioget(xdata,'txt');
      bol1:=low__tofile(xfilename,xdata,e);
      end
   else if (xext='c2p') then
      begin
      itext.ioget(xdata,'txt');
      bol1:=low__tofile(xfilename,xdata,e);
      end
   else if (xext='r') then//redirect link
      begin
      itext.ioget(xdata,'txt');
      bol1:=low__tofile(xfilename,xdata,e);
      end
   else if (xext='html') then
      begin
      itext.ioget(xdata,'txt');
      bol1:=low__tofile(xfilename,xdata,e);
      end;
   //.update revert data
   itext.revertinit(xdata,true);//19dec2021
   //.other
   if bol1 then modifiedoff;
   end;

//change to current
xfilename:=xnavfilename;
xext:=xnavext;
//load current
//.info
if (xfilename<>'') and (xmustinfo or xinfo_mustload) then
   begin
   //init
   if (not xstatus_loadeddata) and itext.visible then
      begin
      //nil
      end
   else xmustpaint:=true;
   xdata.clear;
   xstyle:=low__aorb(1,3,low__chapterfileOK(xfilename));
   xrows:=false;
   xscrollv_px:=0;
   xscrollh:=0;
   xpos:=0;
   xpos2:=0;
   xvars.clear;
   //get
   if low__fromfile(xfilename+'.ini',xdata,e) then
      begin
      xvars.data:=xdata;
      xstyle:=frcrange(xvars.i['style'],0,4);
      xrows:=xvars.b['rows'];
      xscrollv_px:=xvars.i['scrollv.px'];
      xscrollh:=xvars.i['scrollh'];
      xpos:=xvars.i['pos'];
      xpos2:=xvars.i['pos2'];
      end;
   end;

//.xdata
if (xfilename<>'') and (xmustdata or xdata_mustload) then
   begin
   //init
   xmustpaint:=true;
   xdata.clear;
   ilastfilename:=ifilename;
   //get
   low__fromfile(xfilename,xdata,e);
   if (xext='c2p') or (xext='dic') or (xext='txt') or (xext='footnote') or (xext='c2v') or (xext='r') or (xext='bwd') or (xext='bwp') or (xext='xml')  or (xext='html') then
      begin
      xtextfont;
      itext.core.obackupname:='__'+low__extractfilename(xfilename);//25feb20223
      itext.wrap:=xfindwrap;
      itext.linespacing:=xfindlinespacing;
      itext.ioset3(xdata,xscrollv_px,-1,xscrollh,xpos,xpos2,false,false);
      itext.revertinit(xdata,true);//19dec2021
      icansave:=true;
      modifiedoff;
      end;
   end;

//show
if (xext='c2p') or (xext='dic') or (xext='txt') or (xext='footnote') or (xext='c2v') or (xext='r') or (xext='bwd') or (xext='bwp') or (xext='xml') or (xext='html') then
   begin
   xshow(itext,true);
   xshow(ilist,false);
   xshow(iimagelist,false);
   xshow(iimage,false);
   end
else if (xext='exe') or (xext='zip') or (xext='7z') then
   begin
   if (xmustdata or xdata_mustload) then
      begin
      xneedtmp;
      low__menuinit(xtmp);
      low__menuitem(xtmp,tepNone,'Name'+#9+'Size'+#9+'Folder','','',0,true);
      str1:=remlastext(xfilename);
      for p:=1 to 3 do
      begin
      case p of
      1:str2:=str1+'.zip';
      2:str2:=str1+'.7z';
      else str2:=str1+'.exe';
      end;
      int1:=low__filesize(str2);
      if (int1>=0) then low__menuitem(xtmp,tepext2(str2,tepEXE20),low__extractfilename(str2)+#9+low__64(int1)+' b'+#9+low__extractfilepath(str2),'','',0,true);
      end;//p
      low__menuend(xtmp);
      ilist.data:=xtmp;
      end;
   xshow(itext,false);
   xshow(ilist,true);
   xshow(iimagelist,false);
   xshow(iimage,false);
   end
else if (xext='png') or (xext='jpg') or (xext='jif') or (xext='jpeg') or (xext='gif') or (xext='ico') or (xext='bmp') then
   begin
   if (xmustdata or xdata_mustload) then
      begin
      //image
      xneedtmp;
      if not low__fromfile(xfilename,xtmp,e) then xtmp.clear;
      int1:=xtmp.len;
      iimage.makeimageviewer2(xtmp,true);
      miscells(iimage.ximageviewerbuffer,sbits,sw,sh,scellcount,scellw,scellh,sdelay,shasai,stransparent);

      //info
      xneedtmp;
      low__menuinit(xtmp);
      low__menuitem(xtmp,tepNone,'Name'+#9+'Size'+#9+'Dimensions','','',0,true);
      low__menuitem(xtmp,tepBMP20,low__extractfilename(xfilename)+#9+low__64(int1)+' b'+#9+low__64(misw(iimage.ximageviewerbuffer))+' w x '+low__64(mish(iimage.ximageviewerbuffer))+' h'+low__insstr(' + '+low__64(scellcount)+' cells',scellcount>=2)+' + '+low__aorbstr('solid','transparent',stransparent),'','',0,true);
      low__menuend(xtmp);
      iimagelist.data:=xtmp;
      end;
   xshow(itext,false);
   xshow(ilist,false);
   xshow(iimagelist,true);
   xshow(iimage,true);
   end
else
   begin
   xshow(itext,false);
   xshow(ilist,false);
   xshow(iimagelist,false);
   xshow(iimage,false);
   end;

//sync
if itext.visible then
   begin
   itext.orows:=xrows;
   itext.wrap:=xfindwrap;
   itext.linespacing:=xfindlinespacing;
   ilog.orows:=xrows;
   ilog.wrap:=1;
   end;

//set
ifilename:=xfilename;
istyle:=frcrange(xstyle,0,4);
irows:=xrows;
iscrollv_px:=xscrollv_px;
iscrollh:=xscrollh;
ipos:=xpos;
ipos2:=xpos2;

//.butcap
xbutcap:=low__lastfoldername(anavfolder,'( None )');

//was: xbutcap:=low__udv(low__extractfilename(xfilename),'none');
//.buttep
//xbuttep:=tepEdit20;
//xbuttep:=tepBWD20;
//was: if low__setstr(iextref,xext) then xbuttep:=tepext2(xfilename,tepNew20);

{//was:
if (ishowlog<>ilogbase.visible) then
   begin
   ilogbase.visible:=ishowlog;
   xmustpaint:=true;
   end;
{}

//.repaint
if xmustpaint then
   begin
   gui.fullalignpaint;
   end;
except;end;
try
bfree(xdata);
bfree(xtmp);
freeobj(@xvars);
except;end;
end;

//## tprogram ##################################################################
//xxxxxxxxxxxxxxxxxxxx//sssssssssssssssssssssssssss
//## create ##
constructor tprogram.create(xminsysver:longint;xhost:tobject;dwidth,dheight:longint);
var
   junk1,junk2,junk3:tstr8;//xxxxxxxxxxxxxxxxxxxxxxx
   dfolder,e:string;
   p:longint;
   int1,int2:longint;//xxxxxxxxxxxxxxxx
   a:tdynamicstring;
   b:tstr8;
begin
if system_debug then dbstatus(38,'Debug 010 - 21may2021_528am');//yyyy

//needers - 26sep2021
need_jpeg;
need_gif;

//self
inherited create(10021095,xhost,dwidth,dheight);
ibuildingcontrol:=true;

{//xxxxxxxxxxxxxxxxxxxxx
junk1:=bnew;
junk2:=bnew;
junk3:=bnew;

if not zip_start(junk1,junk2) then showbasic('start.error');
if not zip_addfromfile(junk1,junk2,'c:\temp\words.txt') then showbasic('addfile.error');

//if not zip_add3(junk1,junk2,'notes.txt','Some notes here...END!') then showbasic('add.error');
//if not zip_addfromfile(junk1,junk2,'c:\temp\3.bmp') then showbasic('addfile.error');

//if not zip_addfromfolder(junk1,junk2,'c:\temp\','*.bmp','') then showbasic('addfromfolder.error');

if not zip_stop(junk1,junk2) then showbasic('stop.error');

if not low__tofile('c:\temp\1.zip',junk1,e) then showbasic('e1>'+e+'<<');//xxxxxxxxxxxxxxxxxxxxxx
siclose;//xxxxxxxxxxx

{}//xxxxxxxxx



//init
iparsep:='|';
ircode10:=10;
iinfotimer:=ms64;
itimer100:=ms64;
itimer250:=ms64;
itimer500:=ms64;
itimerslow:=ms64;
istatusref64:=ms64;
isettingsref:='';
isettingsref2:='';
iwritingtime:=0;
iwritingwords:=0;
iwritingwordsREF:=0;
iwritingwordsREF2:='';
//vars
iloaded:=false;
ishowlog:=true;
ibackup:=false;
idocindex:=0;
ilognamecount:=0;
ierrorcount:=0;
iwarncount:=0;
idepthcount:=0;
ifilecount:=0;
for p:=0 to high(ilastfilecount) do ilastfilecount[p]:=0;
iruncodeCOUNT:=0;
ifilebytes:=0;
ifiletime:='';
ibackupfolder:='';

//controls
with rootwin do
begin
scroll:=false;
xhead;
xtoolbar;
{//debug only:
xtoolbar.add('t1',tepMax20,0,'t1','Toggle full screen');
xtoolbar.add('t2',tepMax20,0,'t2','Toggle full screen');
xtoolbar.add('t3',tepMax20,0,'t3','Toggle full screen');
xtoolbar.add('t4',tepMax20,0,'t4','Toggle full screen');
{}//xxxxxxxxxxxxxxxxxxxxxxxx

//xtoolbar.add('test',tepRefresh20,0,'test','');


xtoolbar.add('Max',tepMax20,0,'max.toggle','Toggle full screen mode');
xtoolbar.add('Nav',tepNav20,0,'nav.toggle','Toggle display of navigation panel');
xtoolbar.add('Refresh',tepRefresh20,0,'refresh','Refresh list');
xtoolbar.add('Fav',tepFav20,0,'fav','Show favourites list');
xtoolbar.add('Close',tepClose20,0,'close','Close document');
xtoolbar.add('Save',tepSave20,0,'save','Save document - press Ctrl+S');

xtoolbar.add('Last',tepPrev20,0,'last.toggle','Toggle last document');

xtoolbar.addsep;

xtoolbar.add('Menu',tepMenu20,0,'nav.showmenu','Show menu');
xtoolbar.add('Edit',tepEdit20,0,'edit','Show edit menu');

xtoolbar.add('Redo',tepRedo20,0,'redo','Redo last change - press Ctrl+R');
xtoolbar.add('Undo',tepUndo20,0,'undo','Undo last change - press Ctrl+D');
xtoolbar.add('Find',tepNext20,0,'find','Find text | Press F4 for dialog window and F3 to find next');
xtoolbar.add('Check',tepPlay20,0,'spell','Spell check document | Press F7');
xtoolbar.add('Add',tepAddL20,0,'spell.add','Add word to supplementary dictionary and continue spell check');
xtoolbar.add('Backup',tepNewfolder20,0,'backup','Backup directory contents to automatically named ZIP archive (no subfolders)');

xtoolbar.addsep;



//xtoolbar.add('Rows',tepEdit20,0,'rows.toggle','Toggle rows');
//xtoolbar.add('Wrap',tepWrap20,0,'style.inc','Increment through wrap styles: None, Window, Page and Page + 2x');

//xtoolbar.add('Big!',tepWrap20,0,'test1','Increment through wrap styles: None, Window, Page and Page + 2x');
//xtoolbar.addsep;
//xtoolbar.add('Save As',tepSave20,0,'saveas','Save As document');
//xhigh2.ntitle(false,'Playback Progress','Midi playback progress');
end;


with rootwin do
begin
scroll:=false;
xhead;
xtoolbar2;
xtoolbar2.orighttoleft:=false;
xtoolbar2.odownsubtle:=true;
xtoolbar2.normal:=false;
xtoolbar2.oasbuttons:=false;
xtoolbar2.omarkcleanly:=true;
xtoolbar2.ovpad:=10;
end;

//left
rootwin.xstatus2;
rootwin.xstatus2.cellwidth[0]:=120;
rootwin.xstatus2.cellwidth[1]:=130;
rootwin.xstatus2.cellwidth[2]:=100;
rootwin.xstatus2.cellwidth[3]:=110;
rootwin.xstatus2.cellwidth[4]:=80;
rootwin.xstatus2.cellwidth[5]:=80;
rootwin.xstatus2.cellwidth[6]:=130;
rootwin.xstatus2.cellwidth[7]:=90;
rootwin.xstatus2.cellwidth[8]:=130;
rootwin.xstatus2.cellwidth[9]:=90;


//.last links on toolbar - 22mar2021
with rootwin do
begin
xtoolbar.xaddoptions;
xtoolbar.xaddhelp;
end;

//.doc editors
for p:=0 to high(idoclist) do
begin
idoclist[p]:=tdoceditor.create(rootwin);
idoclist[p].host:=self;
idoclist[p].visible:=(p<=0);
idoclist[p].oautoheight:=true;
idoclist[p].opagename:='doc.'+inttostr(p);
idoclist[p].tag:=p;
idoclist[p].shownav:=false;//off at startup
idoclist[p].xshowhide;
rootwin.xtoolbar2.add('',tepNew20,0,idoclist[p].opagename,'');
end;

//events
rootwin.xtoolbar.onclick:=__onclick;
rootwin.xtoolbar.showmenuFill1:=xshowmenuFill1;
rootwin.xtoolbar.showmenuClick1:=xshowmenuClick1;
rootwin.xtoolbar.ocanshowmenu:=true;//use toolbar for special menu display - 18dec2021
rootwin.xtoolbar2.onclick:=__onclick;
rootwin.xstatus2.clickcell:=xclickcell;
for p:=0 to high(idoclist) do idoclist[p].ondoccheck:=xclosesamefiles;
sys.onshortcut:=xonshortcut;

//inav.onclick:=__onclick;
//inav.xlist.showmenuFill1:=xshowmenuFill1;
//inav.xlist.showmenuClick1:=xshowmenuClick1;

//defaults
xfillinfo;
for p:=0 to high(idoclist) do
begin
idoclist[p].xclear;
rootwin.xtoolbar2.bvisible[p]:=false;
end;
xshowpage(0);

//start timer event
ibuildingcontrol:=false;
xloadsettings;
xstarttimer;
xunpackdic(false);
end;
//## destroy ##
destructor tprogram.destroy;
var
   p:longint;
begin
try
//settings
xautosavesettings(true);
//editors
for p:=0 to high(idoclist) do idoclist[p].xsave;
//self
inherited destroy;
except;end;
end;
//## xunpackdic ##
procedure tprogram.xunpackdic(xforce:boolean);
var
   a:tstr8;
   e,df:string;
begin
try
//defaults
a:=nil;
//get
df:=low__platfolder('settings')+'main.dic';
if xforce or (not low__fileexists(df)) then
   begin
   a:=bnew;
   a.aadd(program_maindic1);
   a.aadd(program_maindic2);
   a.aadd(program_maindic3);
   a.aadd(program_maindic4);
   if low__decompress(a,e) and low__tofile(df,a,e) then dic_reload(0);
   end;
except;end;
try;bfree(a);except;end;
end;
//## xonshortcut ##
function tprogram.xonshortcut(sender:tobject):boolean;
begin
try
result:=false;
case sys.key of
akctrlS:begin;result:=true;xdoc.xsave;end;
//akctrlL:begin;result:=true;xcmd(self,0,'last.toggle');end;
end;//case
except;end;
end;
//## xclickcell ##
procedure tprogram.xclickcell(sender:tobject);
var
   n:string;
begin
try
n:='';
if (sender is tbasicstatus) then n:=(sender as tbasicstatus).clickname;
if (n<>'') then xcmd(nil,0,n);
except;end;
end;
//xxxxxxxxxxxxxxxxxxxxxxxx//sssssssssssssssssssss
//## canbackup ##
function tprogram.canbackup:boolean;
begin
try;result:=(xdoc.xnavfolder<>'');except;end;
end;
//## backup ##
procedure tprogram.backup;
label
   skipend;
var
   xdata,xlist:tstr8;
   e,xfolder,df:string;
begin
try
//defaults
xdata:=nil;
xlist:=nil;
//check
if not canbackup then exit;
//init
xdata:=bnew;
xlist:=bnew;
xfolder:=xdoc.xnavfolder;
//start
if not zip_start(xdata,xlist) then goto skipend;
//get
if not zip_addfromfolder(xdata,xlist,xfolder,'*','') then
   begin
   pop_error('Backup failed');
   goto skipend;
   end;
//stop
if not zip_stop(xdata,xlist) then goto skipend;
//prompt
df:=ibackupfolder+low__datetimename2(now)+'__'+low__lastfoldername(xfolder,'Untitled')+'.zip';
if pop_save2(df,peZIP,low__insstr(low__platfolder2('backups',false),low__folderexists(low__platfolder2('backups',false))),'Backup') then
   begin
   ibackupfolder:=low__extractfilepath(df);
   //save
   if not low__tofile(df,xdata,e) then pop_error(e);
   end;

skipend:
except;end;
try
bfree(xdata);
bfree(xlist);
except;end;
end;
//## xfindformat ##
function tprogram.xfindformat(x:tstr8):string;
var
   v:string;
begin
try
result:='txt';
if not block(x) then exit;
v:=bgetstr1(x,1,4);
if low__comparetext(v,'bwp1') or low__comparetext(v,'bwp#')      then result:='bwp'
else if low__comparetext(v,'bwd1') or low__comparetext(v,'bwd#') then result:='bwd';
except;end;
try;bunlockautofree(x);except;end;
end;
//## xclosesamefiles ##
procedure tprogram.xclosesamefiles(x:tdoceditor;xfilename:string);
var
   p:longint;
begin
try
//check
if ibuildingcontrol then exit;
//get
for p:=0 to high(idoclist) do
begin
if (x<>idoclist[p]) and low__comparetext(xfilename,idoclist[p].xnavfile) then idoclist[p].xclose;
end;//p
except;end;
end;
//## xdoc ##
function tprogram.xdoc:tdoceditor;
begin
try;result:=idoclist[xdocindex];except;end;
end;
//## xdocindex ##
function tprogram.xdocindex:longint;
begin
try;result:=frcrange(idocindex,0,high(idoclist));except;end;
end;
//## xshowpage ##
procedure tprogram.xshowpage(x:longint);
begin
try
rootwin.page:='doc.'+inttostr(frcrange(x,0,high(idoclist)));
idocindex:=frcrange(x,0,high(idoclist));
except;end;
end;
//## xshowmenuFill1 ##
procedure tprogram.xshowmenuFill1(sender:tobject;xstyle:string;xmenudata:tstr8;var ximagealign:longint;var xmenuname:string);
begin
try
//check
if zznil(xmenudata,5000) then exit;

except;end;
end;
//## xshowmenuClick1 ##
function tprogram.xshowmenuClick1(sender:tbasiccontrol;xstyle:string;xcode:longint;xcode2:string;xtepcolor:longint):boolean;
begin
try
//handled
result:=true;
//get
//if low__comparetext(strcopy1(xcode2,1,4),'new.') then xcmd(nil,0,xcode2)
//else
result:=false;
except;end;
end;
//## xfillinfo ##
procedure tprogram.xfillinfo;
begin
try
//if zzok(inav,7320) then inav.findinfo(iselstart,iselcount,idownindex,inavindex,ifolderindex,ifileindex,inavcount,ifoldercount,ifilecount,iisnav,iisfolder,iisfile);
//low__iroll(iinfoid,1);
except;end;
end;
//## xloadsettings ##
procedure tprogram.xloadsettings;
var
   a:tvars8;
   p:longint;
begin
try
//defaults
a:=nil;
//check
if zznil(prgsettings,5001) then exit;
//init
a:=vnew2(950);
//filter
a.b['max']  :=prgsettings.bdef('max',false);
a.s['backupfolder']:=prgsettings.sdef('backupfolder','');
a.c['writingtime']:=prgsettings.idef64('writingtime',0);
a.c['writingwords']:=prgsettings.idef64('writingwords',0);
a.b['showlog']  :=prgsettings.bdef('showlog',true);
a.i['docindex'] :=prgsettings.idef2('docindex',0,0,high(idoclist));
a.b['autoview'] :=prgsettings.bdef('autoview',true);
a.b['shownav'] :=prgsettings.bdef('shownav',true);
a.b['backup'] :=prgsettings.bdef('backup',true);
a.b['main.use'] :=prgsettings.bdef('main.use',true);
a.b['sup1.use'] :=prgsettings.bdef('sup1.use',true);
a.b['sup2.use'] :=prgsettings.bdef('sup2.use',true);
a.s['find.text']:=prgsettings.sdef('find.text','');
for p:=0 to high(idoclist) do idoclist[p].xloadsettings('doc'+inttostr(p),a);
//sync
prgsettings.data:=a.data;
//set
//.writing
xwritingreset;
iwritingtime:=a.c['writingtime'];
iwritingwords:=a.c['writingwords'];
//.other
ibackupfolder:=low__readportablefilename(a.s['backupfolder']);
idocindex:=a.i['docindex'];
ishowlog:=a.b['showlog'];
ibackup:=a.b['backup'];
iautoview:=a.b['autoview'];
ishownav:=a.b['shownav'];
xshowpage(idocindex);
sysdic_main_use:=a.b['main.use'];
sysdic_sup1_use:=a.b['sup1.use'];
sysdic_sup2_use:=a.b['sup2.use'];
sysfind_text:=a.s['find.text'];
//.max
if (not iloaded) and a.b['max'] then gui.maxscreen:=a.b['max'];
except;end;
try
freeobj(@a);
iloaded:=true;
except;end;
end;
//## xsavesettings ##
procedure tprogram.xsavesettings;
var
   a:tvars8;
   p:longint;
begin
try
//check
if not iloaded then exit;
//defaults
a:=nil;
a:=vnew2(951);
//get
a.b['max']:=gui.maxscreen;
a.c['writingtime']:=iwritingtime;
a.c['writingwords']:=iwritingwords;
a.b['showlog']:=ishowlog;
a.i['docindex']:=xdocindex;
a.b['autoview']:=iautoview;
a.b['shownav']:=ishownav;
a.b['backup']:=ibackup;
a.b['main.use']:=sysdic_main_use;
a.b['sup1.use']:=sysdic_sup1_use;
a.b['sup2.use']:=sysdic_sup2_use;
a.s['find.text']:=sysfind_text;
a.s['backupfolder']:=low__makeportablefilename(ibackupfolder);
for p:=0 to high(idoclist) do idoclist[p].xsavesettings('doc'+inttostr(p),a);
//set
prgsettings.data:=a.data;
siSaveprgsettings;
except;end;
try;freeobj(@a);except;end;
end;
//## xautosavesettings ##
procedure tprogram.xautosavesettings(xfull:boolean);
var
   bol1:boolean;
   p:longint;
begin
try
//check
if not iloaded then exit;
//get
bol1:=false;
for p:=0 to high(idoclist) do if idoclist[p].xmustsavesettings then bol1:=true;
if low__setstr(isettingsref,bnc(gui.maxscreen)+bnc(ishownav)+bnc(iautoview)+bnc(ibackup)+bnc(ishowlog)+'|'+inttostr(xdocindex)+'|'+bnc(sysdic_main_use)+bnc(sysdic_sup1_use)+bnc(sysdic_sup2_use)+#7+ibackupfolder+#7+sysfind_text) then bol1:=true;
if xfull and low__setstr(isettingsref2,low__64(iwritingtime)+'|'+low__64(iwritingwords)) then bol1:=true;
//set
if bol1 then xsavesettings;
except;end;
end;
//## xwritingreset ##
procedure tprogram.xwritingreset;
begin
try
iwritingtime:=0;
iwritingwords:=0;
iwritingwordsREF:=0;
iwritingwordsREF2:='';
except;end;
end;
//## __onclick ##
procedure tprogram.__onclick(sender:tobject);
begin
try;xcmd(sender,0,'');except;end;
end;
//## xsplitnameonlastdash ##
procedure tprogram.xsplitnameonlastdash(x:string;var v1,v2:string);//07oct2022
var
   xname:string;
   p:longint;
   //## xfindextset ##
   function xfindextset:string;
   var
      p:longint;
   begin
   try
   result:=xname;
   if (result<>'') then
      begin
      for p:=1 to length(result) do if (strcopy1x(result,p,1)='.') then
         begin
         result:=strcopy1x(result,p,length(result));
         break;
         end;
      end;
   except;end;
   end;
begin
try
//init
xname:=low__extractfilename(x);
v1:=remlastext(xname);
v2:=xfindextset;//handles double extensions e.g. ".7z.ini" - 07oct2022
//get
if (xname<>'') then
   begin
   //was: for p:=1 to length(xname) do if (strcopy1x(xname,p,1)='-') then
   for p:=length(xname) downto 1 do if (strcopy1x(xname,p,1)='-') then//split on the LAST dash, allowing for custom user specific dashes such as "cursors-yellow-screenshot3.jpg" which splits to "cursors-yellow" and "screenshot3.jpg" - 09oct2022
      begin
      v1:=strcopy1x(xname,1,p-1);
      v2:=strcopy1x(xname,p,length(xname));
      break;
      end;//p
   end;
except;end;
end;
//## xcmd ##
procedure tprogram.xcmd(sender:tobject;xcode:longint;xcode2:string);
label
   redonew,skipend;
var
   xlist:tdynamicstring;
   p,xfilterindex,int1,xtepcolor:longint;
   bol1,zok:boolean;
   xname,xfolder,v1,v2,d1,d2,sf,df,e,str3,str2,str1:string;
begin//use for testing purposes only - 15mar2020
try
//defaults
xlist:=nil;
//init
zok:=zzok(sender,7455);
if zok and (sender is tbasictoolbar) then
   begin
   //ours next
   xcode:=(sender as tbasictoolbar).ocode;
   xcode2:=low__lowercase((sender as tbasictoolbar).ocode2);
   //nav toolbar handler 1st
   if (xcode2<>'nav.refresh') then
      begin
      if xdoc.xnav.xoff_toolbarevent(sender as tbasictoolbar) then goto skipend;
      end;
   end
else if zok and (sender is tbasicnav) then
   begin
   //if gui.mousedbclick and vidoubleclicks and xismidi and (not iplaying) then imustplay:=true;
   goto skipend;
   end;
//get
if (xcode2='fav') then xdoc.popfav
else if (xcode2='max.toggle') then gui.maxscreen:=not gui.maxscreen
else if (xcode2='nav.toggle') then ishownav:=not ishownav
else if (xcode2='last.toggle') then xdoc.lasttoggle
else if (xcode2='refresh') or (xcode2='nav.refresh') then//override "inav" refresh without our own
   begin
   xdoc.xreload;
//   ilastfilename:='';
   end
else if (xcode2='home') then
   begin
   xdoc.xnav.folder:='';
//   ilastfilename:='';
   end
else if (xcode2='restore.maindic') then
   begin
   if pop_query('This will restore the main dictionary to it''s original state and overwrite it.  Are you sure you wish to proceed?') then xunpackdic(true);
   end
else if (xcode2='find') then xdoc._text.findpop
else if (xcode2='spell') then xdoc.xspell
else if (xcode2='spell.add') then xdoc.xspelladd
else if (xcode2='undo') then xdoc._text.xact('undo',e)
else if (xcode2='redo') then xdoc._text.xact('redo',e)
else if (xcode2='backup') then backup

//else if (xcode2='autoplay') then iautoplay:=not iautoplay//16apr2021
else if (xcode2='folder') then
   begin
   if (xdoc.xnav.folder<>'') then runLOW(xdoc.xnav.folder,'');
   end
else if (xcode2='autoview.toggle') then iautoview:=not iautoview


else if (xcode2='test') then
   begin
   low__wordcore_str(xdoc.core^,'vpos.px','1000');
   end
else if (xcode2='test1') then
   begin
   xdoc.core.cfontsize:=32;
   end

else if (xcode2='style.inc') then
   begin
   int1:=frcrange(xdoc.style+1,0,4);
   if (int1=xdoc.style) then int1:=0;
   xdoc.style:=int1;
   end
else if (xcode2='rows.toggle') then xdoc.rows:=not xdoc.rows
else if low__comparetext(strcopy1(xcode2,1,4),'doc.') then xshowpage(strint(strcopy1(xcode2,5,length(xcode2))))
else if (xcode2='saveas') then xdoc.xsaveas
else if (xcode2='save') then xdoc.xsave
else if (xcode2='split.toggle') then xdoc.split:=not xdoc.split
else if (xcode2='log.toggle') then ishowlog:=not ishowlog
else if (xcode2='backup.toggle') then
   begin
   if (not ibackup) or pop_query('Confirm: Turn off backup support?') then ibackup:=not ibackup;
   end
else if (xcode2='time.reset') then
   begin
   if pop_query('Reset writing counter?') then xwritingreset;
   end
else if (xcode2='backup.showfolder') then runlow(low__platfolder('backups'),'')
else if (xcode2='close') then
   begin
   xdoc.xclose;
   xshowpage(frcmin(xdocindex-1,0));
   end
else if (xcode2='edit') then xdoc.xshowmenu('edit')
else if (xcode2='new.duplicate') then
   begin
   //init
   bol1:=false;
   xname:=xdoc.xnavfile;
   xfolder:=low__extractfilepath(xname);
   //filter
   xsplitnameonlastdash(xname,v1,v2);
   //get
   if (xfolder<>'') and (v1<>'') then
      begin
      str1:='';
      if gui.popedit(str1,'Type a new target name for "'+v1+'*"','Type a new product name with using a dash "-" in the name') and (str1<>'')then
         begin
         str1:=safename(str1);
         xlist:=tdynamicstring.create;
         //check to see if a more specific filename exists, if so, then we use the selected item's FULL name, else we drop to the last slash -> "cursors-yellow.zip" -> "cursors-yellow*" when "cursors-yellow-screenshot.jpg" exists else we drop to "cursors*"
         if not low__filelist(xlist,false,xfolder,remlastext(low__extractfilename(xname))+'-*','') then goto skipend;

         //.narrow down mask for best-on-target duplication - 09oct2022
         if (xlist.count>=1) then v1:=remlastext(low__extractfilename(xname));
         if not low__filelist(xlist,false,xfolder,v1+'*','') then goto skipend;

         //.duplicate selected product set - 09oct2022
         if (xlist.count>=1) then
            begin
            //duplicate files
            for p:=0 to (xlist.count-1) do
            begin
            sf:=xlist.value[p];
            d1:=strcopy1(sf,1,length(v1));
            d2:=strcopy1(sf,length(v1)+1,length(sf));
            //.prevent accidental use of another simliar named product e.g. "mask" and "maskplus" by forcing it to "mask-" or "mask." thus avoiding "maskplus-" and "maskplus." - 09oct2022
            if (d1<>'') and ( (strcopy1(sf,length(v1)+1,1)='-') or (strcopy1(sf,length(v1)+1,1)='.') ) then
               begin
               df:=str1+d2;
               if (not low__fileexists(xfolder+df)) and (not low__copyfile(xfolder+sf,xfolder+df,e)) then goto skipend;
               end;
            end;//p
            //update list
            xcmd(nil,0,'refresh');
            end;
         end;
      end
   else gui.poperror('Item selected does not have a dash "-" in it''s name and therefore cannot be duplicated safely.');
   end
else
   begin
   if system_debug then showbasic('Unknown Command>'+xcode2+'<<');
   end;
skipend:
except;end;
try
freeobj(@xlist);
except;end;
end;
//## __ontimer ##
procedure tprogram.__ontimer(sender:tobject);//._ontimer
label
   skipend;
var
   p:longint;
   str1:string;
   cmp1:comp;
begin
try
//init

//timer100
if (ms64>=itimer100) and iloaded then
   begin
   xsync;
   if (low__keyidle<1000) then
      begin
      //.time
      iwritingtime:=low__add64(iwritingtime,100);
      //.words
      if low__setstr(iwritingwordsREF2,low__lowercase(xdoc.xnavfile)) then iwritingwordsREF:=0;
      if (iwritingwordsREF=0) then iwritingwordsREF:=xdoc._text.wordcount;
      cmp1:=low__sub64(xdoc._text.wordcount,iwritingwordsREF);
      iwritingwordsREF:=xdoc._text.wordcount;
      //..incremental choke -> too much and it's probably a paste or undo/redo action -> ignore it
      if (cmp1>=1) and (cmp1<=50) then iwritingwords:=low__add64(iwritingwords,cmp1);
      end;
   //reset
   itimer100:=ms64+100;
   end;

   
//timer250
if (ms64>=itimer250) then
   begin
   //reset
   itimer250:=ms64+150;
   end;

//timer500
if (ms64>=itimer500) and iloaded then
   begin
   //.filename in top title
   str1:=xdoc.xnavfile;
   if (str1<>'') then str1:=' - '+low__insstr('*',xdoc.modified)+low__extractfilename(str1);
   rootwin.xhead.caption2:=str1;

   //savesettings
   xautosavesettings(false);
   //reset
   itimer500:=ms64+500;
   end;

//timerslow
if (ms64>=itimerslow) and iloaded then
   begin
   //savesettings
   xautosavesettings(true);//include writingtime/words check - 06feb2023
   //reset
   itimerslow:=ms64+30000;
   end;


//debug support
if system_debug then
   begin
   if system_debugFAST then rootwin.paintallnow;
   end;
if system_debug and system_debugRESIZE then
   begin
   if (system_debugwidth<=0) then system_debugwidth:=gui.host.width;
   if (system_debugheight<=0) then system_debugheight:=gui.host.height;
   //change the width and height to stress
   //was: if (random(10)=0) then gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   gui.setbounds(gui.left,gui.top,system_debugwidth+random(32)-16,system_debugheight+random(128)-64);
   end;

skipend:
except;end;
end;
//## xsync ##
procedure tprogram.xsync;
var
   adocindex,p:longint;
   x:tdoceditor;
   str1,str2:string;
   xtextOK,xshownav,xhavefile:boolean;
   cmp1:comp;
begin
try
//check
//if gui.mousedown then exit;
adocindex:=xdocindex;

//init
x:=xdoc;
xhavefile:=(x.xnavfile<>'');
xshownav:=ishownav;
xtextOK:=x.textshowing;

//get
//.doc editors
for p:=0 to high(idoclist) do
begin
idoclist[p].shownav:=xshownav;
idoclist[p].showlog:=ishowlog;
idoclist[p].backup:=ibackup;
idoclist[p].xsmartsync;
rootwin.xtoolbar2.btep2['doc.'+inttostr(p)]:=idoclist[p].xbuttep;
rootwin.xtoolbar2.bcap2['doc.'+inttostr(p)]:=inttostr(p+1)+'. '+idoclist[p].xbutcap;
rootwin.xtoolbar2.bvisible[p]:=true;
//rootwin.xtoolbar2.bhighlight2['doc.'+inttostr(p)]:=(p=adocindex);
rootwin.xtoolbar2.bmarked2['doc.'+inttostr(p)]:=(p=adocindex);
end;//p

//.buttons
rootwin.xtoolbar.benabled2['nav.prev']:=xdoc.xnav.canprev;
rootwin.xtoolbar.benabled2['nav.next']:=xdoc.xnav.cannext;
//rootwin.xtoolbar.bmarked2['wrap.toggle']:=(x.wrap>=1);
rootwin.xtoolbar.bmarked2['rows.toggle']:=x.rows;
//rootwin.xtoolbar.bmarked2['autoview.toggle']:=iautoview;
rootwin.xtoolbar.bmarked2['log.toggle']:=ishowlog;
rootwin.xtoolbar.bmarked2['split.toggle']:=x.split;
rootwin.xtoolbar.bmarked2['nav.toggle']:=xshownav;
rootwin.xtoolbar.bmarked2['max.toggle']:=gui.maxscreen;

rootwin.xtoolbar.benabled2['text.paste']:=xtextOK;//19apr2022

rootwin.xtoolbar.benabled2['find']:=xtextOK and xhavefile and xdoc.xcanfind;

rootwin.xtoolbar.benabled2['spell']:=xtextOK and xhavefile and xdoc.xcanspell;
rootwin.xtoolbar.benabled2['spell.add']:=xtextOK and xhavefile and xdoc.xcanspelladd;

rootwin.xtoolbar.benabled2['undo']:=xtextOK and xhavefile and xdoc._text.canundo;
rootwin.xtoolbar.benabled2['redo']:=xtextOK and xhavefile and xdoc._text.canredo;

rootwin.xtoolbar.benabled2['save']:=xtextOK and xhavefile and xdoc.cansave and xdoc.modified;
rootwin.xtoolbar.benabled2['backup']:=canbackup;

rootwin.xtoolbar.benabled2['last.toggle']:=xdoc.canlast;

rootwin.xtoolbar.bvisible2['refresh']:=xshownav;
rootwin.xtoolbar.bvisible2['fav']:=xshownav;
rootwin.xtoolbar.bvisible2['close']:=xshownav;


//.status2
rootwin.xstatus2.celltext[0]:='Page: '+low__64(xdoc._text.page)+' / '+low__64(xdoc._text.pages);
rootwin.xstatus2.celltext[1]:='Line: '+low__64(1+low__wordcore_str2(xdoc.core^,'pos>line',inttostr(xdoc.cpos)))+' / '+low__64(1+low__wordcore_str2(xdoc.core^,'pos>line',inttostr(maxint)));

rootwin.xstatus2.celltext[2]:='Words: '+low__64(xdoc._text.wordcount);
//was: rootwin.xstatus2.cellpert[2]:=low__percentage64(xdoc._text.wordcount,5000);


//.wrap
case xdoc.style of
0:str1:='None';
1:str1:='Window';
2:str1:='Page';
3:str1:='Page + 2x';
4:str1:='Manuscript';
else str1:='?';
end;
rootwin.xstatus2.celltext[3]:='Wrap: '+str1;
rootwin.xstatus2.cellname[3]:='style.inc';

rootwin.xstatus2.celltext[4]:='Rows: '+low__aorbstr('Off','On',xdoc.rows);
rootwin.xstatus2.cellname[4]:='rows.toggle';


rootwin.xstatus2.celltext[5]:='Nav: '+low__aorbstr('Hide','Show',xshownav);
rootwin.xstatus2.cellname[5]:='nav.toggle';


rootwin.xstatus2.celltext[6]:='Time: '+low__dhmslabel(iwritingtime);
rootwin.xstatus2.cellname[6]:='time.reset';

rootwin.xstatus2.celltext[7]:='Typed: '+low__64(iwritingwords)+'w';
rootwin.xstatus2.cellname[7]:='time.reset';

//.rate
cmp1:=low__div64(low__mult64(3600,iwritingwords),low__div64(iwritingtime,1000));
rootwin.xstatus2.celltext[8]:='Rate: '+low__64(cmp1)+'w /hr';
rootwin.xstatus2.cellname[8]:='time.reset';
rootwin.xstatus2.cellpert[8]:=low__percentage64(cmp1,5000);//0..100% -> 0..5,000 w/hr


rootwin.xstatus2.celltext[9]:='Backup: '+low__aorbstr('Off','On'+low__insstr(' / '+low__64(systrack_backupcount)+' made',systrack_backupcount>=1),ibackup);
rootwin.xstatus2.cellname[9]:='backup.toggle';
except;end;
end;
//## xlognameclear ##
procedure tprogram.xlognameclear;
begin
try;ilognamecount:=0;except;end;
end;
//## xlognameadd ##
procedure tprogram.xlognameadd(xlogname:string);
begin
try
if (ilognamecount<=high(ilognamelist)) then
   begin
   ilognamelist[ilognamecount]:=low__udv(xlogname,'(none)');
   inc(ilognamecount);
   end;
except;end;
end;
//## xlognamedel ##
procedure tprogram.xlognamedel;
begin
try;ilognamecount:=frcmin(ilognamecount-1,0);except;end;
end;
//## xshow ##
procedure tprogram.xshow(xmsg:string);
begin
try;xdoc.logadd(xmsg+#10);except;end;
end;
//## xshowerror ##
function tprogram.xshowerror(xmsg,xmorechain:string):boolean;
begin
try;result:=true;inc(ierrorcount);xshow('ERROR: '+xmsg+#32+'['+xmorechain+']');except;end;
end;
//## xshowwarn ##
function tprogram.xshowwarn(xmsg,xmorechain:string):boolean;
begin
try;result:=true;inc(iwarncount);xshow('WARN: '+xmsg+#32+'['+xmorechain+']');except;end;
end;
//## xshowinfo ##
function tprogram.xshowinfo(xmsg,xmorechain:string):boolean;
begin
try;result:=true;xshow('INFO: '+xmsg+#32+'['+xmorechain+']');except;end;
end;


//## low__chapterfileOK ##
function low__chapterfileOK(xfilename:string):boolean;
var
   p:longint;
begin
try
//defaults
result:=false;
//get
xfilename:=low__extractfilename(xfilename);
if (xfilename<>'') then
   begin
   for p:=1 to length(xfilename) do if (strbyte1x(xfilename,p)=ssunderscore) and (strbyte1x(xfilename,p+1)=ssunderscore) then
      begin
      result:=true;
      break;
      end;//p
   end;
except;end;
end;

//## low__lastfoldername ##
function low__lastfoldername(xfolder,xdefaultname:string):string;
var
   str1:string;
   p:longint;
begin
try
//defaults
result:=xdefaultname;
//get
str1:=asfolderNIL(xfolder);
if (str1<>'') then
   begin
   for p:=(length(str1)-1) downto 1 do
   begin
   if (strbyte1x(str1,p)=ssbackslash) or (strbyte1x(str1,p)=ssslash) then
      begin
      str1:=strcopy1(str1,p+1,length(str1));
      break;
      end;
   end;//p
   //.trim trailing slash
   if (str1<>'') and ((strbyte1x(str1,length(str1))=ssbackslash) or (strbyte1x(str1,length(str1))=ssslash)) then str1:=strcopy1(str1,1,length(str1)-1);
   //set
   if (str1<>'') then result:=str1;
   end;
except;end;
end;


initialization
   siInit;

finalization
   siHalt;

end.
