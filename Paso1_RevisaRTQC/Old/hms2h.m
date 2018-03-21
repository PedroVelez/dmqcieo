function [r]=hms2h(h,m,s)
%HMS2H   Converts hours, minutes, seconds to decimal hours

r = h +(m+s/60)/60;
 
