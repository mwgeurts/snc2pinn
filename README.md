# SNC IC Profiler to Pinnacle Profile Converter

by Mark Geurts <mark.w.geurts@gmail.com>
<br>Copyright &copy; 2016, University of Wisconsin Board of Regents

ConvertICP searches a provided directory for SNC IC Profiler save files and saves the profiles in the Pinnacle ASCII file format. This function can be executed with no inputs, upon which it will prompt the user to select a directory to scan for IC Profiler files, or have a folder path specified (either as a single string or an array of path parts). Note that the Pinnacle file is saved using the same file name into the same directory with the extension .dat.

Note that the SSD is retrieved from the IC Profiler file header. To expedite collection of the remaining beam parameters, the file name maybe stored in the following format (see the function ParseFileName for more information or to change the format):

`X<Energy>_<WedgeName>_<FieldSize in cm>_<Depth in mm>.prm`

An example is shown below:

`X06_EDW15_05x05_015.prm`

Below are some examples of how to execute this function:

```matlab
ConvertICP();
ConvertICP('path/to/scan/');
ConvertICP('path/', 'to/', 'scan/');
```
