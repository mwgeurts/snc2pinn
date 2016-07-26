function ConvertICP(varargin)
% ConvertICP searches a provided directory for SNC IC Profiler save files 
% and saves the profiles in the Pinnacle ASCII file format. This function 
% can be executed with no inputs, upon which it will prompt the user to 
% select a directory to scan for IC Profiler files, or have a folder path 
% specified (either as a single string or an array of path parts). Note 
% that the Pinnacle file is saved using the same file name into the same 
% directory with the extension .dat.
%
% Note that the SSD is retrieved from the IC Profiler file header. To 
% expedite collection of the remaining beam parameters, the file name may
% be stored in the following format (see the function ParseFileName for 
% more information or to change the format):
%
% X<Energy>_<WedgeName>_<FieldSize in cm>_<Depth in mm>.prm
%
% Below are some examples of how to execute this function:
%
%   ConvertICP();
%   ConvertICP('path/to/scan/');
%   ConvertICP('path/', 'to/', 'scan/');
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

% If no input arguments were provided to this function
if nargin == 0
    
    % Open a dialog box for the user to select a directory
    if exist('Event', 'file') == 2
        Event('UI window opened to select import path');
    end
    path = uigetdir(['Select the directory to scan for IC Profiler ', ...
        'save files']);
  
% Otherwise, if only one argument was provided
elseif nargin == 1
    
    % Assume provided input is the path
    path = varargin{1};
 
% Otherwise, multiple arguments were provided
else
    
    % Use fullfile() to concatenate inputs
    path = fullfile(varargin);
end

% Add xpdf_tools submodule to search path
addpath('./snc_extract');

% Check if MATLAB can find ParseSNCprm
if exist('ParseSNCprm', 'file') ~= 2
    
    % If not, throw an error
    if exist('Event', 'file') == 2
        Event(['The snc_extract submodule does not exist in the search path. ', ...
            'Use git clone --recursive or git submodule init followed by git ', ...
            'submodule update to fetch all submodules'], 'ERROR');
    else
        error(['The snc_extract submodule does not exist in the search path. ', ...
            'Use git clone --recursive or git submodule init followed by git ', ...
            'submodule update to fetch all submodules']);
    end
end

% Log start of search and start timer
if exist('Event', 'file') == 2
    Event(['Searching ', path, ' for IC Profiler save files']);
end
t = tic;

% Retrieve folder contents of directory
list = dir(path);

% Initialize folder counter
i = 0;

% Initialize profile counter
c = 0;

% Start recursive loop through each folder, subfolder
while i < size(list, 1)

    % Increment current folder being analyzed
    i = i + 1;
    
    % If the folder content is . or .., skip to next folder in list
    if strcmp(list(i).name, '.') || strcmp(list(i).name, '..')
        continue
        
    % Otherwise, if the folder content is a subfolder    
    elseif list(i).isdir == 1
        
        % Retrieve the subfolder contents
        subList = dir(fullfile(path, list(i).name));
        
        % Look through the subfolder contents
        for j = 1:size(subList, 1)
            
            % If the subfolder content is . or .., skip to next subfolder 
            if strcmp(subList(j).name, '.') || ...
                    strcmp(subList(j).name, '..')
                continue
            else
                
                % Otherwise, replace the subfolder name with its full name
                subList(j).name = fullfile(list(i).name, subList(j).name);
            end
        end
        
        % Append the subfolder contents to the main folder list
        list = vertcat(list, subList); %#ok<AGROW>
        
        % Clear temporary variable
        clear subList;
        
    % Otherwise, if the file is a PRM file
    elseif size(strfind(lower(list(i).name), '.prm'), 1) > 0

        % Log file name and increment counter
        if exist('Event', 'file') == 2
            Event(['Found PRM file ', list(i).name]);
        end
        c = c + 1;

        % Execute in try/catch loop to skip failing plans       
        try
            
            % Extract PRM file contents
            data = ParseSNCprm(path, list(i).name);

            % Analyze Profiler fields
            results = AnalyzeProfilerFields(data);
        
            % Store output file name
            [~, outfile, ~] = fileparts(list(i).name); 
            outfile = [outfile, '.dat']; %#ok<AGROW>
            
            % Open file handle to output file
            if exist('Event', 'file') == 2
                Event(['Writing profile to output file ', outfile]);
            end
            fid = fopen(fullfile(path, outfile), 'w');
            
            % Verify file handle is correct
            if fid < 3
                if exist('Event', 'file') == 2
                    Event('The file could not be created', 'ERROR');
                else
                    error('The file could not be created');
                end
            end
        
            % Try to get energy, field size, depth from filename
            [energy, wedge, fieldsize, depth] = ParseFileName(list(i).name);
            
            % If the input fields are empty, ask for them
            if energy == 0
                
                % Use ICP energy if specified
                if isfield(data, 'menergy') && ~isempty(data.menergy)
                    [tokens, ~] = regexp(data.menergy, '([0-9]+)', ...
                        'tokens', 'match');
                    energy = str2double(tokens{1}{1});
                else
                    energy = str2double(inputdlg('Enter the beam energy:'));
                end
            end
            if isempty(wedge)
                wedge = inputdlg('Enter the wedge name (leave empty if open):');
            end
            if fieldsize(1) == 0 && fieldsize(2) == 0
                fieldsize(1) = str2double(inputdlg('Enter the jaw X position in cm:'));
                fieldsize(2) = str2double(inputdlg('Enter the jaw Y position in cm:'));
            end
            if depth == 0
                depth = str2double(inputdlg('Enter the profile depth in cm:'));
            end
            
            % Write the file header
            fprintf(fid, 'PinnDoseProfile\n');
            fprintf(fid, '%0.0f %0.1f\n', energy, data.dssd);
            fprintf(fid, '%0.2f %0.2f %0.2f %0.2f\n', fieldsize(1)/2, ...
                fieldsize(1)/2, fieldsize(2)/2, fieldsize(1)/2);
            if ~isempty(wedge)
                fprintf(fid, 'WedgeName %s\n', wedge);
            end
            fprintf(fid, '2\n');
            
            % Print X profile
            fprintf(fid, 'XProfile %0.2f %0.2f\n', depth, 0);
            fprintf(fid, '%i\n', size(results.xdata, 2));
            for j = 1:size(results.xdata,2)
                fprintf(fid, '%0.4f %0.4f\n', results.xdata(1,j), ...
                    results.xdata(2,j));
            end
            
            % Print Y profile
            fprintf(fid, 'YProfile %0.2f %0.2f\n', depth, 0);
            fprintf(fid, '%i\n', size(results.ydata, 2));
            for j = 1:size(results.ydata,2)
                fprintf(fid, '%0.4f %0.4f\n', results.ydata(1,j), ...
                    results.ydata(2,j));
            end
            
            % Close file
            fclose(fid);
            if exist('Event', 'file') == 2
                Event(['Output written successfully to ', outfile]);
            end
         
            % Clear temporary variables
            clear data depth energy fid fieldsize j outfile tokens ...
                results wedge;
            
        % Catch errors
        catch
            
            % Log event
            if exist('Event', 'file') == 2
                Event('Errors occurred, skipping to next file');
            end
            
            % Continue to next file
            continue
        end
    end
end

% Log completion
if exist('Event', 'file') == 2
    Event(sprintf(['Directory %s scan completed successfully in %0.3f', ...
        ' seconds, finding %i IC Profiler file(s)'], ...
        path, toc(t), c));
end

% Clear temporary variables
clear c i list path t;