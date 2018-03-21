CDF   |   
      	DATE_TIME         	STRING256         STRING64   @   STRING32       STRING16      STRING8       STRING4       STRING2       N_PROF        N_PARAM       N_LEVELS   6   N_CALIB       	N_HISTORY                title         Argo float vertical profile    institution       CORIOLIS   source        
Argo float     
references        (http://www.argodatamgt.org/Documentation   user_manual_version       3.1    Conventions       Argo-3.1 CF-1.6    featureType       trajectoryProfile      history       X2006-08-28T19:42:30Z creation; 2015-10-19T17:15:38Z last update (coriolis COFC software)      @   	DATA_TYPE                  	long_name         	Data type      conventions       Argo reference table 1     
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
_FillValue                  8  ;$   PRES_ADJUSTED            
      
   	long_name         )Sea water pressure, equals 0 at sea-level      standard_name         sea_water_pressure     
_FillValue        G�O�   units         decibar    	valid_min                	valid_max         F;�    C_format      %7.1f      FORTRAN_format        F7.1   
resolution        =���   axis      Z         �  ;\   PRES_ADJUSTED_QC         
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  8  <4   PRES_ADJUSTED_ERROR          
         	long_name         VContains the error on the adjusted values as determined by the delayed mode QC process     
_FillValue        G�O�   units         decibar    C_format      %7.1f      FORTRAN_format        F7.1   
resolution        =���      �  <l   PSAL         
      	   	long_name         Practical salinity     standard_name         sea_water_salinity     
_FillValue        G�O�   units         psu    	valid_min         @      	valid_max         B$     C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o      �  =D   PSAL_QC          
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  8  >   PSAL_ADJUSTED            
      	   	long_name         Practical salinity     standard_name         sea_water_salinity     
_FillValue        G�O�   units         psu    	valid_min         @      	valid_max         B$     C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o      �  >T   PSAL_ADJUSTED_QC         
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  8  ?,   PSAL_ADJUSTED_ERROR          
         	long_name         VContains the error on the adjusted values as determined by the delayed mode QC process     
_FillValue        G�O�   units         psu    C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o      �  ?d   TEMP         
      	   	long_name         $Sea temperature in-situ ITS-90 scale   standard_name         sea_water_temperature      
_FillValue        G�O�   units         degree_Celsius     	valid_min         �      	valid_max         B      C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o      �  @<   TEMP_QC          
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  8  A   TEMP_ADJUSTED            
      	   	long_name         $Sea temperature in-situ ITS-90 scale   standard_name         sea_water_temperature      
_FillValue        G�O�   units         degree_Celsius     	valid_min         �      	valid_max         B      C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o      �  AL   TEMP_ADJUSTED_QC         
         	long_name         quality flag   conventions       Argo reference table 2     
_FillValue                  8  B$   TEMP_ADJUSTED_ERROR          
         	long_name         VContains the error on the adjusted values as determined by the delayed mode QC process     
_FillValue        G�O�   units         degree_Celsius     C_format      %9.3f      FORTRAN_format        F9.3   
resolution        :�o      �  B\   	PARAMETER               	            	long_name         /List of parameters with calibration information    conventions       Argo reference table 3     
_FillValue                  0  C4   SCIENTIFIC_CALIB_EQUATION               	            	long_name         'Calibration equation for this parameter    
_FillValue                    Cd   SCIENTIFIC_CALIB_COEFFICIENT            	            	long_name         *Calibration coefficients for this equation     
_FillValue                    Fd   SCIENTIFIC_CALIB_COMMENT            	            	long_name         .Comment applying to this parameter calibration     
_FillValue                    Id   SCIENTIFIC_CALIB_DATE               	             	long_name         Date of calibration    conventions       YYYYMMDDHHMISS     
_FillValue                  ,  Ld   HISTORY_INSTITUTION                      	long_name         "Institution which performed action     conventions       Argo reference table 4     
_FillValue                    L�   HISTORY_STEP                     	long_name         Step in data processing    conventions       Argo reference table 12    
_FillValue                    L�   HISTORY_SOFTWARE                     	long_name         'Name of software which performed action    conventions       Institution dependent      
_FillValue                    L�   HISTORY_SOFTWARE_RELEASE                     	long_name         2Version/release of software which performed action     conventions       Institution dependent      
_FillValue                    L�   HISTORY_REFERENCE                        	long_name         Reference of database      conventions       Institution dependent      
_FillValue                  @  L�   HISTORY_DATE                      	long_name         #Date the history record was created    conventions       YYYYMMDDHHMISS     
_FillValue                    L�   HISTORY_ACTION                       	long_name         Action performed on data   conventions       Argo reference table 7     
_FillValue                    L�   HISTORY_PARAMETER                        	long_name         (Station parameter action is performed on   conventions       Argo reference table 3     
_FillValue                    L�   HISTORY_START_PRES                    	long_name          Start pressure action applied on   
_FillValue        G�O�   units         decibar         M   HISTORY_STOP_PRES                     	long_name         Stop pressure action applied on    
_FillValue        G�O�   units         decibar         M   HISTORY_PREVIOUS_VALUE                    	long_name         +Parameter/Flag previous value before action    
_FillValue        G�O�        M   HISTORY_QCTEST                       	long_name         <Documentation of tests performed, tests failed (in hex form)   conventions       EWrite tests performed when ACTION=QCP$; tests failed when ACTION=QCF$      
_FillValue                    MArgo profile    3.1 1.2 19500101000000  20060828194230  20180206150319  1900379 ARGO_CR                                                         Daniel BALLESTERO                                               PRES            TEMP            PSAL               A   IF  3551143                         2C  D   PROVOR                          OIN-04-SP-S2-06                 n/a                             841 @�5����1   @�5����@"ȴ9Xc�U��Q�1   ARGOS   Primary sampling: averaged [10 sec sampling, 50 dbar average from 2000 dbar to 200 dbar; 10 sec sampling, 10 dbar average from 200 dbar to 10.0 dbar]                                                                                                              F   F   F   A�  B  B4  B`  B�  B�  B�  B�  B�  B�  B�  C  C  C  C%  C/  C9  CC  Cd  C�� C�� C�  CԀ C�  D@ D� D� D(� D5@ DA� DN� DZ� Dg  Ds� D�  D�� D�� D�� D�  D�` D�  D�� D�  D�@ D�� D�� D�  D�` D�� D�� D�  D�@ D�� D�� 444444444444444444444444444444444444444444444444444444  G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�444444444444444444444444444444444444444444444444444444  G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�B��B�#B�NBs�B	7B	bNB	�jB
 �B
R�B
O�B
:^B
?}B
VB
$�B
VB
B	�B	�B
B
+B	��B	�B	�{B	Q�B	|�B	ȴB	�/B	�B
�B
�B
7LB
:^B
B�B
B�B
<jB
aHB
iyB
cTB
k�B
dZB
t�B
{�B
|�B
z�B
�B
�uB
��B
��B
��B
�LB
B
ÖB
��B
�444444444444444444444444444444444444444444444444444444  G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�444444444444444444444444444444444444444444444444444444  G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�A�I�A��7A��
A�-AyƨAk�^Af �Aa�FA_�A]��A\��AZȴAY7LAX�jAWXAUƨATQ�AR��AK��AA|�A8^5A.5?A#��A��A�+@�V@�hs@�dZ@�V@�t�@��9@��P@�n�@��H@�33@��@�;d@}�T@u?}@m��@d��@\I�@TI�@K�m@C33@;��@65?@1X@*�\@&@"J@��@��@|�444444444444444444444444444444444444444444444444444444  G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�444444444444444444444444444444444444444444444444444444  G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�G�O�PRES            TEMP            PSAL            PRES_ADJUSTED(cycle i)=PRES (cycle i)-Surface Pressure(cycle i+1).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              Surface pressure=0 dbar                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         No significant pressure drift detected - Calibration error is manufacturer specified accuracy                                                                                                                                                                   No significant temperature drift detected - Calibration error is manufacturer specified accuracy                                                                                                                                                                No significant salinity drift detected - Calibration error is manufacturer specified accuracy                                                                                                                                                                   201802061501012018020615010120180206150101  TC      CVQC1.7.                                                                20060907170217  CF  PSAL            A�  G�O�B��                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            B  G�O�B�#                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            B4  G�O�B�N                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            B`  G�O�Bs�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            B�  G�O�B	7                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            B�  G�O�B	bN                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            B�  G�O�B	�j                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            B�  G�O�B
 �                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            B�  G�O�B
R�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            B�  G�O�B
O�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            B�  G�O�B
:^                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            C  G�O�B
?}                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            C  G�O�B
V                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            C  G�O�B
$�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            C%  G�O�B
V                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            C/  G�O�B
                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            C9  G�O�B	�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            CC  G�O�B	�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            Cd  G�O�B
                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            C�� G�O�B
+                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            C�� G�O�B	��                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            C�  G�O�B	�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            CԀ G�O�B	�{                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            C�  G�O�B	Q�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D@ G�O�B	|�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D� G�O�B	ȴ                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D� G�O�B	�/                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D(� G�O�B	�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D5@ G�O�B
�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            DA� G�O�B
�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            DN� G�O�B
7L                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            DZ� G�O�B
:^                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            Dg  G�O�B
B�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            Ds� G�O�B
B�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�  G�O�B
<j                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�� G�O�B
aH                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�� G�O�B
iy                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�� G�O�B
cT                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�  G�O�B
k�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�` G�O�B
dZ                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�  G�O�B
t�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�� G�O�B
{�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�  G�O�B
|�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�@ G�O�B
z�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�� G�O�B
�                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�� G�O�B
�u                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�  G�O�B
��                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�` G�O�B
��                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�� G�O�B
��                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�� G�O�B
�L                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�  G�O�B
                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�@ G�O�B
Ö                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�� G�O�B
��                TC      CVQC1.7.                                                                20060907170217  CF  PSAL            D�� G�O�B
�                TC      OA  3.02                                                                20070327000000  QC  TEMP            G�O�G�O�G�O�2006-09-13      TC      CVQC1.7.                                                                20070907145941  CF  PSAL            A�  G�O�B��                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            B  G�O�B�#                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            B4  G�O�B�N                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            B`  G�O�Bs�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            B�  G�O�B	7                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            B�  G�O�B	bN                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            B�  G�O�B	�j                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            B�  G�O�B
 �                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            B�  G�O�B
R�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            B�  G�O�B
O�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            B�  G�O�B
:^                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            C  G�O�B
?}                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            C  G�O�B
V                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            C  G�O�B
$�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            C%  G�O�B
V                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            C/  G�O�B
                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            C9  G�O�B	�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            CC  G�O�B	�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            Cd  G�O�B
                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            C�� G�O�B
+                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            C�� G�O�B	��                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            C�  G�O�B	�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            CԀ G�O�B	�{                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            C�  G�O�B	Q�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D@ G�O�B	|�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D� G�O�B	ȴ                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D� G�O�B	�/                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D(� G�O�B	�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D5@ G�O�B
�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            DA� G�O�B
�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            DN� G�O�B
7L                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            DZ� G�O�B
:^                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            Dg  G�O�B
B�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            Ds� G�O�B
B�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�  G�O�B
<j                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�� G�O�B
aH                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�� G�O�B
iy                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�� G�O�B
cT                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�  G�O�B
k�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�` G�O�B
dZ                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�  G�O�B
t�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�� G�O�B
{�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�  G�O�B
|�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�@ G�O�B
z�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�� G�O�B
�                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�� G�O�B
�u                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�  G�O�B
��                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�` G�O�B
��                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�� G�O�B
��                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�� G�O�B
�L                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�  G�O�B
                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�@ G�O�B
Ö                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�� G�O�B
��                TC      CVQC1.7.                                                                20070907145941  CF  PSAL            D�� G�O�B
�                TC      CVQC1.7.                                                                20071003170505  CF  PSAL            B  G�O�B�#                TC      CVQC1.7.                                                                20071010165037  CF  PSAL            A�  G�O�B��                TC      CVQC1.7.                                                                20071010165037  CF  PSAL            B  G�O�B�#                IF  CODMCOOA1   DMQCGL01                                                        20080409232639  QCP$PSAL            G�O�G�O�G�O�                        CORA                                                                    20080329011953  SVP                 G�O�G�O�G�O�                IF      SCOO1.4                                                                 20130425140012  QC                  G�O�G�O�G�O�                IF  CODMCOOA6.2 DMQCGL01                                                        20140818101113  QCP$TEMP            G�O�G�O�G�O�                IF  CODMCOOA6.2 DMQCGL01                                                        20140818101050  QCP$TEMP            G�O�G�O�G�O�                IF  CODMCOOA6.2 DMQCGL01                                                        20140818101940  QCF$PSAL                B�  G�O�6               IF  CODMCOOA6.2 DMQCGL01                                                        20140818102024  QCF$PSAL                B�  G�O�6               IF  CODMCOOA6.2 DMQCGL01                                                        20140818101038  QCF$TEMP            G�O�G�O�G�O�4               IF      COFC2.7                                                                 20151019171538                      G�O�G�O�G�O�                SP  ARSQAIEOV0.1                                                                20180206150029  CF                  G�O�G�O�G�O�                SP  ARSQAIEO1   WOA05                                                           20180206150101  QC  PRES            G�O�G�O�G�O�                SP  ARSQAIEO1   WOA05                                                           20180206150151  QC  PSAL            G�O�G�O�G�O�                