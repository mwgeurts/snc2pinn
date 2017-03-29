# SNC IC Profiler to Pinnacle Profile Converter

by Mark Geurts <mark.w.geurts@gmail.com>
<br>Copyright &copy; 2016, University of Wisconsin Board of Regents

ConvertICP searches a provided directory for SNC IC Profiler save files and saves the profiles in the Pinnacle ASCII file format. This function can be executed with no inputs, upon which it will prompt the user to select a directory to scan for IC Profiler files, or have a folder path specified (either as a single string or an array of path parts). Note that the Pinnacle file is saved using the same file name into the same directory with the extension .dat.

Note that the SSD is retrieved from the IC Profiler file header. To expedite collection of the remaining beam parameters, the file name maybe stored in the following format (see the function ParseFileName for more information or to change the format):

```matlab
X<Energy>_<WedgeName>_<FieldSize in cm>_<Depth in mm>.prm
```

An example is shown below:

```matlab
X06_EDW15_05x05_015.prm
```

Below are some examples of how to execute this function:

```matlab
ConvertICP();
ConvertICP('path/to/scan/');
ConvertICP('path/', 'to/', 'scan/');
```

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
