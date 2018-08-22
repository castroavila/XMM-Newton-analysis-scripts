#!/bin/bash

#  config.sh
#  
#  Manuel Castro Avila <manuel.castro@inpe.br>
#  
#  28-02-2017
#  
#  National Institute for Space Research (INPE),  São José dos Campos, SP, Brazil

	
	
	
		
#Colors for outputtig print

	red=`tput setaf 1`
	green=`tput setaf 2`
	yellow=`tput setaf 4`
	blue=`tput setaf 6`
	reset=`tput sgr0`
	
if [ -z $1 ]; then
	echo "${red} You provided no filename ${reset}"
	return
fi


if [[ -f $1 ]]; then 
		echo "${red} File $1 already exists ${reset}"
		return
fi


##	
	config_file=$1

	echo "#!"/"bash"/"bash"																			>$config_file

	
	echo "#		*************Configuration file *************"										>>$config_file
	echo "#		Manuel Castro Avila <manuel.castro@inpe.br>"						>>$config_file
	echo "#"																						>>$config_file
	echo "#		`date +"%d-%m-%Y"`"																	>>$config_file
	echo "#		"																					>>$config_file
	echo "#		National Institute for Space Research (INPE),  São José dos Campos, SP, Brazil"		>>$config_file
	
	echo "#		"																					>>$config_file
	echo "#		"																					>>$config_file
	echo "#		"																					>>$config_file
	echo "#		"																					>>$config_file
	echo ""																							>>$config_file
	echo ""																							>>$config_file
	echo ""																							>>$config_file
	echo ""																							>>$config_file

#	Source name
 
	echo "#">>$config_file	
	echo "#	Source name"																			>>$config_file
	echo "#">>$config_file	
	echo "">>$config_file
	echo "">>$config_file
	echo "${green}Source ${reset}"
	read arg
	echo "		sourcename="$arg																			>>$config_file
	
	echo "">>$config_file
	echo "">>$config_file




	echo "#">>$config_file	
	echo "#	Instrument's features "																	>>$config_file
	echo "#">>$config_file	
	echo ""																							>>$config_file
	
	echo "${green}Camera (pn, mos1 or mos2) ?${reset}"
	read arg
	camera=$arg

	echo "		camera="$camera																		>>$config_file
	
	echo "${green}mode (timing or imaging)?${reset}"
	read arg
	mode=$arg
	echo "		mode="$arg																			>>$config_file
	
	
	echo ""																							>>$config_file
	echo ""																							>>$config_file
	
# 	Event file
	
	echo "#">>$config_file	
	echo "#Raw data"																				>>$config_file
	echo "#">>$config_file	
	echo ""																							>>$config_file
	echo ""																							>>$config_file
	
	if	[ $mode == "timing" ]; then
			
			echo "#	Observation in timing mode, two files are requested"						>>$config_file
			echo ""																					>>$config_file
			
			echo "${green}Observation in timing mode ${reset}"  
			echo "${yellow}	timing event raw file: ${reset}"
			read arg
			echo "		eventfile="$arg																>>$config_file
			
			echo "${yellow}	imaging event raw file: ${reset} "
			read arg
			echo "		imagingeventfile="$arg																>>$config_file
			
	
	elif	[ $mode == "imaging" ]; then

			echo "${green}Observation in imaging mode ${reset}"  

			echo "# Observation in imaging mode, one file are requested"							>>$config_file
			echo ""																					>>$config_file
			echo "${yellow}	Event raw file ?${reset}"
			read arg
			echo "		eventfile="$arg																	>>$config_file
	
			else
			
			echo "${red} Camera mode doesn't match, exit....${reset}"
			return
	
	fi
			
	echo ""																									>>$config_file		
	echo ""																									>>$config_file		
	echo ""																									>>$config_file		
	
#Additional parameters to be set later

#rate parameter. Here it is assumed a value of 0.35 for MOS and 0.4 for PN, but it could be changed

	echo "#">>$config_file	
	echo "#Rate for filtering">>$config_file
	echo "#">>$config_file	
	echo "#It is assumed a value of 0.35 for MOS and 0.4 for PN">>$config_file
	echo "">>$config_file
	echo "">>$config_file
	
	
	if [ $camera == "pn" ]; then
				echo "		rate=0.4">>$config_file
			else
				echo "		rate=0.35">>$config_file
	fi

	echo "">>$config_file
	echo "">>$config_file

##Extraction regions
##Defining the extraction regions for both source and background contributions

	echo "#">>$config_file	
	echo "#Extraction regions">>$config_file
	echo "#">>$config_file	
	echo "#Feel free to edit these values. They change depending on source">>$config_file
	echo "">>$config_file
	if [ $mode == "timing" ]; then
			
			if [ $camera == "mos1" ] || [ $camera == "mos2" ]; then

				
				echo "#Source extraction">>$config_file
				echo "">>$config_file
				echo "		sourceextraction=\"(RAWX>=29) && (RAWX<=47)\"">>$config_file
				echo "#Background extraction">>$config_file
				echo "">>$config_file
				echo "		bkgextraction=\"((X,Y) in circle(0.,0.,0.))\"">>$config_file
				else 
				
				echo "#Source extraction">>$config_file
				echo "">>$config_file
				echo "		sourceextraction=\"(RAWX>=29) && (RAWX<=47)\"">>$config_file
				echo "#Background extraction">>$config_file
				echo "">>$config_file
				echo "		bkgextraction=\"(RAWX>=29) && (RAWX<=47)\"">>$config_file

			fi

		else

			echo "#Source extraction">>$config_file
			echo "">>$config_file
			echo "		sourceextraction=\"((X,Y) in circle(0.,0.,0.))\"">>$config_file
			echo "#Background extraction">>$config_file
			echo "">>$config_file
			echo "		bkgextraction=\"((X,Y) in circle(0.,0.,0.))\"">>$config_file

	fi
	echo "">>$config_file
	echo "">>$config_file
	
#Spectrum
	echo "#">>$config_file	
	echo "#	Spectrum"																							>>$config_file
	echo "#">>$config_file	
	echo ""																										>>$config_file
	echo ""																										>>$config_file
	echo ""																										>>$config_file


#Lightcurve
	
	echo "#">>$config_file	
	echo "#	Lightcurve parameters"																				>>$config_file
	echo "#">>$config_file	
	echo "#	LC resolution in s"																					>>$config_file
	echo ""																										>>$config_file
	echo "		lctimeresolution="																					>>$config_file
	echo ""																										>>$config_file
	echo "#Energy extraction range in eV">>$config_file
	echo "# The range could be edited later">>$config_file
	echo "		Emin=200">>$config_file
	echo "		Emax=12000">>$config_file



			


