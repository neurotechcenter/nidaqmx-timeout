#!/usr/bin/env python

import os, sys, time
import numpy, numpy as np, matplotlib, matplotlib as mpl, matplotlib.pyplot as plt
if 'IPython' in sys.modules: plt.ion()

def GetClipboard():
	try: import tkinter
	except: import Tkinter as tkinter
	r = tkinter.Tk()
	r.withdraw()
	data = r.clipboard_get()
	r.destroy()	
	return data
	
def ExtractTimes( source=None, plot=True ):
	"""
	`source` can be the path to a log (from the `system-logs` directory)
	or the contents of such a file, or `None` (in which case log contents
	are taken from the clipboard).

	`plot` can be `False`, `True`, `'hold'` or an integer figure number.
	"""
	if source is None: source = GetClipboard()
	if '\n' in source: source = source.split( '\n' )
	else: source = list( open( source ) )
	stamped = [ line.strip() for line in source if line.startswith( tuple( '0123456789' ) ) ]
	logname = '\n'.join( line.rsplit( '/', 1 )[ -1 ] for line in stamped if 'log will be saved' in line )
	gitrev = '\n'.join( line.rsplit( '-', 1 )[ -1 ][ 1: ] for line in stamped if 'git revision' in line )
	first = time.mktime( time.strptime( ' '.join( stamped[  0 ].split()[ :2 ] ).rstrip( ':' ), '%Y-%m-%d %H:%M:%S' ) )
	last  = time.mktime( time.strptime( ' '.join( stamped[ -1 ].split()[ :2 ] ).rstrip( ':' ), '%Y-%m-%d %H:%M:%S' ) )
	mins = ( last - first ) / 60.0
	t = numpy.array( [ float( line.split( ':' )[ 0 ] ) for line in source if 'ReportDebugTimes' in line ] )
	dt = numpy.diff( t )
	title = '%s (git revision %s): %.3f sec +/- %.3f STD (%d occurrences over %.1f mins)' % ( logname, gitrev, dt.mean(), dt.std(), t.size, mins )
	print( title )
	if plot:
		if isinstance( plot, str ): 
			try: plot = int( plot )
			except: pass
		if isinstance( plot, int ) and not isinstance( plot, bool ): plt.figure( plot )
		if plot != 'hold': plt.clf()
		plt.subplot( 2, 1, 1 )
		plt.plot( t[ 1: ] / 60.0, dt, 'x' )
		plt.xlabel( 'minutes' )
		plt.ylabel( 'inter-glitch interval (seconds)' )
		plt.title( title.replace( ': ', '\n' ) )
		plt.subplot( 2, 1, 2 )
		plt.hist( dt, bins=int( numpy.ceil( dt.max() ) ) )
		plt.xlabel( 'inter-glitch interval (seconds)' )
		plt.ylabel( 'number of occurrences' )
	return t

if __name__ == '__main__':
	ExtractTimes( *sys.argv[ 1: ] )
	if 'IPython' not in sys.modules: plt.show()

