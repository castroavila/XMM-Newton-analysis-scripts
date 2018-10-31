#!/bin/bash 


#  sas.sh
#  
#  Manuel Castro Avila <manuel.castro@inpe.br>
#  
#  28-02-2017
#  
#  National Institute for Space Research (INPE),  São José dos Campos, SP, Brazil

	red=`tput setaf 1`
	green=`tput setaf 2`
	yellow=`tput setaf 3`
	blue=`tput setaf `
 	reset=`tput sgr0`
	blink="\033[5m"


##check if a command was successfully executed
function success {


if [ $1 -ne 0 ]; then
	echo "${red} Executed command failed${reset}"
	return	
	else
	echo "${green}success${reset}"
fi
echo "${reset}"
}

function check {
	cif_file=`ls $SAS_ODF/*.cif`
#	echo "cif_file= "$cif_file
	sumfile=`ls $SAS_ODF/*SUM.SAS`
#	echo "SUM.SAS= "$sumfile


##Load Heasoft and SAS

if [ -v HEADAS ]; then
	. $HEADAS/headas-init.sh
	success $?
	echo "${green} Heasoft loaded${reset}"
	else
	echo "${red} HEADAS variable didn't find. Check ~/.bashrc file${reset}"
	return
fi 


if [ -v SAS_DIR ]; then
	source $SAS_DIR/sas-setup.sh
	echo "${green} SAS_DIR defined ${reset}"
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
echo ${reset}
#with option "-z" checks if the variable is unset or set to empty string

if [ -z $cif_file ] && [ -z $sumfile ] ; then

		cd $SAS_ODF
		cifbuild
		export SAS_CCF=$SAS_ODF/ccf.cif
		odfingest
		sumfile=`ls $SAS_ODF/*SUM.SAS`
		export SAS_ODF=$sumfile
		
		else
		echo "${green}*.cif and *SUM.SAS files already exist${reset}"

		export SAS_CCF=${cif_file}	
		export SAS_ODF=${sumfile}
fi 
	
}

#############################################
#############################################
#############################################



#As input user can provide either the .tar.gz or the odf directory (if data have alraedy been extracted)

#If a file is provided, the script extracts it and creates odf, pn and mos directories


#Option -f checks if $1 is a file and  exists

##Set full path of either file or directory

	full_path=`readlink -f $1`
#Path where files will be placed
	root_path=$PWD
if  [ -f ${full_path} ] && [ -n ${full_path}  ] ; then
	echo -e "${green}You provided a .tar file $1"
	echo "${green}It will be extracted, odf, pn and mos directories will be created"
	echo "Files from ${full_path} will be placed into odf directory ${reset}"

##check if either odf, pn or mos exist
	if [ -d "odf" ]; then
		
	echo "${red}odf directory  already exists, delete it."
	echo "Otherwise provide this directory instead the .tar.gz file ${reset}"
	return 
	fi
	mkdir odf pn mos
	cd ${root_path}/odf
	export SAS_ODF=$PWD
	tar xvfz ${full_path}
#Now extract .TAR file and delete it after extraction
	tar_file=`ls *.TAR`	
	tar xvf ${tar_file}
	rm ${tar_file}
	echo "${green}${tar_file} deleted ${reset}"	
	check
	echo "${green}Which camera do you want to extract the data from: (pn, mos, both)?${reset}"
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
		echo "${green} Extraction  for both pn and mos cameras done${reset}"
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
	export SAS_ODF=${full_path}
	check
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


