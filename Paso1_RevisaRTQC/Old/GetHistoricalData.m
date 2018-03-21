function [pa_grid_lat,pa_grid_long,pa_grid_dates,pa_grid_pres,pa_grid_temp,pa_grid_sal] = GetHistoricalData(pn_float_long,pn_float_lat,pa_float_name) ;
[pa_wmo_numbers ]=findWMOboxes(pn_float_long,pn_float_lat);
po_config_data.HISTORICAL_DIRECTORY='/Users/pvb/Data/Argo/Climatology';
po_config_data.HISTORICAL_CTD_PREFIX='/Historical_ctd/CTD_for_DMQC_2010V1/ctd_';
po_config_data.HISTORICAL_BOTTLE_PREFIX='/Historical_bot/bot_';
po_config_data.HISTORICAL_ARGO_PREFIX='/Argo_profiles/ARGO_for_DMQC_2010V04/argo_';

%retr_region_ow( pa_wmo_numbers, pa_float_name, po_config_data) ;

% This function retrieves historical data from the 9 selected WMO boxes,
% merges the CTD, BOT and Argo files, makes sure longitude is continuous
% around the 0-360 degree mark, and converts the dates of the
% historical data from time format2 to year.mo+ (changedates.m).
%
% pa_wmo_numbers can be NaN: when float profiles are out of range (65N, 65S),
% or when there's no .mat file in that box, denoted by 0 (e.g. box on land).
%
% Historical data have lat,long and dates organised in single rows.
% The output from this function gives lat,long and dates in columns,
% just for ease of checking .... really doesn't matter.
%
% Annie Wong, December 2007.
%
% modified from get_region.m, Dec 2006, Breck Owens.
%

max_p = 2000; % max depth to retrieve historical data

%pa_index_0 = 0;

pa_grid_sal   = [ ] ;
pa_grid_temp  = [ ] ;
pa_grid_pres  = [ ] ;
pa_grid_lat   = [ ] ;
pa_grid_long  = [ ] ;
pa_grid_dates = [ ] ;

%[ max_depth, how_many_cols ] = size(pa_grid_pres);

for ln_index = 1:length(pa_wmo_numbers)
    for ntyp = 2:4
        if( ~isnan(pa_wmo_numbers(ln_index,1)) & pa_wmo_numbers(ln_index,ntyp) ) % check to see if we are supposed to load this data type
            if ntyp == 2 % the 2nd column denotes CTD data
                lo_box_data = load( strcat( po_config_data.HISTORICAL_DIRECTORY, po_config_data.HISTORICAL_CTD_PREFIX, sprintf( '%4d', pa_wmo_numbers(ln_index,1))));
            elseif ntyp == 3 % the 3rd column denotes historical data
                lo_box_data = load( strcat( po_config_data.HISTORICAL_DIRECTORY, po_config_data.HISTORICAL_BOTTLE_PREFIX, sprintf( '%4d', pa_wmo_numbers(ln_index,1))));
            elseif ntyp == 4 % the 4th column denotes Argo data
                lo_box_data = load( strcat( po_config_data.HISTORICAL_DIRECTORY, po_config_data.HISTORICAL_ARGO_PREFIX, sprintf( '%4d', pa_wmo_numbers(ln_index,1))));
                % exclude Argo float being analysed from the Argo reference data selection,
                % must do this step before concatenating the vectors, because "index" comes
                % from "get_region_ow.m", which includes this step ---------------------
                not_use=[];
                for i=1:length(lo_box_data.lat)
                    profile=lo_box_data.source{i};
                    jj=findstr(profile,'_');
                    ref_float=profile(1:jj-1);
                    kk=findstr(pa_float_name, ref_float);
                    if(isempty(kk)==0)
                        not_use=[not_use,i];
                    end
                end
                lo_box_data.lat(not_use)=[];
                lo_box_data.long(not_use)=[];
                lo_box_data.dates(not_use)=[];
                lo_box_data.sal(:,not_use)=[];
                lo_box_data.temp(:,not_use)=[];
                lo_box_data.pres(:,not_use)=[];
                lo_box_data.temp(:,not_use)=[];
                %-----------------------------------------------------------------------
            end
            pa_grid_sal   = merge(pa_grid_sal, lo_box_data.sal);
            pa_grid_temp  = merge(pa_grid_temp, lo_box_data.temp);
            pa_grid_pres  = merge(pa_grid_pres, lo_box_data.pres);
            pa_grid_lat   = merge(pa_grid_lat, lo_box_data.lat);
            pa_grid_long  = merge(pa_grid_long, lo_box_data.long);
            pa_grid_dates = merge(pa_grid_dates, lo_box_data.dates);
        end
    end
end

% longitude goes from 0 to 360 degrees
ln_jj = find( pa_grid_long < 0 ) ;
pa_grid_long( ln_jj ) = 360 + pa_grid_long( ln_jj ) ;


% make sure longitude is continuous around the 0-360 degree mark
ln_kk = find( pa_grid_long>=320 & pa_grid_long<=360 ) ;
if( isempty( ln_kk ) == 0 )
    ln_ll = find( pa_grid_long>=0 & pa_grid_long<=40 ) ;
    pa_grid_long( ln_ll ) = 360 + pa_grid_long( ln_ll ) ;
end

% make pa_grid_sal, pa_grid_temp, pa_grid_pres have the same NaNs
ln_ii = find( isnan( pa_grid_sal ) == 1 ) ;
pa_grid_pres( ln_ii ) = NaN.*ones( 1, length( ln_ii ) ) ;
pa_grid_temp( ln_ii ) = NaN.*ones( 1, length( ln_ii ) ) ;
ln_ii = find( isnan( pa_grid_pres ) == 1 ) ;
pa_grid_sal( ln_ii ) = NaN.*ones( 1, length( ln_ii ) ) ;
pa_grid_temp( ln_ii ) = NaN.*ones( 1, length( ln_ii ) ) ;
ln_ii = find( isnan( pa_grid_temp ) == 1 ) ;
pa_grid_sal( ln_ii ) = NaN.*ones( 1, length( ln_ii ) ) ;
pa_grid_pres( ln_ii ) = NaN.*ones( 1, length( ln_ii ) ) ;

pa_grid_dates = changedates( pa_grid_dates ) ;

% turns rows into columns
pa_grid_lat = pa_grid_lat' ;
pa_grid_long = pa_grid_long' ;


function [ pa_wmo_numbers ] = findWMOboxes(pn_float_long,pn_float_lat) ;
% This function finds 5x5=25 WMO boxes with the float profile in the centre.
% The WMO box numbers, between 90N and 90S, are stored in wmo_boxes.mat.
% The 1st column has the box numbers, the 2nd column denotes CTD data,
% the 3rd column denotes bottle data, the 4th column denotes Argo data.
% No data is denoted by 0. Otherwise 1.
%
% A. Wong, 16 August 2004
%
pa_wmo_numbers = [ NaN.*ones( 9, 1 ), zeros( 9, 1 ), zeros( 9, 1 ), zeros( 9, 1 ) ] ;
load WMO_Boxes

la_lookup_x = [ ] ;
la_lookup_y = [ ] ;
vector_x = [] ;
vector_y = [] ;

la_x = [ 5:10:355 ] ; % 36 elements
for i=1:18
    la_lookup_x = [ la_lookup_x; la_x ] ;
end

la_y = [ 85:-10:-85 ] ; % 18 elements
for i=1:36
    la_lookup_y = [ la_lookup_y, la_y' ];
    vector_y = [ vector_y; la_y' ];
    vector_x = [ vector_x; la_x(i).*ones(18,1) ];
end

la_lookup_no=reshape( [ 1:648 ], 18, 36 ) ;

ln_x1 = pn_float_long +.01;
ln_x2 = pn_float_long + 10.01;
ln_x3 = pn_float_long - 9.99;

ln_y1 = pn_float_lat + .01;
ln_y2 = pn_float_lat + 10.01;
ln_y3 = pn_float_lat - 9.99;

% interp2 will treat 360 as out of range, but will interpolate 0

if( ln_x3<0 )ln_x3=360+ln_x3;end;
if( ln_x1>=360 )ln_x1=ln_x1-360;end
if( ln_x2>=360 )ln_x2=ln_x2-360;end

if( isnan(pn_float_lat)==0&isnan(pn_float_long)==0 )
    ln_i1 = interp2( la_lookup_x, la_lookup_y, la_lookup_no, ln_x1, ln_y1, 'nearest' ) ;
    ln_i2 = interp2( la_lookup_x, la_lookup_y, la_lookup_no, ln_x2, ln_y1, 'nearest' ) ;
    ln_i3 = interp2( la_lookup_x, la_lookup_y, la_lookup_no, ln_x3, ln_y1, 'nearest' ) ;
    ln_i4 = interp2( la_lookup_x, la_lookup_y, la_lookup_no, ln_x1, ln_y2, 'nearest' ) ;
    ln_i5 = interp2( la_lookup_x, la_lookup_y, la_lookup_no, ln_x2, ln_y2, 'nearest' ) ;
    ln_i6 = interp2( la_lookup_x, la_lookup_y, la_lookup_no, ln_x3, ln_y2, 'nearest' ) ;
    ln_i7= interp2( la_lookup_x, la_lookup_y, la_lookup_no, ln_x1, ln_y3, 'nearest' ) ;
    ln_i8= interp2( la_lookup_x, la_lookup_y, la_lookup_no, ln_x2, ln_y3, 'nearest' ) ;
    ln_i9= interp2( la_lookup_x, la_lookup_y, la_lookup_no, ln_x3, ln_y3, 'nearest' ) ;
else
    ln_i1 = NaN ;
    ln_i2 = NaN ;
    ln_i3 = NaN ;
    ln_i4 = NaN ;
    ln_i5 = NaN ;
    ln_i6 = NaN ;
    ln_i7 = NaN ;
    ln_i8 = NaN ;
end

if( isnan(ln_i1)==0 )pa_wmo_numbers(1,:)=la_wmo_boxes(ln_i1,:);end;
if( isnan(ln_i2)==0 )pa_wmo_numbers(2,:)=la_wmo_boxes(ln_i2,:);end;
if( isnan(ln_i3)==0 )pa_wmo_numbers(3,:)=la_wmo_boxes(ln_i3,:);end;
if( isnan(ln_i4)==0 )pa_wmo_numbers(4,:)=la_wmo_boxes(ln_i4,:);end;
if( isnan(ln_i5)==0 )pa_wmo_numbers(5,:)=la_wmo_boxes(ln_i5,:);end;
if( isnan(ln_i6)==0 )pa_wmo_numbers(6,:)=la_wmo_boxes(ln_i6,:);end;
if( isnan(ln_i7)==0 )pa_wmo_numbers(7,:)=la_wmo_boxes(ln_i7,:);end;
if( isnan(ln_i8)==0 )pa_wmo_numbers(8,:)=la_wmo_boxes(ln_i8,:);end;
if( isnan(ln_i9)==0 )pa_wmo_numbers(9,:)=la_wmo_boxes(ln_i9,:);end;


function [dates]=changedates(dates_format2);

% This function changes dates in format YYYYMMDDhhmmss to a
% decimal number. The input dates can be in either a single
% row or a single column, but the output dates are organised
% in a single column.
%
% A. Wong, 29 May 2001
%

dates=NaN.*ones(length(dates_format2),1); %organise dates in a single column

for i=1:length(dates_format2)
    if(isnan(dates_format2(i))==0)
        junk=int2str(dates_format2(i));
        yr=str2num(junk(:,1:4));
        mo=str2num(junk(:,5:6));
        day=str2num(junk(:,7:8));
        hr=str2num(junk(:,9:10));
        min=str2num(junk(:,11:12));
        if(mo<1|mo>12|day<1|day>31)
            dates(i)=yr;
        else
            dates(i)=yr+cal2dec(mo,day,hr,min)./365;
        end
    end
end