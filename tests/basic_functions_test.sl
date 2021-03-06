
% 2014.08.13 - lia
%
% Test to be sure that basic functions work
%
%% NOTE: On first run, be sure to uncomment test_autoname_outfile
%% All of the test function calls are listed at the end

_traceback = 1;

require("xstardb");

%%---------------------------------------%%
%% Test of autoname outfile

variable x1, x2, y;
(x1, x2) = linear_grid( 1.0, 40.0, 16384 );

define test_autoname_outfile()
{
    fit_fun( "Powerlaw(1) * warmabs2(1) + photemis2(123)"  );
    set_par( "warmabs2(1).write_outfile",  1 );
    set_par( "photemis2(123).write_outfile",  1 );
    set_par( "*.autoname_outfile", 1 );
    
    y = eval_fun(x1, x2);
}


%%---------------------------------------%%
%% Test of read db functions

variable wa, pe;

define test_read_db()
{
    wa = rd_xstar_output("warmabs_1.fits");
    pe = rd_xstar_output("photemis_123.fits");
}

%%---------- After first autoname, must load dbs ----------%%

%test_autoname_outfile;
test_read_db;

%%---------------------------------------%%
%% Test of wavelength selection from db
%% And qualifiers "elem" and "ion"

variable MIN = 3.0, MAX = 3.5;
variable iwa = where(xstar_wl(wa, MIN, MAX));
variable ipe = where(xstar_wl(pe, MIN, MAX));

define test_xstar_wl()
{
    message("Features selected from warmabs model:");
    xstar_page_group(wa, iwa);

    message("Features selected from photemis model:");
    xstar_page_group(pe, ipe);

    message("Test the redshift parameter on phoetemis features:");
    xstar_page_group(pe, ipe; redshift=0.1);

    message("The above transitions are in the wrong range.\nTest the redshift features on xstar_wl with wa");
    variable iwa_z = where( xstar_wl(wa, MIN, MAX; redshift=0.1) );
    xstar_page_group(wa, iwa_z; redshift=0.1);
}

% Test boolean stringing together of xstar_wl with others

define test_xstar_el_ion()
{
    message("Testing xstar_el_ion function, return Ca and Fe lines only");
    variable iwa2 = where( xstar_el_ion(wa, [Ca,Fe]) and xstar_wl(wa,1,40) );
    xstar_page_group(wa, iwa2);

    message("Testing xstar_el_ion function, return Fe I and III lines only");
    variable iwa3 = where( xstar_el_ion(wa, Fe, [1,3]) and xstar_wl(wa,1,40) );
    xstar_page_group(wa, iwa3);

    message("Testing xstar_el_ion function, return Ca V only");
    variable iwa4 = where( xstar_el_ion(wa, Ca, 5) and xstar_wl(wa,1,40) );
    xstar_page_group(wa, iwa4);
}

% Test output of xstar_trans

define test_xstar_trans()
{
    message("Testing xstar_trans, return OIII lines only");
    variable o_iii = where( xstar_trans(wa, O, 3) );
    xstar_page_group(wa, o_iii);

    message("Testing xstar_trans, return OIII transitions into the ground state");
    variable o_iii_ground = where( xstar_trans(wa, O, 3, 1) );
    xstar_page_group(wa, o_iii_ground);

    message("Testing xstar_trans, return OVII helium triplet only");
    variable o_vii_triplet = where( xstar_trans(wa, O, 7, 1, [2:7]) );
    xstar_page_group(wa, o_vii_triplet);
}

%%---------------------------------------%%
%% Test xstar_strong and qualifiers
%% This also tests the xstar_page_group sorting qualifiers

variable nstrong = 10;
variable iwa_strong = xstar_strong(nstrong, wa; wmin=MIN, wmax=MAX);

% warmabs default: field="ew" and emis=0
define test_xstar_strong()
{
    variable wa_ew = get_struct_field(wa,"ew")[iwa];
    variable isort = array_sort(wa_ew);
    
    message("The largest equiv widths:");
    print(wa_ew[isort[[-nstrong:]]]);

    message("The list returned from xstar_strong, sorted by EW");
    xstar_page_group(wa, iwa_strong; sort="ew");

    message("Test the limit qualifier by returning ew values above 0.5");
    xstar_page_group(wa, xstar_strong(1000, wa; limit=0.5); sort="ew");
}
%% Okay, this is correct (note difference in format)

%%---------------------------------------%%
%% Test sorting cases for xstar_page_group

define test_xstar_page_group_sorting()
{
    message("Sorting photoemis by luminosity");
    xstar_page_group(pe, ipe; sort="luminosity");
    
    message("Sorting photoemis by nothing");
    xstar_page_group(pe, ipe; sort="none");

    message("Sorting warmabs by tau0");
    xstar_page_group(wa, iwa[[0:10]]; sort="tau0");

    message("Sorting warmabs by a_ij");
    xstar_page_group(wa, iwa[[0:10]]; sort="a_ij");
}

%%---------------------------------------%%
%% Test plotting with xstar_plot_group

%% Using range 3.0 - 3.1 Angs, plot iwa_strong lines

define test_xstar_plot_group()
{
    plot_bin_density;
    xlabel( latex2pg( "Wavelength [\\A]" ) ) ; 
    ylabel( latex2pg( "Flux [phot/cm^2/s/A]" ) );
    xrange(3.0,3.1);
    hplot(x1, x2, y, 1);
    xstar_plot_group(wa, iwa_strong, 5);
    
    variable style = line_label_default_style();
    style.angle = -25.0;
    style.top_frac = 0.65;
    style.bottom_frac = 0.8;
    style.offset = 0.5;
    style.label_type = 1; 
    xstar_plot_group(wa, iwa_strong, 3, style);
}

%% Another range that shows a multitude of blended lines: 
%%    18-20 (Includes an edge)
%%    19-20 (Close up of many blended features)


%%------- TEST FUNCTION CALLS ----------------%%
%% Modify this portion to turn on various tests

%test_xstar_plot_group();

%test_xstar_wl;
%test_xstar_el_ion;
%test_xstar_trans;

test_xstar_strong;

%test_xstar_page_group_sorting;


