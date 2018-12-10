/*******************************************************************************
|
| Name   : sim_tools_example1.sas
| Purpose: Examples of using macros and FCMP Functions from sim_tools.
| Version: 9.4
| Author : T Drury
|
********************************************************************************/;

*** INCLUDE MACROS AND FUNCTIONS ***;
options source2;
filename code1 url "https://raw.githubusercontent.com/squiffy-statto/sim_tools/master/sim_tools.sas";
%include code1;


*** SIMPLE USAGE OF START TIME AND STOPTIME ***;

%starttime();
data a;
  do i = 1 to 10000;
  do j = 1 to 10000;
    output;
  end;
  end;
run;
%stoptime();


%starttime();
data b;
  do i = 1 to 10000;
  do j = 1 to 20000;
    output;
  end;
  end;
run;
%stoptime();



*** COMPLEX USAGE OF MULTIPLE STARTTIMES AND STOPTIME ***;

%starttime(startid=time1);
data a;
  do i = 1 to 10000;
  do j = 1 to 10000;
    output;
  end;
  end;
run;

%starttime(startid=time2);
data b;
  do i = 1 to 10000;
  do j = 1 to 10000;
    output;
  end;
  end;
run;

%starttime(startid=time3);
data c;
  do i = 1 to 10000;
  do j = 1 to 20000;
    output;
  end;
  end;
run;

%stoptime(startid=%str(time1,time2,time3));

proc datasets lib = work noprint;
  delete a b c;
run;
quit;







