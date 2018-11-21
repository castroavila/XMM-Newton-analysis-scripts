README.txt

:Author:	Manuel Castro Avila
:Email:	manuel.castro@inpe.br
:Date:	30-Oct-2018
		National Institute for Space Research (INPE)- São José dos 
		Campos/SP - Brazil

Those scripts are intended to aid in extracting spectra and light curves from
PN- and MOS-EPIC cameras on board the XMM-Newton satellite, following the SAS
Data analysis Threads (https://www.cosmos.esa.int/web/xmm-newton/sas-threads).
The scripts are being developed under financial support from FAPESP (Fundação
de Amparo à Pesquisa do Estado de São Paulo, Brazil) under grant
#2015/25972-0 

Make sure you have installed both Heasoft and SAS tools and that the variables
HEADAS and SAS_DIR have been set up properly. The scripts will check for
non-empty variables, otherwise it will stop the execution. Also set up the
SAS_CCFPATH variable accordingly. The scripts will run ONLY in sh-family shells.
The best way to run the scripts is via alias,  i.e.,  alias name=".
/path/to/the_script.sh"; this is due to the fact that variables SAS_ODF and
SAS_CCF must be defined  globally for the bash session, since they are required
by other scripts.

Scripts:

-->sas.sh:
	Either the original .TAR file (the one downloaded from the XMM-Newton
	database) or the odf directory must be provided.
	It extracts the files from the *.TAR file, executes  both cifbuild and
	odfingest commands, and set up the necessary environment variables.

	If the odf directory is provided, check the existence of both .cif and
	*SUM.SAS files, and set up environment variables accordingly.  
	
	If you resume your analysis in a new shell session, make sure to always run 
	this script before continuing the analysis.

-->config.sh:
	Create a .conf file in each directory (either pn or mos directories)
	containing info about the data for that particular camera and observation:
	camera, operating mode, eventfiles. Other variables are set up by default.
	Before starting the analysis you can edit the generated file at will.


-->execution.sh:
	This script performs the data analysis: it extracts a clean eventfile and
   generates images of the observed field of view. The user can then choose the
   proper extraction regions and add them to the *.conf file in order to generate
   plots to assess pileup. The user can then extract spectra and/or lightcurves.
     
