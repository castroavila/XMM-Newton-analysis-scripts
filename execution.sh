#!/bin/bash

# @author	   : Manuel Castro Avila <manuel.castro@inpe.br>
# @file		   : execute.sh	
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
	yellow=`tput setaf 3`
	blue=`tput setaf 4`
	reset=`tput sgr0`


	CONFIG_FILE=./$1
	
	
	
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
	
	
	echo "SAS_DIR=          "$SAS_DIR
	echo "SAS_CCFPATH=      "$SAS_CCFPATH
	echo "SAS_ODF=          "$SAS_ODF
	echo "SAS_CCF=          "$SAS_CCF
	echo "**********************************************"
	echo "${reset}"

#######################################################
#######################################################

#Camera exists?

	if [ $camera != "mos1" ] && [ $camera != "mos2" ] && [ $camera != "pn" ]; then
		echo "Camera option: ${camera} doesn't exist"
		return
	fi

#Mode exist?

	if [ $mode != "timing"  ] && [ $mode != "imaging" ]; then
		echo "Camera mode: ${mode} doesn't exist"
		return 
	fi


    	echo	"${yellow}"
    	echo 	"***************************************************************************"
    	echo	"*                    CONFIGURATION                                        *"
    	echo 	"*Source name:          "$sourcename
	echo 	"*camera:               "$camera
	echo 	"*mode:                 "$mode
	echo 	"*eventfile:            "$eventfile
#	if [ -n "$imagingeventfile" ]; then
#	echo    "*imagingeventfile:     "$imagingeventfile 
#	fi
	if [ -n "$lctimeresolution" ]; then
	echo 	"*time resolution:      "$lctimeresolution
	fi
	echo	"*rate:                 "$rate	
	echo 	"*sourceextraction:     "$sourceextraction
	echo	"*bkgextraction:        "$bkgextraction
		
	echo 	"***************************************************************************${reset}"




	echo	"${green}"
	echo	"****************************************************************************"
	echo	"*        Options:                                                          *"
	echo 	"*                 1)filter                                                 *"
	echo 	"*                 2)pileup                                                 *"
	echo 	"*                 3)spectrum                                               *"
	echo	"*                 4)lc                                                     *"
	echo 	"*                                                                          *"
	echo 	"****************************************************************************${reset}"

##Log file
	logfile=log.txt

##function

function success {


if [ $1 -eq 0 ]; then
	echo "success"
	else
	echo "fail"
fi
#echo "${reset}"
}
	
#Filtering the events 

		ratefile=${sourcename}_ratefile_${camera}_${mode}.fits
		gtifile=${sourcename}_gti_${camera}_${mode}.fits
		cleaneventfile=${sourcename}_${camera}_${mode}_clean.fits		
#Filtering when mos is in timing mode. In this case two files are generated: TimingEvts and ImagingEvts.

#if [ -z "$imagingeventfile" ]  &&  [ $camera == "mos1" ] || [ $camera == "mos2" ]  && [ $mode == "timing"  ]; then
#		echo "${yellow} Imaging file when mos in timing mode don't generate..${reset}"
#		else
#	
#		ratefile_ima=${sourcename}_ratefile_${camera}_${mode}_imaging.fits
#		gtifile_ima=${sourcename}_gti_${camera}_${mode}_imaging.fits
#		cleaneventfile_ima=${sourcename}_${camera}_${mode}_imaging_clean.fits
#		
#
#fi



#Image for both source and background extraction

						
		source_image=${sourcename}_${camera}_${mode}_source_image.fits
		bkg_image=_${camera}_${mode}_bkg_image.fits

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
		expression_filter="\" #XMMEA_EP && (PI>10000&&PI<12000) && (PATTERN==0) \""
		rate_express="\"RATE<=${rate}\""
		expression_clean="\" #XMMEA_EP && gti(${gtifile},TIME) && (PI>150) \""

elif	[ $camera == "mos1"  ] || [ $camera == "mos2" ]; then
		echo "mos"
	
		expression_filter="\" #XMMEA_EM && (PI>10000) && (PATTERN==0) \""
		rate_express="\"RATE<=${rate}\""
		expression_clean="\" #XMMEA_EM && gti(${gtifile},TIME) && (PI>150)\""
		
fi
		
									

##create a full string and afterwards execute it
	cmd="evselect table=${eventfile}  withrateset=Y rateset=${ratefile} maketimecolumn=Y   timebinsize=100 makeratecolumn=Y expression=${expression_filter}"
	eval $cmd > /dev/null

#log
	echo "##Filtering">$logfile
	echo "">>$logfile
	echo $cmd >> $logfile			
#evselect table="$eventfile"  withrateset=Y rateset="$ratefile" maketimecolumn=Y   timebinsize=100 makeratecolumn=Y expression="$expression_filter" 
echo "${yellow}"
echo "Step 1 of filtering: `success $?`"
#
	cmd="tabgtigen table=${ratefile} expression=${rate_express} gtiset=${gtifile} "
	eval $cmd >/dev/null
#log 	
	echo "">>$logfile
	echo $cmd >> $logfile
#tabgtigen table=$ratefile expression="$rate_express" gtiset=$gtifile >/dev/null	
echo "Step 2 of filtering: `success $?`"
###
	cmd="evselect table=${eventfile}  withfilteredset=Y filteredset=${cleaneventfile} destruct=Y keepfilteroutput=T expression=${expression_clean}" >/dev/null
	eval $cmd >/dev/null
#log
	echo "" >>$logfile
	echo $cmd>>$logfile
#evselect table=$eventfile  withfilteredset=Y filteredset=$cleaneventfile destruct=Y keepfilteroutput=T expression="$expression_clean" >/dev/null
echo "Step 3 of filtering: `success $?`"
echo "${reset}"


##
##Correction by barycenter
##Check it.. It seems there are a few issues between a barycenter-corrected event file and the  pileup-related tasks..

cp $cleaneventfile ${sourcename}_${camera}_${mode}_nobary_correc.fits

echo "${yellow}Barycentric correction${reset}"
barycen table=$cleaneventfile::EVENTS >/dev/null


#If imagingeventfile defined 

	
if [ -n "$imagingeventfile" ]; then
		echo "${yellow}Barycentric correction for second file with imaging data${reset}"	
		cp ${cleaneventfile_ima} ${sourcename}_${camera}_${mode}_imaging_nobary_correc.fits
		barycen table=$cleaneventfile_ima::EVENTS

fi

#
#Image for both spectral and lightcurve extraction 
#
	echo "${yellow}Imaging the observed field ${reset}"	

	if [ $mode == "timing" ]; then
		echo "">>$logfile
#		echo "##Extracting image -- timing mode">>$logfile

		if [ $camera == "mos1" ] || [ $camera == "mos2" ]; then
			
			echo "##Image for ${camera} in ${mode}">>$logfile
			cmd="evselect table=${cleaneventfile} imagebinning=binSize imageset=${source_image} withimageset=yes  xcolumn=RAWX ycolumn=TIME ximagebinsize=1 yimagebinsize=1"	
			eval $cmd >/dev/null

##log	
			echo $cmd>>$logfile
			echo "${yellow}Image for ${camera} in ${mode} was produced?: `success $?` ${reset}"

			elif [ $camera == "pn" ]; then

			echo "Image for ${camera} in ${mode}">>$logfile
			echo "">>$logfile			
			cmd="evselect table=${cleaneventfile} imagebinning=binSize imageset=${source_image} withimageset=yes   xcolumn=RAWX ycolumn=RAWY ximagebinsize=1 yimagebinsize=1"
			echo "${green}command:"
			echo "                ${cmd}${reset}"
			eval $cmd >/dev/null
##log
			echo $cmd >>$logfile
		
		fi

	
	elif [ $mode == "imaging" ]; then
		echo "">>$logfile
		echo "##Image for ${camera} in ${mode}">>$logfile
		echo "">>$logfile
		cmd="evselect table=$cleaneventfile imagebinning=binSize imageset=$source_image  withimageset=yes  xcolumn=X ycolumn=Y ximagebinsize=80 yimagebinsize=80"
		eval $cmd >/dev/null
##log
		echo $cmd >>$logfile
		echo "">>$logfile
	fi
	echo "${yellow}Image was produced?: `success $?` ${reset}"

#############################################################

	
		;;


#######
###Option 2 ####
#######


2)
	echo "${blue}Pile-up analysis${reset}"
	echo "${blue}Make sure you have defined the extraction properly in the .conf file"
	echo "Since it isn't check in the script${reset}"

	cmd="evselect table=${cleaneventfile} withfilteredset=yes filteredset=pn_filtered.evt keepfilteroutput=yes expression=\"${sourceextraction} && gti(${gtifile},TIME)\" "
	eval $cmd > /dev/null
	echo "${yellow}"
	echo "Step 1 pile-up --> extract clean  event file : `success $?`"

#log 
	echo "##Pile-up commands" > $logfile
	echo $cmd >> $logfile
	
#Output .ps file name
	filename=${camera}_${tag}_filtered_pat.ps	
	cmd="epatplot set=pn_filtered.evt plotfile=${filename}"
	eval $cmd >/dev/null
	echo "Step 2 pile-up --> generate .ps plot to assess pile-up: `success $?`"
	echo "${reset}"
#log	
	echo "" >>$logfile 
	echo $cmd >>$logfile		
#epatplot set=pn_filtered.evt plotfile="pn_filtered_pat.ps" 

		;;



#####
###Option 3 ###
######


3) 
##
##Espectral extraction
##	
	echo "${blue}Spectral extraction${reset}"
	echo "##Spectral extraction" >$logfile


	if [ $camera == "pn" ]; then
			echo "${yellow} Spectral extraction from $camera in $mode mode${reset}" 
			filter_express="(FLAG==0) && (PATTERN<=4)"
	
		else	
			echo "${yellow} Spectral extraction from $camera in $mode mode${reset}" 
			filter_express="#XMMEA_EM && (PATTERN<=12)" 
	fi

	source_signal_spec=${sourcename}_${camera}_${mode}_${tag}_source_spectrum.fits
	bkg_signal_spec=${sourcename}_${camera}_${mode}_${tag}_bkg_spectrum.fits
	source_spec=${sourcename}_${camera}_${mode}_${tag}_spectrum.fits
	rmf_matrix=${sourcename}_${camera}_${mode}_${tag}.rmf
	arf_matrix=${sourcename}_${camera}_${mode}_${tag}.arf

###
###Spectral extraction from pn camera
####
	if [ $camera == "pn" ]; then

#Source spectral extraction
		cmd="evselect table=${cleaneventfile} withspectrumset=yes spectrumset=${source_signal_spec} energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479  expression=\" ${filter_express}&&${sourceextraction}\" "
		eval $cmd > /dev/null
#log		
		echo "">>$logfile
		echo $cmd >>$logfile

		

	echo "${yellow}Source spectral extraction: `success $?`"

	

#Background spectral extraction

		cmd="evselect table=$cleaneventfile withspectrumset=yes spectrumset=$bkg_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=20479 expression=\" ${filter_express}&&${bkgextraction}\" "
		eval $cmd >/dev/null

#log
		echo "">>$logfile
		echo $cmd >>$logfile


	echo "${yellow}Background spectral extraction: `success $?`"

	fi
	

###Spectral extraction from MOS cameras
##check technical  doc since mos1 or 2?  in timing mode only single ?? patterns are allowed

if [ $camera == "mos1" ] || [ $camera == "mos2" ]; then
	echo "" >> $logfile
	echo "##Spectral extraction for $camera in $mode mode"  >>$logfile
	echo "" >> $logfile
##Source extraction 
	if [ $mode == "timing" ]; then
##Spectral extraction, MOS data in timing mode
##
##Source extraction
		cmd="evselect table=$cleaneventfile withspectrumset=yes spectrumset=$source_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999 expression=\"(FLAG==0) && (PATTERN<=0) && ${sourceextraction}\" "
		eval $cmd > /dev/null
		echo "${yellow}Source spectral extraction for $camera in $mode mode: `success $?`"
#log	
		echo "" >> $logfile	
		echo $cmd >> $logfile	
###
##Background extraction for mos in timing mode
		cmd="evselect table=$cleaneventfile withspectrumset=yes spectrumset=$bkg_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999 expression=\"(FLAG==0) && (PATTERN<=0) && ${bkgextraction}\" "
		eval $cmd > /dev/null
		echo "${yellow}Background spectral extraction for $camera in $mode mode: `success $?`"
#log
		echo "" >> $logfile	
		echo $cmd >> $logfile	

		else
#####
###Source spectral extraction -- MOS data imaging mode
		cmd="evselect table=$cleaneventfile  withspectrumset=yes spectrumset=$source_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999 expression=\"${filter_express}&&${sourceextraction}\" "
		eval $cmd > /dev/null
		echo "${yellow}Source spectral extraction for $camera in $mode mode: `success $?`"
#log
		echo "">>$logfile
		echo $cmd >>$logfile
##Background extraction -- MOS data in imaging mode
		cmd="evselect table=$cleaneventfile withspectrumset=yes spectrumset=$bkg_signal_spec energycolumn=PI spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999 expression=\"${filter_express}&&${bkgextraction}\""
		eval $cmd > /dev/null
		echo "${yellow}Background spectral extraction for $camera in $mode mode: `success $?`"
#log
		echo "">>$logfile
		echo $cmd >>$logfile

	fi	

fi


#Calculate the area of source and background region used to make the spectral files

	cmd="backscale spectrumset=${source_signal_spec} badpixlocation=${cleaneventfile}"
	eval $cmd > /dev/null
#log
	echo "" >>$logfile
	echo $cmd >> $logfile
	
#        backscale spectrumset=$source_signal_spec badpixlocation=$cleaneventfile > /dev/null
	echo "${yellow}Backscale for source: `success $?`"


		cmd="backscale spectrumset=${bkg_signal_spec} badpixlocation=${cleaneventfile}"
		eval $cmd >/dev/null
#log
		echo "" >>$logfile
		echo $cmd >>$logfile		

        echo "${yellow}Backscale for background: `success $?`"

	

#Generate a redistribution matrix

		cmd="rmfgen spectrumset=${source_signal_spec} rmfset=${rmf_matrix}"
		eval $cmd >/dev/null
#log 
		echo "" >>$logfile
		echo $cmd >>$logfile		
                echo "${yellow}rfmgen: `success $?`"

#Generate an ancillary file
			
		cmd="arfgen spectrumset=${source_signal_spec} arfset=${arf_matrix} withrmfset=yes rmfset=${rmf_matrix}  badpixlocation=${cleaneventfile}  detmaptype=psf"	
		eval $cmd >/dev/null
#log
		echo "">>$logfile
		echo $cmd >>$logfile	
                echo "${yellow}arfgen: `success $?`"


#Rebin the spectrum and link associated files
	
		cmd="specgroup spectrumset=${source_signal_spec} mincounts=${mincounts} oversample=${oversample} rmfset=${rmf_matrix} arfset=${arf_matrix} backgndset=${bkg_signal_spec} groupedset=${source_spec}"
		eval $cmd >/dev/null
#log
	echo "">>$logfile
	echo $cmd>>$logfile
                echo "${yellow}specgroup: `success $?`"


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
		return 
	else 
		echo "${green}LC resolution of "${lctimeresolution}" s"
fi
	


	if [ $camera == "pn" ]; then
		filter_express="#XMMEA_EP && (FLAG==0) && (PATTERN<=4) && (PI in [${Emin}:${Emax}])"
	elif [ $camera == "mos1" ] || [ $camera == "mos2" ]; then
			if [ $mode == "timing" ]; then
				filter_express="(FLAG==0) && (PATTERN<=0) && (PI in [${Emin}:${Emax}])"	
				else
				filter_express="#XMMEA_EM && (PATTERN<=12) && (PI in [${Emin}:${Emax}])" 
			fi

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
	echo "          LC extraction between "${ScaleEmin}" and "${ScaleEmax}" keV"
	echo "${reset}"



	source_signal=${sourcename}_${camera}_${mode}_${tag}_source_${ScaleEmin}-${ScaleEmax}keV_${lcresolution}.lc
	bkg_signal=${sourcename}_${camera}_${mode}_${tag}_bkg_${ScaleEmin}-${ScaleEmax}keV_${lcresolution}.lc
	source_lc=${sourcename}_${camera}_${mode}_${tag}_lc_${ScaleEmin}-${ScaleEmax}keV_${lcresolution}.lc

	echo "##Light curve extraction " >$logfile
	echo "## ${camera} in ${mode} with ${lcresolution}-s bin" >>$logfile	

##Source extraction

	echo "${yellow}"
	cmd="evselect table=${cleaneventfile} energycolumn=PI  expression=\"${filter_express} && ${sourceextraction}\" withrateset=yes rateset=${source_signal} timebinsize=${lctimeresolution} maketimecolumn=yes makeratecolumn=yes"
	eval $cmd > /dev/null
	echo "LC extraction for source: `success $?`"
#log
	echo "">>$logfile
	echo $cmd>>$logfile



##background extraction

	cmd="evselect table=${cleaneventfile} energycolumn=PI  expression=\"${filter_express} && ${bkgextraction}\" withrateset=yes rateset=${bkg_signal} timebinsize=${lctimeresolution} maketimecolumn=yes makeratecolumn=yes"

	eval $cmd > /dev/null
	echo "Background extraction: `success $?` "
#log
	echo "">>$logfile
	echo $cmd>>$logfile


##Combine
	cmd="epiclccorr srctslist=${source_signal} eventlist=${cleaneventfile} outset=${source_lc} bkgtslist=${bkg_signal} withbkgset=yes applyabsolutecorrections=yes"
	eval $cmd >/dev/null 
	echo "Combining source + bkg: `success $?` "
#log
	echo "">>$logfile
	echo $cmd>>$logfile


echo "${reset}"


	
;;		
	esac
	
