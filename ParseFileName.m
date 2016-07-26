function [energy, wedge, fieldsize, depth] = ParseFileName(name)
% ParseFileName extracts the beam energy, wedge name, field size, and depth
% from the file name of the IC Profiler. The file name is expected to take
% on the following format:
%
% X<Energy>_<WedgeName>_<FieldSize in cm>_<Depth in mm>.prm
%
% An example is shown below:
%
% X06_EDW15_05x05_015.prm
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2015 University of Wisconsin Board of Regents
%
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the  
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see http://www.gnu.org/licenses/.

% Initialize empty return arguments
energy = 0;
wedge = '';
fieldsize = [0, 0];
depth = 0;

% Use RegEx to match file name
[tokens, ~] = regexp(name, ...
    'X([0-9]+)_([a-zA-Z0-9]*)_?([0-9]+)x([0-9]+)_([0-9]+)', ...
    'tokens', 'match');

% If the file was matched
if ~isempty(tokens)
    energy = str2double(tokens{1}{1});
    wedge = tokens{1}{2};
    fieldsize(1) = str2double(tokens{1}{3});
    fieldsize(2) = str2double(tokens{1}{4});
    depth = str2double(tokens{1}{5})/10;
end
    
