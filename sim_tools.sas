/*******************************************************************************
| Name   : sim_tools.sas
| Purpose: Creates helper macros and FCMP functions for simulation tasks
| Version: 9.4
| Author : T Drury
|--------------------------------------------------------------------------------
| Macros List:
|--------------------------------------------------------------------------------
| ODSOFF     : Turns off all ODS table and graphs and stops results being created
| Parameters : notesyn = [OPT] stops notes being written to the log.
|
|--------------------------------------------------------------------------------
| ODSON      : Turns on all ODS tables and graphs and restarts results creation
| Parameters : NONE
|
|--------------------------------------------------------------------------------
| STARTTIME : Creates macros variables for the current time to allow the timing 
|             of long running programs.
| Parameters: reportyn = Y [OPT] Creates Message in Log
|             startid  = starttime1 [OPT] Creates specific name for timepoint
|
|--------------------------------------------------------------------------------
| STOPTIME : Creates macros variables for the current time to allow the timing 
|            of long running programs then calculates time elapsed from start
|            time IDs supplied of looks for the default STARTTIME1.
| Parameters: reportyn = Y [OPT] Creates Message in Log
|             stopid   = starttime1 [OPT] Creates specific name for timepoint
|             startid  = [OPT] Comma seperated list of timepoints to calculate 
|                        elapsed time.
|
|--------------------------------------------------------------------------------
| FCMP Functions List:
|--------------------------------------------------------------------------------
| NONE
*********************************************************************************/;


**********************************************************************************;
*** MACRO: ODSOFF                                                              ***;
**********************************************************************************;

%macro odsoff(notesyn=Y);
ods select none;
ods results off;
ods graphics off;
%if &notesyn. = N %then %do; options nonotes; %end;
%mend;


**********************************************************************************;
*** MACRO: ODSON                                                               ***;
**********************************************************************************;

%macro odson;
ods select all;
ods results on;
ods graphics on;
options notes;
%mend;


**********************************************************************************;
*** MACRO: STARTTIME                                                           ***;
**********************************************************************************;

%macro starttime(reportyn=Y
                ,startid=starttime1);

  %let toolname = STARTTIME;
  %global &startid.;

  %*** CREATE DEFAULT IF PARAMETER SET TO MISSING ***; 
  %if %length(&startid.) = 0 %then %let startid=starttime1;

  %*** LOG START TIME FOR PARALLEL MACRO ***;
  %let &startid. = %sysfunc(datetime());

  %*** IF REQUESTED PRINT TO LOG ***;
  %if &reportyn. = Y %then %do;

   %put NO%upcase(te:(&toolname.)):--------------------------------------------------------------------;
   %put NO%upcase(te:(&toolname.)): Start Time Request: %left(%sysfunc(putn(&&&startid., datetime18.)));
   %put NO%upcase(te:(&toolname.)): Start Time ID:      %upcase(&startid.);
   %put NO%upcase(te:(&toolname.)):--------------------------------------------------------------------; 

  %end;

%mend;


**********************************************************************************;
*** MACRO: STOPTIME                                                            ***;
**********************************************************************************;

%macro stoptime(reportyn= Y
               ,stopid  = stoptime1
               ,startid =);

  %let toolname = STOPTIME;
  %global &stopid.;

  %*** CREATE DEFAULT IF PARAMETER SET TO MISSING ***; 
  %if %length(&stopid.) = 0 %then %let stopidid=stoptime1;

  %*** LOG STOP TIME MACRO ***;
  %let &stopid. = %sysfunc(datetime());

  %*** IF REQUESTED PRINT TO LOG ***;
  %if &reportyn. = Y %then %do;

    %*** BASIC STOP TIME INFORMATION ***;
    %put NO%upcase(te:(&toolname.)):--------------------------------------------------------------------; 
    %put NO%upcase(te:(&toolname.)): Stop Time Request: %left(%sysfunc(putn(&&&stopid., datetime18.)));
    %put NO%upcase(te:(&toolname.)): Stop Time ID:      %upcase(&stopid.);
    %put NO%upcase(te:(&toolname.)):--------------------------------------------------------------------; 

    %*** COUNT START IDS VALUES SUPPLIED ***;
    %let startn = %sysfunc(countw(&startid.,%str(,)));

    %*** IF NO START IDS SUPPLIED CHECK FOR DEFAULT NAME ***;
    %if &startn. = 0 %then %do;
      %if %symexist(starttime1) %then %do;

        %let start  = starttime1;
        %let time   = %sysfunc(sum(&&&stopid.,-&&&start.));
        %let dd     = %sysfunc(putn(%sysfunc(int(%sysevalf( (&time.) / (24*60*60) ) )),z2.));
        %let hh     = %sysfunc(putn(%sysfunc(int(%sysevalf( (&time. - &dd.*24*60*60) / (60*60) ) )),z2.));
        %let mm     = %sysfunc(putn(%sysfunc(int(%sysevalf( (&time. - &dd.*24*60*60 - &hh.*60*60) / 60 ) )),z2.));
        %let ss     = %sysfunc(putn(%sysfunc(int(%sysevalf( (&time. - &dd.*24*60*60 - &hh.*60*60 - &mm.*60) ) )),z2.));

        %put NO%upcase(te:(&toolname.)): Processing Time Since:;
        %put NO%upcase(te:(&toolname.)): %sysfunc(putc(%upcase(&start.),$21.)): &dd.:&hh.:&mm.:&ss. (dd:hh:mm:ss).; 

      %end;
      %else %do; 
        %put NO%upcase(te:(&toolname.)): No Explicit or Default Start Time IDs Found.;
      %end;
    %end;
    %else %do;

      %put NO%upcase(te:(&toolname.)): Processing Time Since:;
      %do ii = 1 %to &startn.;
        %let start = %scan(&startid.,&ii.,%str(,));
        %let time  = %sysfunc(sum(&&&stopid.,-&&&start.));
        %let dd    = %sysfunc(putn(%sysfunc(int(%sysevalf( (&time.) / (24*60*60) ) )),z2.));
        %let hh    = %sysfunc(putn(%sysfunc(int(%sysevalf( (&time. - &dd.*24*60*60) / (60*60) ) )),z2.));
        %let mm    = %sysfunc(putn(%sysfunc(int(%sysevalf( (&time. - &dd.*24*60*60 - &hh.*60*60) / 60 ) )),z2.));
        %let ss    = %sysfunc(putn(%sysfunc(int(%sysevalf( (&time. - &dd.*24*60*60 - &hh.*60*60 - &mm.*60) ) )),z2.));
        %put NO%upcase(te:(&toolname.)): %sysfunc(putc(%upcase(&start.),$21.)): &dd.:&hh.:&mm.:&ss. (dd:hh:mm:ss).; 
      %end;
    %end;
    %put NO%upcase(te:(&toolname.)):--------------------------------------------------------------------; 

  %end;

%mend;


