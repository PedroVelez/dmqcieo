CDF   7   
      	DATE_TIME         	STRING256         STRING64   @   STRING32       STRING16      STRING8       STRING4       STRING2       N_PROF        N_PARAM       N_LEVELS   7   N_CALIB       	N_HISTORY                title         Argo float vertical profile    institution       CORIOLIS   source        
Argo float     
references        (http://www.argodatamgt.org/Documentation   user_manual_version       3.1    Conventions       Argo-3.1 CF-1.6    featureType       trajectoryProfile      history       X2006-02-11T14:04:00Z creation; 2015-10-19T17:15:27Z last update (coriolis COFC software)      @   	DATA_TYPE                  	long_name         	Data type      conventions       Argo reference table 1     
_FillValue                    7t   FORMAT_VERSION                 	long_name         File format version    
_FillValue                    7�   HANDBOOK_VERSION               	long_name         Data handbook version      
_FillValue                    7�   REFERENCE_DATE_TIME                 	long_name         !Date of reference for Julian days      conventions       YYYYMMDDHHMISS     
_FillValue                    7�   DATE_CREATION                   	long_name         Date of file creation      conventions       YYYYMMDDHHMISS     
_FillValue                    7�   DATE_UPDATE                 	long_name         Date of update of this file    conventions       YYYYMMDDHHMISS     
_FillValue                    7�   PLATFORM_NUMBER                   	long_name         Float unique identifier    conventions       WMO float identifier : A9IIIII     
_FillValue                    7�   PROJECT_NAME                  	long_name         Name of the project    
_FillValue                  @  7�   PI_NAME                   	long_name         "Name of the principal investigator     
_FillValue                  @  8   STATION_PARAMETERS           	            	long_name         ,List of available parameters for the station   conventions       Argo reference table 3     
_FillValue                  0  8D   CYCLE_NUMBER               	long_name         Float cycle number     conventions       =0...N, 0 : launch cycle (if exists), 1 : first complete cycle      
_FillValue         ��        8t   	DIRECTION                  	long_name         !Direction of the station profiles      conventions       -A: ascending profiles, D: descending profiles      
_FillValue                    8x   DATA_CENTRE                   	long_name         .Data centre in charge of float data processing     conventions       Argo reference table 4     
_FillValue                    8|   DC_REFERENCE                  	long_name         (Station unique identifier in data centre   conventions       Data centre convention     
_FillValue                     8�   DATA_STATE_INDICATOR                  	long_name         1Degree of processing the data have passed through      conventions       Argo reference table 6     
_FillValue                    8�   	DATA_MODE                  	long_name         Delayed mode or real time data     conventions       >R : real time; D : delayed mode; A : real time with adjustment     
_FillValue                    8�   PLATFORM_TYPE                     	long_name         Type of float      conventions       Argo reference table 23    
_FillValue                     8�   FLOAT_SERIAL_NO                   	long_name         Serial number of the float     
_FillValue                     8�   FIRMWARE_VERSION                  	long_name         Instrument firmware version    
_FillValue                     8�   WMO_INST_TYPE                     	long_name         Coded instrument type      conventions       Argo reference table 8     
_FillValue                    9   JULD               	long_name         ?Julian day (UTC) of the station relative to REFERENCE_DATE_TIME    standard_name         time   units         "days since 1950-01-01 00:00:00 UTC     conventions       8Relative julian days with decimal part (as parts of day)   
_FillValue        A.�~       axis      T      
resolution        ?q   comment_on_resolution         �JULD resolution is 6 minutes, except when JULD = JULD_LOCATION or when JULD = JULD_FIRST_MESSAGE (TRAJ file variable); in that case, JULD resolution is 1 second        9   JULD_QC                	long_name         Quality on date and time   conventions       Argo reference table 2     
_FillValue                    9   JULD_LOCATION                  	long_name         @Julian day (UTC) of the location relative to REFERENCE_DATE_TIME   units         "days since 1950-01-01 00:00:00 UTC     conventions       8Relative julian days with decimal part (as parts of day)   
_FillValue        A.�~       
resolution        >��	4E�        9   LATITUDE               	long_name         &Latitude of the station, best estimate     standard_name         latitude   units         degree_north   
_FillValue        @�i�       	valid_min         �V�        	valid_max         @V�        axis      Y           9    	LONGITUDE                  	long_name         'Longitude of the station, best estimate    standard_name         	longitude      units         degree_east    
_FillValue        @�i�       	valid_min         �f�        	valid_max         @f�        axis      X           9(   POSITION_QC                	long_name         ,Quality on position (latitude and longitude)   conventions       Argo reference table 2     
_FillValue                    90   POSITIONING_SYSTEM                    	long_name         Positioning system     
_FillValue                    94   VERTICAL_SAMPLING_SCHEME                  	long_name         Vertical sampling scheme   conventions       Argo reference table 16    
_FillValue                    9<   CONFIG_MISSION_NUMBER                  	long_name         :Unique number denoting the missions performed by the float     conventions       !1...N, 1 : first complete mission      
_FillValue         ��        :<   PROFILE_PRES_QC                	long_name         #Global quality flag of PRES profile    conventions       Argo reference table 2a    
_FillValue                    :@   PROFILE_PSAL_QC                	long_name         #Global quality flag of PSAL profile    conventions       Argo reference table 2a    
_FillValue                    :D   PROFILE_TEMP_QC                	long_name         #Global quality flag of TEMP profile    conventions       Argo reference table 2a    
_FillValue                    :H   PRES         
      
   	long_name         )Sea water pressure, equals 0 at sea-level      standard_name         sea_water_pressure     
_FillValue        G�O�   units         decibar    	valid_min                	valid_max         F;�    C_format      %7.1f      FORTRAN_format        F7.1   
resolution        =���   axis      Z         �  :L   PRES_QC          
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  8  ;(   PRES_ADJUSTED            
      
   	long_name         )Sea water pressure, equals 0 at sea-level      standard_name         sea_water_pressure     
_FillValue        G�O�   units         decibar    	valid_min                	valid_max         F;�    C_format      %7.1f      FORTRAN_format        F7.1   
resolution        =���   axis      Z         �  ;`   PRES_ADJUSTED_QC         
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  8  <<   PRES_ADJUSTED_ERROR          
         	long_name         VContains the error on the adjusted values as determined by the delayed mode QC process     
_FillValue        G�O�   units         decibar    C_format      %7.1f      FORTRAN_format        F7.1   
resolution        =���      �  <t   PSAL         
      	   	long_name         Practical salinity     standard_name         sea_water_salinity     
_FillValue        G�O�   units         psu    	valid_min         @      	valid_max         B$     C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o      �  =P   PSAL_QC          
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  8  >,   PSAL_ADJUSTED            
      	   	long_name         Practical salinity     standard_name         sea_water_salinity     
_FillValue        G�O�   units         psu    	valid_min         @      	valid_max         B$     C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o      �  >d   PSAL_ADJUSTED_QC         
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  8  ?@   PSAL_ADJUSTED_ERROR          
         	long_name         VContains the error on the adjusted values as determined by the delayed mode QC process     
_FillValue        G�O�   units         psu    C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o      �  ?x   TEMP         
      	   	long_name         $Sea temperature in-situ ITS-90 scale   standard_name         sea_water_temperature      
_FillValue        G�O�   units         degree_Celsius     	valid_min         �      	valid_max         B      C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o      �  @T   TEMP_QC          
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  8  A0   TEMP_ADJUSTED            
      	   	long_name         $Sea temperature in-situ ITS-90 scale   standard_name         sea_water_temperature      
_FillValue        G�O�   units         degree_Celsius     	valid_min         �      	valid_max         B      C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o      �  Ah   TEMP_ADJUSTED_QC         
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  8  BD   TEMP_ADJUSTED_ERROR          
         	long_name         VContains the error on the adjusted values as determined by the delayed mode QC process     
_FillValue        G�O�   units         degree_Celsius     C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o      �  B|   	PARAMETER               	            	long_name         /List of parameters with calibration information    conventions       Argo reference table 3     
_FillValue                  0  CX   SCIENTIFIC_CALIB_EQUATION               	            	long_name         'Calibration equation for this parameter    
_FillValue                    C�   SCIENTIFIC_CALIB_COEFFICIENT            	            	long_name         *Calibration coefficients for this equation     
_FillValue                    F�   SCIENTIFIC_CALIB_COMMENT            	            	long_name         .Comment applying to this parameter calibration     
_FillValue                    I�   SCIENTIFIC_CALIB_DATE               	             	long_name         Date of calibration    conventions       YYYYMMDDHHMISS     
_FillValue                  ,  L�   HISTORY_INSTITUTION                      	long_name         "Institution which performed action     conventions       Argo reference table 4     
_FillValue                    L�   HISTORY_STEP                     	long_name         Step in data processing    conventions       Argo reference table 12    
_FillValue                    L�   HISTORY_SOFTWARE                     	long_name         'Name of software which performed action    conventions       Institution dependent      
_FillValue                    L�   HISTORY_SOFTWARE_RELEASE                     	long_name         2Version/release of software which performed action     conventions       Institution dependent      
_FillValue                    L�   HISTORY_REFERENCE                        	long_name         Reference of database      conventions       Institution dependent      
_FillValue                  @  L�   HISTORY_DATE                      	long_name         #Date the history record was created    conventions       YYYYMMDDHHMISS     
_FillValue                    M   HISTORY_ACTION                       	long_name         Action performed on data   conventions       Argo reference table 7     
_FillValue                    M   HISTORY_PARAMETER                        	long_name         (Station parameter action is performed on   conventions       Argo reference table 3     
_FillValue                    M   HISTORY_START_PRES                    	long_name          Start pressure action applied on   
_FillValue        G�O�   units         decibar         M(   HISTORY_STOP_PRES                     	long_name         Stop pressure action applied on    
_FillValue        G�O�   units         decibar         M,   HISTORY_PREVIOUS_VALUE                    	long_name         +Parameter/Flag previous value before action    
_FillValue        G�O�        M0   HISTORY_QCTEST                       	long_name         <Documentation of tests performed, tests failed (in hex form)   conventions       EWrite tests performed when ACTION=QCP$; tests failed when ACTION=QCF$      
_FillValue                    M4Argo profile    3.1 1.2 19500101000000  20060211140400  20180206150257  1900379 ARGO_CR                                                         Daniel BALLESTERO                                               PRES            TEMP            PSAL               A   IF  3090653                         2C  D   PROVOR                          OIN-04-SP-S2-06                 n/a                             841 @�����1   @�����@ _;dZ��VV�u1   ARGOS   Primary sampling: averaged [10 sec sampling, 50 dbar average from 2000 dbar to 200 dbar; 10 sec sampling, 10 dbar average from 200 dbar to 10.0 dbar]                                                                                                              F   F   F   A�  A�  B  B4  B\  B�  B�  B�  B�  B�  B�  B�  C  C  C  C%  C/  C9  CC  C`  C�  C�� C�  CԀ C� D@ D� D  D(� D5� DB  DN@ DZ� Dg@ Ds� D�` D�` D�� D�� D�  D�� D�� D�� D�  D�� D�� D�� D�  D�` D�� D�� D�  D�` D� D�` 4444444444444444444444444444444444444444444444444444444 G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�4444444444444444444444444444444444444444444444444444444 G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�BW
B�ZB��B�B	�BB
T�B
�BJB
��B
��B
��B
{�B
o�B
aHB
K�B
E�B
D�B
{B	�B	�B	�?B	��B	ZB	9XB	��B	��B	�mB	��B	��B	��B

=B
'�B
DB
1'B
;dB
N�B
L�B
S�B
F�B
L�B
dZB
_;B
_;B
_;B
hsB
e`B
k�B
dZB
^5B
l�B
t�B
o�B
m�B
q�B
�14444444444444444444444444444444444444444444444444444444 G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�4444444444444444444444444444444444444444444444444444444 G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�A�O�A��7As+Aa��AV�AQ��AN��AN9XAO�AN�RAM��AM33AL=qAKC�AJI�AI�AG�wAF��AES�A>ĜA5�A-33A$�jA�hA|�@�ȴ@�+@�(�@�n�@ă@��@��@�Ĝ@��@��@��@�(�@��T@���@u�T@k��@cƨ@Z��@R=q@K"�@Cƨ@<�@6�@/�w@(A�@#�
@ 1'@�@5?@o4444444444444444444444444444444444444444444444444444444 G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�4444444444444444444444444444444444444444444444444444444 G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�PRES            TEMP            PSAL            PRES_ADJUSTED(cycle i)=PRES (cycle i)-Surface Pressure(cycle i+1).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Surface pressure=0 dbar                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         No significant pressure drift detected - Calibration error is manufacturer specified accuracy                                                                                                                                                                   No significant temperature drift detected - Calibration error is manufacturer specified accuracy                                                                                                                                                                No significant salinity drift detected - Calibration error is manufacturer specified accuracy                                                                                                                                                                   201802061501012018020615010120180206150101  TC      OA  3.02                                                                20070328000000  QC  PSAL            G�O�G�O�G�O�2006-03-01      TC      CVQC1.7.                                                                20071003170107  CF  TEMP            B4  G�O�Aa��                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            B\  G�O�AV�                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            B�  G�O�AQ��                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            B�  G�O�AN��                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            B�  G�O�AN9X                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            B�  G�O�AO�                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            B�  G�O�AN�R                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            B�  G�O�AM��                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            B�  G�O�AM33                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            C  G�O�AL=q                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            C  G�O�AKC�                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            C  G�O�AJI�                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            C%  G�O�AI�                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            C/  G�O�AG�w                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            C9  G�O�AF��                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            CC  G�O�AES�                TC      CVQC1.7.                                                                20071003170108  CF  TEMP            C`  G�O�A>Ĝ                IF  CODMCOOA1   DMQCGL01                                                        20080409174011  QCP$PSAL            G�O�G�O�G�O�                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            B\  G�O�AV�                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            B�  G�O�AQ��                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            B�  G�O�AN��                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            B�  G�O�AN9X                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            B�  G�O�AO�                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            B�  G�O�AN�R                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            B�  G�O�AM��                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            B�  G�O�AM33                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            C  G�O�AL=q                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            C  G�O�AKC�                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            C  G�O�AJI�                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            C%  G�O�AI�                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            C/  G�O�AG�w                TC      CVQC1.7.                                                                20071010164756  CF  TEMP            C9  G�O�AF��                TC      CVQC1.7.                                                                20071010164756  CF  PSAL            B�  G�O�B
�                TC      CVQC1.7.                                                                20071010164756  CF  PSAL            B�  G�O�B
{�                TC      CVQC1.7.                                                                20071010164756  CF  PSAL            C  G�O�B
o�                TC      CVQC1.7.                                                                20071010164756  CF  PSAL            C  G�O�B
aH                TC      CVQC1.7.                                                                20071010164756  CF  PSAL            B�  G�O�BJ                TC      CVQC1.7.                                                                20071010164756  CF  PSAL            B�  G�O�B
��                TC      CVQC1.7.                                                                20071010164756  CF  PSAL            B�  G�O�B
��                TC      CVQC1.7.                                                                20071010164756  CF  PSAL            B�  G�O�B
��                TC      CVQC1.7.                                                                20071010164756  CF  PSAL            C  G�O�B
K�                TC      CVQC1.7.                                                                20071010164756  CF  PSAL            C%  G�O�B
E�                        CORA                                                                    20080329033033  SVP                 G�O�G�O�G�O�                IF      SCOO1.4                                                                 20130425140014  QC                  G�O�G�O�G�O�                IF  CODMCOOA6.2 DMQCGL01                                                        20140818100700  QCP$TEMP            G�O�G�O�G�O�                IF  CODMCOOA6.2 DMQCGL01                                                        20140818100722  QCP$TEMP            G�O�G�O�G�O�                IF  CODMCOOA6.2 DMQCGL01                                                        20140818101456  QCF$PSAL            B�  Dz  G�O�6               IF  CODMCOOA6.2 DMQCGL01                                                        20140818101343  QCF$PSAL            B�  D/  G�O�6               IF  CODMCOOA6.2 DMQCGL01                                                        20140818100604  QCP$TEMP            G�O�G�O�G�O�                IF  CODMCOOA6.2 DMQCGL01                                                        20140818101435  QCF$PSAL            B�  D/  G�O�6               IF      COFC2.7                                                                 20151019171527                      G�O�G�O�G�O�                SP  ARSQAIEOV0.1                                                                20180206150029  CF                  G�O�G�O�G�O�                SP  ARSQAIEO1   WOA05                                                           20180206150101  QC  PRES            G�O�G�O�G�O�                SP  ARSQAIEO1   WOA05                                                           20180206150151  QC  PSAL            G�O�G�O�G�O�                