This is a MEX function that can read data directly from a '.PLX' file, the native file format used and produced by the hardware/software made by Plexon, Inc. (www.plexon.com).

This function is completely independent of the 'mexPlex' library distributed directly by Plexon, Inc. and is in no way supported by Plexon, Inc. so please don't contact them for help using this function.

It has the following features that are not supported by the official library:
1) You can read the entire PLX file in a single call. This is substantially faster than reading the entire file using separate calls to read each separate channel and unit.
2) You can read multiple channels/units (including a mix of spike, event, waveform, and continuous channels) in a single call.
3) You can read a subset of the file by specify time ranges to read.
4) You can read a subset of the file by specify a starting recording number and number of records to read.

This function needs to be compiled prior to use. Once a compiler is set up, you can compile using the helper function 'build_readPLXFileC' (which is included with this submission). Although this function has been primarily tested under both Linux (Ubuntu) and Windows (32-bit and 64-bit), it has also been used with Mac OS X.

Once the function is compiled, for detailed help run: readPLXFileC('help')

USAGE:
  plx = readPLXFileC(filename, varargin)
  plx = readPLXFileC('help')
  plx = readPLXFileC('version')

INPUT:
  filename - Name of the PLX file to read.
  varargin - One (or more) of the arguments listed below. Arguments are
             parsed in order, with later arguments overriding earlier
             arguments.

ARGUMENTS:
  'help' - Display this help information
  'version' - Display MEX file version information
                    If 'version' occurs as the first input argument,
                    the revision number is returned as the first (and only) output,
                    and the version information is only printed to screen
                    if no ouptut is requested.
                    If 'version' occurs after the first input argument,
                    version information is printed to the screen, but
                    otherwise the function behaves as though 'version' was not present.
  'headers' - Retrieve only headers (default)
                    (implies 'nospikes','noevents','nocontinuous')
  '[no]fullread' - Scan the entire file (default = 'nofullread')
                    ('fullread' is implied if anything other than headers are requested)
  '[no]spikes' - Retrieve (or not) spike timestamps (default = 'nospikes')
                    'nospikes' implies 'nowaves'
  '[no]waves' - Retrieve (or not) spike waveforms (default = 'nowaves')
                    'waves' implies 'spikes'
  '[not]units' - Must be followed by a list of units to (not) retrieve
                    0 = unsorted, 1 = unit 'a', 2 = unit 'b', etc.
  '[no]events' - Retrieve (or not) event data (default = 'noevents')
  '[no]continuous' - Retrieve (or not) continuous data (default = 'no')
  'all' - Read the entire file
                    (implies 'spikes','waves','events','continuous')
  'range' - Time range of data to retrieve
  'start' - Start of time range of data to retrieve
  'stop' - End of time range of data to retrieve
  'first' - First data sample to retrieve
  'num' - Number of data samples to retieve
  'last' - Last data sample to retrieve

SELECTING CHANNELS:
  'spikes','waves','events', and/or 'continuous' can be followed by a
  numerical array, which is then parsed to determine which channels to
  retrieve. An empty array implies 'no'. If the array is missing,
  then all channels are retrieved.

OUTPUT:
  plx - A structure containing the PLX file data. 