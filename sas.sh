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
		
	echo "${red}odf direcory  already exits, delete it."
	echo "Otherwise provide this direcory instead the .tar.gz file ${reset}"
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
	cd ${root_path}/pn
	epproc
	cd ${root_path}/mos
	emproc
	echo "{green} Data for both pn and mos cameras were genereted${reset}"
	user_name=`getent passwd ${user} | cut -d : -f 5`
	echo "${user_name} Good luck from now on with your analysis"	

	
fi


#If odf directory is provided

if [ -n ${full_path} ] && [ -d ${full_path} ]; then
	
	echo -e "${green}You provided odf directory $1${reset}"
	export SAS_ODF=${full_path}
fi

#Neither file nor directory exists


if  [ -f ${full_path} ]  || [ -d ${full_path} ]; then
		echo ""
	else
		echo -e "${red}Provided file or directory ${blink}${full_path}${reset} ${red}doesn't exist${reset}"
	return
fi

function check {
#echo "${green}"
	cif_file=`ls $SAS_ODF/*.cif`
#	echo "cif_file= "$cif_file
	sumfile=`ls $SAS_ODF/*SUM.SAS`
#	echo "SUM.SAS= "$sumfile
#echo "${reset}"



##Load Heasoft and SAS
heainit
 SAS


##############################################
##############################################
#Check if SAS tools have been loaded properly

echo "${green}"
if [ -v SAS_PATH ]; then 
	echo "SAS tools already loaded"
	
	else 
	
	echo "SAS tools don't loaded${reset}"
	 return  
fi	

#with option "-z" checks if the variable is unset or set to empty string

if [ -z $cif_file ] && [ -z $sumfile ] ; then

		cd $SAS_ODF
		cifbuild
		export SAS_CCF=$SAS_ODF/ccf.cif
		odfingest
		sumfile=`ls $SAS_ODF/*SUM.SAS`
		export SAS_ODF=$sumfile
		
		else


		export SAS_CCF=$SAS_ODF/ccf.cif	
		export SAS_ODF=$sumfile
fi 
	
}



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


