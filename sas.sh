#!/bin/bash 


# @author	   : Manuel Castro Avila <manuel.castro@inpe.br>
# @file		   : sas.sh	
# @created	   : 28-Feb-2017
#  National Institute for Space Research (INPE),  São José dos Campos, SP, Brazil

##################################################################################
##################################################################################
#  This script has been developed under financial support from FAPESP (Fundação  #
#  de Amparo à Pesquisa do Estado de São Paulo, Brazil) under grant #2015/25972-0#
##################################################################################
##################################################################################

	red=`tput setaf 1`
	green=`tput setaf 2`
	yellow=`tput setaf 3`
	blue=`tput setaf `
 	reset=`tput sgr0`
	blink="\033[5m"


argument=$1

##########################################################
#check if an argument has been provided 
if [ -z $argument ]; then
	echo "${red}You didn't  provide an argument${reset}"
	return 
fi	

##########################################################
##Load Heasoft and SAS

if [ -v HEADAS ]; then
	. $HEADAS/headas-init.sh
	if [ $? -ne 0 ]; then
		echo "${red}Executed command failed${reset}"
		else
		echo "${green} Heasoft loaded${reset}"
	fi	
	else
	echo "${red} HEADAS variable didn't find. Check ~/.bashrc file${reset}"
	return
fi 


if [ -v SAS_DIR ]; then
	source $SAS_DIR/sas-setup.sh
	if [ $? -ne 0 ]; then
		echo "${red}Executed command failed${reset}"
		else
		echo "${green} SAS_DIR defined ${reset}"
	fi	
	else
	echo "${red} SAS_DIR didn't find. Check ~/.bashrc file ${reset}"
	return	
fi

##############################################
##############################################
#Check if SAS tools have been loaded properly

if [ -v SAS_PATH ]; then 
	echo "${green}SAS tools already loaded${reset}"
	
	else 
	
	echo "${red}SAS tools don't loaded${reset}"
	 return  
fi	

##check if a command was successfully executed
function success {


if [ $1 -ne 0 ]; then
	echo "${red} Executed command failed${reset}"
fi
}

function check {
#	cif_file=`ls $SAS_ODF/*.cif`
#	sumfile=`ls $SAS_ODF/*SUM.SAS`


##with option "-z" checks if the variable is unset or set to empty string
#
#if [ -z $cif_file ] && [ -z $sumfile ] ; then
#
#		cd $SAS_ODF
#		echo "${green} cifbuild executing${reset}"
#		cifbuild
#		export SAS_CCF=$SAS_ODF/ccf.cif
#		echo "${green} odfingest executing${reset}"
#		odfingest
#		sumfile=`ls $SAS_ODF/*SUM.SAS`
#		export SAS_ODF=$sumfile
#		
#		else
#		echo "${green}*.cif and *SUM.SAS files already exist${reset}"
#
#		export SAS_CCF=${cif_file}	
#		export SAS_ODF=${sumfile}
#fi 
	
		cd $SAS_ODF
		echo "${green} cifbuild executing${reset}"
		cifbuild
		export SAS_CCF=$SAS_ODF/ccf.cif
		echo "${green} odfingest executing${reset}"
		odfingest
		sumfile=`ls $SAS_ODF/*SUM.SAS`
		export SAS_ODF=$sumfile
}

#############################################
#############################################
#############################################

##check if an argument has been provided 
#if [ -z $1 ]; then
#	echo "${red}You didn't provide an argument${reset}"
#	return 
#fi	

#As input user can provide either the .tar.gz or the odf directory (if data have already been extracted)

#If a file is provided, the script extracts it and creates odf, pn and mos directories




#Option -f checks if $1 is a file and  exists

##Set full path of either file or directory
	

	full_path=`readlink -f $argument`
	`success $?`
#Path where files will be placed
	root_path=$PWD
if  [ -f ${full_path} ] && [ -n ${full_path}  ] ; then
#Create a directory named after the ObsID to place all the files in there
	directory=`ls ${argument} | awk -F"." '{print($1)}' `	
	root_path=$PWD/${directory}
##check if either odf, pn or mos exist
	if [ -d "${root_path}/odf" ]; then
		
	echo "${red}odf directory  already exists, delete it."
	echo "Otherwise provide this directory instead the .tar.gz file ${reset}"
	return  
	fi

	mkdir ${root_path}
	echo -e "${green}You provided a .tar file $1"
	echo "${green}It will be extracted, odf, pn and mos directories will be created"
	echo "Files from ${full_path} will be placed into odf directory ${reset}"

	mkdir ${root_path}/odf ${root_path}/pn ${root_path}/mos
	cd ${root_path}/odf
	export SAS_ODF=$PWD
	tar xvfz ${full_path}
#Now extract .TAR file and delete it after extraction
	tar_file=`ls *.TAR`	
	tar xvf ${tar_file}
	rm ${tar_file}
	echo "${green}${tar_file} deleted ${reset}"	
	check
	echo "${green}Which camera(s) do you want to extract the eventfiles for: (pn, mos, both)?${reset}"
	echo ""
	read arg
##PN extraction	
	if [ $arg == "pn" ]; then
		cd ${root_path}/pn
		epproc
		echo "${green} Extraction for PN done${reset}"
		cd ${root_path}
#MOS extraction	
	elif [ $arg == "mos" ]; then
		cd ${root_path}/mos
		emproc
		echo "${green} Extraction for MOS done${reset}"
		cd ${root_path}
#Both cameras
	elif [ $arg == "both" ]; then
	
		cd ${root_path}/pn
		epproc
		cd ${root_path}/mos
		emproc
		echo "${green} Eventfile extraction for both pn and mos cameras done${reset}"
		cd ${root_path}
	
	else 
		echo "${red}Option $arg not valid${reset}"
		cd ${root_path}
		return	
	fi
	
fi


#If odf directory is provided

if [ -n ${full_path} ] && [ -d ${full_path} ]; then
	
	echo -e "${green}You provided odf directory ${full_path}${reset}"
	echo "${green}Make sure you have ran both epproc and emproc ${reset}"
	export SAS_ODF=${full_path}
#	check
	cif_file=`ls $SAS_ODF/*.cif`
	sumfile=`ls $SAS_ODF/*SUM.SAS`
	if [ -z $cif_file ] && [ -z $sumfile ] ; then
		echo "${red} You provided a odf directory, but it doesn't have neither the *.cif file nor the *SUM.SAS file."
		echo "Check it or delete the odf directory and provide the original *.TAR file"
		return
	fi
	export SAS_CCF=${cif_file}	
	export SAS_ODF=${sumfile}
fi

#Neither file nor directory exists


if  [ -f ${full_path} ]  || [ -d ${full_path} ]; then
		echo ""
	else
		echo -e "${red}Provided file or directory ${blink}${full_path}${reset} ${red}doesn't exist${reset}"
	return
fi




echo "${yellow}"
echo "********************************************"
echo "********Environment variables***************"
echo "********************************************"


echo "SAS_DIR="$SAS_DIR
echo "SAS_CCFPATH="$SAS_CCFPATH
echo "SAS_ODF="$SAS_ODF
echo "SAS_CCF="$SAS_CCF
echo "**********************************************"
user=`whoami`
user_name=`getent passwd ${user} | cut -d : -f 5`
echo "${green} ${user_name} Good luck from now on with your analysis....${reset}"	
echo "${reset}"


