#!/bin/bash

# @author	   : Manuel Castro Avila <manuel.castro@inpe.br>
# @file		   : conf.sh	
# @created	   : 28-Feb-2017
#  National Institute for Space Research (INPE),  São José dos Campos, SP, Brazil

##################################################################################
##################################################################################
#  This script has been developed under financial support from FAPESP (Fundação  #
#  de Amparo à Pesquisa do Estado de São Paulo, Brazil) under grant #2015/25972-0#
##################################################################################
##################################################################################

#Colors for outputting print

	red=`tput setaf 1`
	green=`tput setaf 2`
	yellow=`tput setaf 4`
	blue=`tput setaf 6`
	reset=`tput sgr0`

############################################################ 
#   you must provide a filename in which  local variables  # 
#   will be written down                                   # 
############################################################ 

#check whether a filename was provided
	
if [ -z $1 ]; then
    echo "${red} You provided no filename ${reset}          "
	return
fi


if [[ -f $1 ]]; then 
    echo "${red} File $1 already exists ${reset}            "
	return
fi


##	
	config_file=$1

    echo "#!"/"bash"/"bash"                                                 >$config_file

	
    echo "# *************Configuration file *************   "               >>$config_file
    echo "#     `date +"%d-%b-%Y"`                          "               >>$config_file
    echo "                                                  "               >>$config_file

#	Source name
 
	echo "#                                                 "				>>$config_file
	echo "#Source name                                      "				>>$config_file
	echo "#                                                 "				>>$config_file	
	echo "                                                  "				>>$config_file
	echo "${green}Source name ${reset}                      "
	read arg
	echo "		sourcename="$arg                                            >>$config_file
	
	echo "                                                  "               >>$config_file




	echo "#                                                 "               >>$config_file	
	echo "#	Instrument's features                           "				>>$config_file
	echo "#                                                 "               >>$config_file	
	echo "                                                  "				>>$config_file
	
	echo "${green}Camera (pn, mos1 or mos2) ?${reset}       "
	read arg
	camera=$arg


    if [ $camera != "pn" ] && [ $camera != "mos1" ] && [ $camera != "mos2" ]; then
            echo "${red} Camera doesn't match, exit....${reset}"
            return
    fi

	echo "		camera="$camera								                >>$config_file
	
	echo "${green}mode (timing or imaging)?${reset}         "
	read arg
	mode=$arg
	echo "		mode="$arg							                        >>$config_file
	
	
	echo "                                                  "				>>$config_file
	echo "                                                  "				>>$config_file
	
#Tag--> label output files
    echo "#Tag to label output files"                                       >>$config_file
    echo "#It can be changed at any time"                                   >>$config_file
    echo "${green}tag:${reset}"
    read arg
    echo "      tag="$arg                                                  >>$config_file           
# 	Event file
	
	echo "#                                                 "               >>$config_file	
	echo "#Raw data                                         "				>>$config_file
	echo "#                                                 "               >>$config_file	
	echo "                                                  "				>>$config_file
	
########################################################################################################	
########################################################################################################	
#   Even that the SAS Data analysis threads (https://www.cosmos.esa.int/web/xmm-newton/sas-threads)    #        	
#   recommend extracting the source contribution from the event file in timing mode and the            # 
#   background contribution from the event file in imaging mode (data acquisition for  EPIC/MOS        # 
#   operating in timing mode), the script only requires the event file in timing mode. From this        # 
#   event file both contributions (source and background) are extracted. This because make more sense  # 
#   extract the data for both cases from the same file (it was generated under the same operating      #  
#   conditions) either that separated files generated by different operating modes.                    #  
######################################################################################################## 	
######################################################################################################## 	

	if	[ $mode == "timing" ]; then

            echo "#	Observation in timing mode"                                 >>$config_file
            echo "# provide event file in timing mode"	                        >>$config_file
			echo "                                          "				    >>$config_file
			
			echo "${green}Observation in timing mode ${reset}"  
			echo "${yellow}	timing event raw file: ${reset}"
			read arg
			echo "		eventfile="$arg                                         >>$config_file
			
#			echo "${yellow}	imaging event raw file: ${reset} "
#			read arg
#			echo "		imagingeventfile="$arg                                  >>$config_file
			
	
	elif	[ $mode == "imaging" ]; then

			echo "${green}Observation in imaging mode ${reset}"  
			echo "# Observation in imaging mode, one file are requested"	    >>$config_file
			echo "${yellow}	Event raw file ?${reset}          "
			read arg
			echo "		eventfile="$arg                                         >>$config_file
	
	else
			
			echo "${red} Camera mode doesn't match, exit....${reset}"
			return
	
	fi
			
	echo "                                                    "				    >>$config_file		
	
#Additional parameters to be set later

#rate parameter. Here it is assumed a value of 0.35 for MOS and 0.4 for PN, but it could be changed

	echo "#                                                     "               >>$config_file	
	echo "#Rate for filtering                                   "               >>$config_file
	echo "#                                                     "               >>$config_file	
	echo "#It is assumed a value of 0.35 for MOS and 0.4 for PN "               >>$config_file
	echo "                                                      "               >>$config_file
        	
	
	if [ $camera == "pn" ]; then
				echo "		rate=0.4                            "               >>$config_file
			else
				echo "		rate=0.35                           "               >>$config_file
	fi

	echo "                                                      "               >>$config_file

##Extraction regions
##Defining the extraction regions for both source and background contributions

	echo "#                                                     "               >>$config_file	
	echo "#Extraction regions">>$config_file
	echo "#">>$config_file	
	echo "#Feel free to edit these values. They change depending on source"     >>$config_file
	echo "                                                      "               >>$config_file
	if [ $mode == "timing" ]; then
			
#			if [ $camera == "mos1" ] || [ $camera == "mos2" ]; then
#
#				
#				echo "#Source extraction">>$config_file
#				echo "">>$config_file
#				echo "		sourceextraction=\"(RAWX>=29) && (RAWX<=47)\"">>$config_file
#				echo "#Background extraction">>$config_file
#				echo "">>$config_file
#				echo "		bkgextraction=\"((X,Y) in circle(0.,0.,0.))\"">>$config_file
#				else 

#If mode equals timing, source and background will be extracted from the same timing event file				
			echo "#Source extraction                            "                   >>$config_file
			echo "">>$config_file
			echo "		sourceextraction=\"(RAWX>=29) && (RAWX<=47)\""              >>$config_file
			echo "#Background extraction">>$config_file
			echo "">>$config_file
			echo "		bkgextraction=\"(RAWX>=29) && (RAWX<=47)\""                 >>$config_file

#			fi

		else

			echo "#Source extraction                            "                   >>$config_file
			echo "">>$config_file
			echo "		sourceextraction=\"((X,Y) in circle(0.,0.,0.))\""           >>$config_file
			echo "#Background extraction">>$config_file
			echo "">>$config_file
			echo "		bkgextraction=\"((X,Y) in circle(0.,0.,0.))\""              >>$config_file

	fi
	echo "                                                      "                   >>$config_file
	
#Spectrum
	echo "#">>$config_file	
	echo "#	Spectrum                                            "					>>$config_file
	echo "#A few values assumed by default. Based on SAS threads"		            >>$config_file	
	echo "                                                      "					>>$config_file
	echo "mincounts=25                                          "                   >>$config_file
	echo "oversample=3                                          "                   >>$config_file
	echo "                                                      "                   >>$config_file


#Lightcurve
	
	echo "#                                                     "                   >>$config_file	
	echo "#	Lightcurve parameters                               "                   >>$config_file
	echo "#                                                     "                   >>$config_file	
	echo "#	LC resolution in s                                  "                   >>$config_file
	echo "                                                      "                   >>$config_file
	echo "      lctimeresolution=                               "                   >>$config_file
	echo "                                                      "                   >>$config_file
	echo "#Energy extraction range in eV                        "                   >>$config_file
	echo "# The range could be edited later by hand             "                   >>$config_file
	echo "      Emin=200                                        "                   >>$config_file
	echo "      Emax=12000                                      "                   >>$config_file

