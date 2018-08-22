#!/bin/bash

#  execution.sh
#  
#  Manuel Castro Avila <manuel.castro@inpe.br>
#  
#  28-02-2017
#  
#  National Institute for Space Research (INPE),  São José dos Campos, SP, Brazil



#Colors for outputtig print

	red=`tput setaf 1`
	green=`tput setaf 2`
	yellow=`tput setaf 3`
	blue=`tput setaf 4`
	reset=`tput sgr0`


	CONFIG_FILE=./$1
#	`heainit`
#	source /home/castro/PROGRAMS/SAS_15/xmmsas_20160201_1833/sas-setup.sh
	
	
	
if	[[	-f $CONFIG_FILE	]]; then
		. $CONFIG_FILE
		
		
		else
		
		echo "${red}Configuration file doesn't provided${reset}"
		return 
fi



#evselect table=1467_0502290101_EPN_U002_TimingEvts.ds  withrateset=Y     rateset=PSRJ0030_ratefile_pn_timing.fits  maketimecolumn=Y   timebinsize=100 makeratecolumn=Y  expression="#XMMEA_EP && (PI>10000 && PI<12000) && (PATTERN==0)"


##Check existence of SAS tools already loaded

if	[ -v SAS_PATH  ] && [ -v SAS_CCF ] && [ -v SAS_ODF ];  then
		
		echo "${green}SAS tools already loaded${reset}"
		
		else
		echo "${red}SAS tools don't loaded..check heainit and load SAS tools${reset}"
		return 

fi

##############################################
##############print variables#################


echo "${yellow}"
echo "********************************************"
echo "********Environment variables***************"
echo "********************************************"


echo "SAS_DIR="$SAS_DIR
echo "SAS_CCFPATH="$SAS_CCFPATH
echo "SAS_ODF="$SAS_ODF
echo "SAS_CCF="$SAS_CCF
echo "**********************************************"
echo "${reset}"

#######################################################
#######################################################


    echo	"${yellow}"
    echo 	"***************************************************************************"
    echo	"*                    CONFIGURATION                                        *"
    echo 	"*Source name:          "$sourcename
	echo 	"*camera:               "$camera
	echo 	"*mode:                 "$mode
	echo 	"*eventfile:            "$eventfile
	if [ -n "$imagingeventfile" ]; then
	echo    "*imagingeventfile:     "$imagingeventfile 
	fi
	echo	"*rate:                 "$rate	
	echo 	"*sourceextraction:     "$sourceextraction
	echo	"*bkgextraction:        "$bkgextraction
		
	echo 	"***************************************************************************${reset}"




	echo	"${green}"
	echo	"****************************************************************************"
	echo 	"*                 1)filter                                                 *"
	echo 	"*                 2)pileup                                                 *"
	echo 	"*                 3)spectrum                                               *"
	echo	"*                 4)lc                                                     *"
	echo 	"*                                                                          *"
	echo 	"****************************************************************************${reset}"

##Log file
	logfile=log.txt

##funtion

function success {


if [ $1 -eq 0 ]; then
	echo "success"
	else
	echo "fail"
fi
echo "${reset}"
}
	
#Filtering the events 

		ratefile="$sourcename"_ratefile_"$camera"_"$mode".fits
		gtifile="$sourcename"_gti_"$camera"_"$mode".fits
		cleaneventfile="$sourcename"_"$camera"_"$mode"_clean.fits		
#Filtering when mos is in timing mode. In this case two files are generated: TimingEvts and ImagingEvts.

if [ -z "$imagingeventfile" ]; then
		echo "${yellow} Imaging file when mos in timing mode don't generate..${reset}"
		else
	
		ratefile_ima="$sourcename"_ratefile_"$camera"_"$mode"_imaging.fits
		gtifile_ima="$sourcename"_gti_"$camera"_"$mode"_imaging.fits
		cleaneventfile_ima="$sourcename"_"$camera"_"$mode"_imaging_clean.fits
		

fi



#Image for both source and background extraction

						
		source_image="$sourcename"_"$camera"_"$mode"_source_image.fits
		bkg_image="$sourcename"_"$camera"_"$mode"_bkg_image.fits

	echo "${yellow}Task:${reset}"
	
	
	read arg
case $arg in 

######
####Option 1 ####
########

	1)
		echo "${green}filtering:${reset}"

if	[ $camera == "pn" ]; then

		echo "pn"
#	Expression of filtering
		expression_filter="#XMMEA_EP && (PI>10000&&PI<12000) && (PATTERN==0)"	
		rate_express="RATE<=$rate"
		expression_clean="#XMMEA_EP && gti("$gtifile",TIME) && (PI>150)"

elif	[ $camera == "mos1"  ] || [ $camera == "mos2" ]; then
		echo "mos"
	
		expression_filter="#XMMEA_EM && (PI>10000) && (PATTERN==0)"	
		rate_express="RATE<=$rate"
		expression_clean="#XMMEA_EM && gti("$gtifile",TIME) && (PI>150)"
		
fi
		
									
			
evselect table="$eventfile"  withrateset=Y rateset="$ratefile" maketimecolumn=Y   timebinsize=100 makeratecolumn=Y expression="$expression_filter" 
echo "${yellow}"
echo "Step 1 of filtering: `success $?`"
#	
tabgtigen table=$ratefile expression="$rate_express" gtiset=$gtifile >/dev/null	
echo "Step 2 of filtering: `success $?`"
###
evselect table=$eventfile  withfilteredset=Y filteredset=$cleaneventfile destruct=Y keepfilteroutput=T expression="$expression_clean" >/dev/null
echo "Step 3 of filtering: `success $?`"
echo "${reset}"
###log

echo "##Filtering">$logfile
echo "">>$logfile


echo "evselect table="$eventfile"  withrateset=Y rateset="$ratefile" maketimecolumn=Y   timebinsize=100 makeratecolumn=Y expression='"$expression_filter"' ">>$logfile
echo "">>$logfile
echo "tabgtigen table=$ratefile expression='"$rate_express"' gtiset=$gtifile">>$logfile
echo "">>$logfile
echo "evselect table=$eventfile  withfilteredset=Y filteredset=$cleaneventfile destruct=Y keepfilteroutput=T expression='"$expression_clean"'">>$logfile
echo "">>$logfile




if [ -n "$imagingeventfile" ]; then
	echo "${green} Filtering second file, imaging data events${reset}"
 
		expression_clean_ima="#XMMEA_EM && gti("$gtifile_ima",TIME) && (PI>150)"
	evselect table="$imagingeventfile"  withrateset=Y rateset="$ratefile_ima" maketimecolumn=Y   timebinsize=100 makeratecolumn=Y expression="$expression_filter" >/dev/null
echo "${yellow}"
echo "Step 1 of filtering: `success $?`"
#       
	tabgtigen table=$ratefile_ima expression="$rate_express" gtiset=$gtifile_ima >/dev/null 
echo "Step 2 of filtering: `success $?`"
###
	evselect table=$imagingeventfile withfilteredset=Y filteredset=$cleaneventfile_ima destruct=Y keepfilteroutput=T expression="$expression_clean_ima" >/dev/null
echo "Step 3 of filtering: `success $?`"
echo "${reset}"


##log


	echo "#Filtering second file, imaging data events">>$logfile
	echo "">>$logfile
	echo "evselect table="$imagingeventfile"  withrateset=Y rateset="$ratefile_ima" maketimecolumn=Y   timebinsize=100 makeratecolumn=Y expression='"$expression_filter"' ">>$logfile
	echo "">>$logfile
	echo "tabgtigen table=$ratefile_ima expression='"$rate_express"' gtiset=$gtifile_ima">>$logfile
	echo "">>$logfile
	echo "evselect table=$imagingeventfile withfilteredset=Y filteredset=$cleaneventfile_ima destruct=Y keepfilteroutput=T expression='"$expression_clean_ima"'">>$logfile
	echo "">>$logfile

	else
		echo "${red}false${reset}"

fi

##
##Correction by barycenter
##

cp $cleaneventfile "$sourcename"_"$camera"_"$mode"_nobary_correc.fits

echo "${yellow}Barycentric correction${reset}"
barycen table=$cleaneventfile::EVENTS


#If imagingeventfile defined 

	
if [ -n "$imagingeventfile" ]; then
		echo "${yellow}Barycentric correction for second file with imaging data${reset}"	
		cp $cleaneventfile_ima "$sourcename"_"$camera"_"$mode"_imaging_nobary_correc.fits
		barycen table=$cleaneventfile_ima::EVENTS

fi

#
#Image for both spectral and lightcurve extraction 
#
	echo "${yellow}Imaging the observed field ${reset}"	



	if [ $mode == "timing" ]; then
		echo "">>$logfile
	
		if [ $camera == "mos1" ] || [ $camera == "mos2" ]; then
			
			echo "##Image for ${camera} in ${mode}">>$logfile
			echo "">>$logfile
	
			evselect table=$cleaneventfile imagebinning=binSize imageset=$source_image withimageset=yes  xcolumn=RAWX ycolumn=TIME ximagebinsize=1 yimagebinsize=1 >/dev/null

##log	
		echo "evselect table=$cleaneventfile imagebinning=binSize imageset=$source_image withimageset=yes  xcolumn=RAWX ycolumn=TIME ximagebinsize=1 yimagebinsize=1">>$logfile
			echo "${yellow}Image for ${camera} in ${mode} was produced?: `success $?` ${reset}"

			elif [ $camera == "pn" ]; then

			echo "Image for ${camera} in ${mode}">>$logfile
			echo "">>$logfile			
			evselect table=$cleaneventfile imagebinning=binSize imageset=$source_image withimageset=yes   xcolumn=RAWX ycolumn=RAWY ximagebinsize=1 yimagebinsize=1 >/dev/null
##log

			echo "evselect table=$cleaneventfile imagebinning=binSize imageset=$source_image withimageset=yes xcolumn=RAWX ycolumn=RAWY ximagebinsize=1 yimagebinsize=1">>$logfile
		
		fi

	
	elif [ $mode == "imaging" ]; then
		
		echo "##Image for ${camera} in ${mode}">>$logfile
		echo "">>$logfile
		evselect table=$cleaneventfile imagebinning=binSize imageset=$source_image  withimageset=yes  xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80>/dev/null	
##log
		echo "evselect table=$cleaneventfile imagebinning=binSize imageset=$source_image withimageset=yes  xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80" >>$logfile
		echo "">>$logfile
	fi
	echo "${yellow}Image was produced?: `success $?` ${reset}"


if [ -n "$imagingeventfile" ]; then
		echo "Image for second file in imaging mode for mos in timing mode">>$logfile
		echo "">>$logfile
		evselect table=$cleaneventfile_ima imagebinning=binSize imageset=$bkg_image  withimageset=yes  xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80>/dev/null
		echo "${yellow}Image for background extraction produced?: `success $?` ${reset}"

##log
		echo "evselect table=$cleaneventfile_ima imagebinning=binSize imageset=$bkg_image withimageset=yes  xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80">>$logfile
		echo "">>$logfile

fi 

	
		;;


#######
###Option 2 ####
#######


2)
		echo "${blue}Pile-up analysis${reset}"


evselect table=$cleaneventfile withfilteredset=yes filteredset=pn_filtered.evt keepfilteroutput=yes expression="${sourceextraction} && gti(${gtifile},TIME)"	

epatplot set=pn_filtered.evt plotfile="pn_filtered_pat.ps" 

		;;



#####
###Option 3 ###
######


3) 
##
##Espectral extraction
##	
	echo "${blue}Spectral extraction${reset}"


	if [ $camera == "pn" ]; then
			echo "${yellow} Spectral extraction from $camera in $mode mode${reset}" 
			filter_express="(FLAG==0) && (PATTERN<=4)"
	
		else	
			echo "${yellow} Spectral extraction from $camera in $mode mode${reset}" 
			filter_express="#XMMEA_EM && (PATTERN<=12)" 
	fi


	source_signal_spec="$sourcename"_"$camera"_"$mode"_source_spectrum.fits
	bkg_signal_spec="$sourcename"_"$camera"_"$mode"_bkg_spectrum.fits
	source_spec="$sourcename"_"$camera"_"$mode"_spectrum.fits
	rmf_matrix="$sourcename"_"$camera"_"$mode".rmf
	arf_matrix="$sourcename"_"$camera"_"$mode".arf

###
###Spectral extraction from pn camera
####
	if [ $camera == "pn" ]; then

#Source spectral extraction
			evselect table=$cleaneventfile withspectrumset=yes spectrumset=$source_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479  expression="${filter_express}&&${sourceextraction}" >/dev/null

	echo "${yellow}Source spectral extraction: `success $?`"

	

#Background spectral extraction


		 evselect table=$cleaneventfile withspectrumset=yes spectrumset=$bkg_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479 expression="${filter_express}&&${bkgextraction}">/dev/null

	echo "${yellow}Background spectral extraction: `success $?`"

	fi
	
###Calculate the area of source and background region used to make the spectral files
##
##
##	backscale spectrumset=$source_signal_spec badpixlocation=$cleaneventfile > /dev/null
##	backscale spectrumset=$bkg_signal_spec badpixlocation=$cleaneventfile >/dev/null
##
##	echo "${yellow}Backscale: `success $?`"
##
###Generate a redistribution matrix
##
##		rmfgen spectrumset=$source_signal_spec rmfset=$rmf_matrix>/dev/null
##		echo "${yellow}rfmgen: `success $?`"
##
###Generate an ancillary file
##
##		arfgen spectrumset=$source_signal_spec arfset=$arf_matrix withrmfset=yes rmfset=$rmf_matrix  badpixlocation=$cleaneventfile  detmaptype=psf >/dev/null
##		echo "${yellow}arfgen: `success $?`"
##
###Rebin the spectrum and link associated files
##
##	 specgroup spectrumset=$source_signal_spec mincounts=25 oversample=3 rmfset=$rmf_matrix arfset=$arf_matrix backgndset=$bkg_signal_spec groupedset=$source_spec >/dev/null
##		echo "${yellow}specgroup: `success $?`"
##
##	echo "${reset}"


###Spectral extraction from MOS cameras


if [ $camera == "mos1" ] || [ $camera == "mos2" ]; then
	
##Source extraction 
	if [ $mode == "timing" ]; then
		evselect table=$cleaneventfile withspectrumset=yes spectrumset=$source_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999 expression="(FLAG==0) && (PATTERN<=0) && ${sourceextraction}" >/dev/null
		else
		 evselect table=$cleaneventfile  withspectrumset=yes spectrumset=$source_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999 expression="${filter_express}&&${sourceextraction}">/dev/null

	fi	
	echo "${yellow}Source spectral extraction: `success $?`"

##Background extraction 
	
	if [ -n "$imagingeventfile" ]; then
		
		 evselect table=$cleaneventfile_ima withspectrumset=yes spectrumset=$bkg_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999  expression="(FLAG==0) && (PATTERN<=1 || PATTERN==3) && ${bkgextraction}">/dev/null
		else
		
		evselect table=$cleaneventfile withspectrumset=yes spectrumset=$bkg_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999 expression="${filter_express}&&${bkgextraction}" >/dev/null


 	fi

fi

echo "${yellow}Background spectral extraction: `success $?`"

#Calculate the area of source and background region used to make the spectral files


        backscale spectrumset=$source_signal_spec badpixlocation=$cleaneventfile > /dev/null
	echo "${yellow}Backscale for source: `success $?`"
 if [ -n "$imagingeventfile" ]; then
		backscale spectrumset=$bkg_signal_spec badpixlocation=$cleaneventfile_ima >/dev/null

		else 
	        backscale spectrumset=$bkg_signal_spec badpixlocation=$cleaneventfile >/dev/null

fi 

        echo "${yellow}Backscale for background: `success $?`"

	

#Generate a redistribution matrix

                rmfgen spectrumset=$source_signal_spec rmfset=$rmf_matrix>/dev/null
                echo "${yellow}rfmgen: `success $?`"

#Generate an ancillary file

		arfgen spectrumset=$source_signal_spec arfset=$arf_matrix withrmfset=yes rmfset=$rmf_matrix  badpixlocation=$cleaneventfile  detmaptype=psf >/dev/null
                echo "${yellow}arfgen: `success $?`"


#Rebin the spectrum and link associated files

         specgroup spectrumset=$source_signal_spec mincounts=25 oversample=3 rmfset=$rmf_matrix arfset=$arf_matrix backgndset=$bkg_signal_spec groupedset=$source_spec >/dev/null
                echo "${yellow}specgroup: `success $?`"

#log

echo "#Source spectral extraction">$logfile
echo "">>$logfile
	if [ $camera == "pn" ]; then
			echo "evselect table=$cleaneventfile withspectrumset=yes spectrumset=$source_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479  expression="${filter_express}"&&"${sourceextraction}"">>$logfile

		echo "">>$logfile
		echo "# Background spectral extraction">>$logfile 
 		echo "">>$logfile
		echo "evselect table=$cleaneventfile withspectrumset=yes spectrumset=$bkg_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479 expression="${filter_express}"&&"${bkgextraction}"">>$logfile
		echo "">>$logfile

			else
			if [ $mode == "timing" ]; then
				echo "evselect table=$cleaneventfile withspectrumset=yes spectrumset=$source_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999 expression='(FLAG==0) &&(PATTERN<=0)&& ${sourceextraction}'" >>$logfile
				else
				echo "evselect table=$cleaneventfile  withspectrumset=yes spectrumset=$source_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999 expression='"${filter_express}"&&"${sourceextraction}"' " >>$logfile
			fi

			echo "">>$logfile
			echo "# Background spectral extraction">>$logfile

			if [ -n "$imagingeventfile" ]; then
				echo "evselect table=${cleaneventfile_ima} withspectrumset=yes spectrumset=${bkg_signal_spec} energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999  expression='(FLAG==0) && (PATTERN<=1 || PATTERN==3)&&${bkgextraction}'" >>$logfile

				else

				echo "evselect table=$cleaneventfile withspectrumset=yes spec    trumset=$bkg_signal_spec energycolumn=PI spectralbinsize=5 withspecrang    es=yes specchannelmin=0 specchannelmax=11999 expression="${filter_express}"&&"${bkgextraction}"" >>$logfile
			fi

	fi

	echo "">>$logfile

	echo "#Calculate the area of source and background regions">>$logfile
	echo "">>$logfile
	echo "backscale spectrumset=$source_signal_spec badpixlocation=$cleaneventfile">>$logfile
	if [ -n "$imagingeventfile" ]; then
		echo "backscale spectrumset=$bkg_signal_spec badpixlocation=$cleaneventfile_ima">>$logfile
				
		else 	
		echo "backscale spectrumset=$bkg_signal_spec badpixlocation=$cleaneventfile">>$logfile

	fi 


	echo "">>$logfile

	echo "#Generate a redistribution matrix">>$logfile
	echo "">>$logfile
	echo "rmfgen spectrumset=$source_signal_spec rmfset=$rmf_matrix">>$logfile
	echo "">>$logfile
	echo "#Generate an ancillary file">>$logfile
	echo "">>$logfile
	echo "arfgen spectrumset=$source_signal_spec arfset=$arf_matrix withrmfset=yes rmfset=$rmf_matrix  badpixlocation=$cleaneventfile  detmaptype=psf">>$logfile
	echo "">>$logfile
	echo "#Rebin the spectrum and link associated files">>$logfile
	echo "">>$logfile
	echo "specgroup spectrumset=$source_signal_spec mincounts=25 oversample=3 rmfset=$rmf_matrix arfset=$arf_matrix backgndset=$bkg_signal_spec groupedset=$source_spec">>$logfile

	;;


#####
##Option 4 ###
#######

4)
	echo "${blue}"
	echo "**********Lightcurve Extraction***********"
	echo "${reset}"
	
	
if [ -z "$lctimeresolution" ]; then
		echo "${red}LC resolution wasn't defined ${reset}"
		exit 0
	else 
		echo "${green}LC resolution of "${lctimeresolution}" s"
fi
	


	if [ $camera == "pn" ]; then
		
			filter_express="#XMMEA_EP&&(FLAG==0)&&(PATTERN<=4) && (PI in [${Emin}:${Emax}])"
	
		else	
			filter_express="#XMMEA_EM && (PATTERN<=12) && (PI in [${Emin}:${Emax}])"
	fi



##Output files

#scale of timing resolution
#	b=1
#	if [ "$lctimeresolution" -lt "$b" ]; then
	if (( $(echo "$lctimeresolution < 1" |bc -l) )); then
# awk was necessary here to fix the precision, so the result will be printed without decimals
		scale=`echo "scale=6;(${lctimeresolution})*1000."| bc | awk '{printf "%0.0f\n", $0}'`
		lcresolution="${scale}ms"
		else
		lcresolution="${lctimeresolution}s"
	fi		


##Scaling energy range

#	Emin

	if (( $(echo "$Emin < 1000" |bc -l) )); then
			ScaleEmin="0"`echo "scale=4;$Emin/100"| bc| awk '{printf "%1.0f\n",$0}'`
			else
			ScaleEmin=`echo "scale=4;$Emin/1000"| bc| awk '{printf "%1.0f\n",$0}'`
	fi
		
#	Emax

	if (( $(echo "$Emax < 1000" |bc -l) )); then
			ScaleEmax="0"`echo "scale=4;$Emax/100"| bc| awk '{printf "%1.0f\n",$0}'`
			else
			ScaleEmax=`echo "scale=4;$Emax/1000"| bc| awk '{printf "%0.0f\n",$0}'`

	fi	


###########################
	echo "${blue}"
	echo "          LC extraction between "${ScaleEmin}" e "${ScaleEmax}" keV"
	echo "${reset}"



	source_signal="$sourcename"_"$camera"_"$mode"_source_"$ScaleEmin"-"$ScaleEmax"keV_"$lcresolution".lc
	bkg_signal="$sourcename"_"$camera"_"$mode"_bkg_"$ScaleEmin"-"$ScaleEmax"keV_"$lcresolution".lc
	source_lc="$sourcename"_"$camera"_"$mode"_lc_"$ScaleEmin"-"$ScaleEmax"keV_"$lcresolution".lc



##Source extraction

echo "${yellow}"
evselect table=$cleaneventfile energycolumn=PI  expression="${filter_express}&&${sourceextraction}" withrateset=yes rateset=$source_signal timebinsize=$lctimeresolution maketimecolumn=yes makeratecolumn=yes >/dev/null

echo "Source extraction: `success $?` "

##background extraction

evselect table=$cleaneventfile energycolumn=PI  expression="${filter_express}&&${bkgextraction}" withrateset=yes rateset=$bkg_signal timebinsize=$lctimeresolution maketimecolumn=yes makeratecolumn=yes >/dev/null

echo "Background extraction: `success $?` "

##Combine

epiclccorr srctslist=$source_signal eventlist=$cleaneventfile outset=$source_lc bkgtslist=$bkg_signal withbkgset=yes applyabsolutecorrections=yes > /dev/null

echo "Combining source + bkg: `success $?` "
echo "${reset}"


##log

echo "#Light curve extraction" >$logfile
echo "">>$logfile
echo "#source extraction ">>$logfile
echo "evselect table="$cleaneventfile" energycolumn=PI  expression="${filter_express}"&&"${sourceextraction}" withrateset=yes rateset=$source_signal timebinsize=$lctimeresolution maketimecolumn=yes makeratecolumn=yes" >>$logfile
echo "">>$logfile	
echo "#background extraction">>$logfile
echo "">>$logfile
echo "evselect table=$cleaneventfile energycolumn=PI  expression="${filter_express}"&&"${bkgextraction}" withrateset=yes rateset=$bkg_signal timebinsize=$lctimeresolution maketimecolumn=yes makeratecolumn=yes">>$logfile
echo "">>$logfile
echo "#Combine">>$logfile
echo "">>$logfile
echo "epiclccorr srctslist=$source_signal eventlist=$cleaneventfile outset=$source_lc bkgtslist=$bkg_signal withbkgset=yes applyabsolutecorrections=yes">>$logfile


	
;;		
	esac
	
