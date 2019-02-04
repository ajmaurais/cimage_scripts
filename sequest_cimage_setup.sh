
wd=$(pwd)
paramsFiles=""
heavyName="heavy"
lightName="light"
heavyParams=""
lightParams=""
ppdir="$HOME/scripts/cimage_scripts/sequest_params_files"
qsubAll=false
qsubAllForce=false
linkMs2s=true

#displays usage information and exits program
function usage {
	echo -e '\nusage: cssetup [options] <params_files>\n'
	echo 'Available sequest.params files:'
	echo 's1: Human SILAC R10 K6'
	echo 's2: Human SILAC R10 K8'
	echo 's3: Human ReDiMe H L'
	echo 's4: Human ReDiMe H L IA H L red_diffMod'
	echo 's5: Human ReDiMe H L IA H L ox_diffMod'
	echo -e '\nAvailable options:'
	echo '-l 1 : Create hard links to ms2 files in heavy folder (default).'
	echo '-l 0 : Do not link .ms2 files, create hard copies instead.'
	echo -e '\n-qs : Use qsub_all to submit sequest jobs to the queue.'
	echo '-qsf : Use qsub_all to submit sequest jobs to the queue and pass -f flag.'
	echo
	exit
}

#checks that $1 is not empty or a flag
function isArg {
	if [[ $1 == -* ]] || [[ -z "$1" ]] ; then
		usage
	fi
}

function absPath {
	if [ -d "$1" ]; then
		( cd "$1"; echo $(dirs -l +0))
	else
		( cd "$(dirname "$1")"; d=$(dirs -l +0); echo "${d%/}/${1##*/}" )
	fi
}

#begin main

#get args
while ! [[ -z "$1" ]] ; do
	if [ -z $2 ] ; then
		isArg "$1"
		paramsFiles="$1"
		break
	fi
	case $1 in
		"-d")
			shift
			isArg "$1"
			wd=$(absPath "$1") ;;
		"-l")
			shift
			isArg "$1"
			if [ "$1" == "1" ] ; then
				linkMs2s=true
			elif [ "$1" == "0" ] ; then
				linkMs2s=false
			else
				echo "$1 is an invalid option for -l"
				exit
			fi
			;;
		"-qs")
			qsubAll=true ;;
		"-qsf")
			qsubAll=true
			qsubAllForce=true ;;
		"-h")
			usage;;
		*)
			echo "$1 is an invalid arguement."
			usage;;
	esac
	shift
done

#check that arg was specified
if [ -z "$paramsFiles" ] ; then
	usage
fi

#check if first arguement points to a dir that exists
if [ ! -d "$wd" ] ; then
	echo "Directory does not exist"
	exit
fi

#make folders if they don't exist
cd $wd
if ! [ -d "$wd/$heavyName" ] ; then
	mkdir $heavyName
	echo "Making $heavyName"
fi
if ! [ -d "$wd/$lightName" ] ; then
	mkdir $lightName
	echo "Making $lightName"
fi

#check if dir contains .ms2 files
if [ $(ls -l "$wd/"*.ms2 2>/dev/null | wc -l) -lt 1 ] ; then
	echo "Valid .ms2 files could not be found in the specified directory! Exiting..."
	exit
fi

#get locations of sequest.params files
case $paramsFiles in
	"s1")
		heavyParams="$ppdir/SILAC_Human_Arg_10_Lys_6_params/heavy/sequest.params"
		lightParams="$ppdir/SILAC_Human_Arg_10_Lys_6_params/light/sequest.params" ;;
	"s2")
		heavyParams="$ppdir/SILAC_Human_Arg_10_Lys_8_params/heavy/sequest.params"
		lightParams="$ppdir/SILAC_Human_Arg_10_Lys_8_params/light/sequest.params" ;;
	"s3")
		heavyParams="$ppdir/ReDiMe_H_L/heavy/sequest.params"
		lightParams="$ppdir/ReDiMe_H_L/light/sequest.params" ;;
	"s4")
		heavyParams="$ppdir/ReDiMe_H_L_IA_H_L_red_diffMod/heavy/sequest.params"
		lightParams="$ppdir/ReDiMe_H_L_IA_H_L_red_diffMod/light/sequest.params" ;;
	"s5")
		heavyParams="$ppdir/ReDiMe_H_L_IA_H_L_ox_diffMod/heavy/sequest.params"
		lightParams="$ppdir/ReDiMe_H_L_IA_H_L_ox_diffMod/light/sequest.params" ;;
	*)
		echo "$paramsFiles is not a valid option."
		exit
esac

#setup up heavy and light folders
if $linkMs2s ; then
	echo "Making links to ms2 files in "$heavyName
	ln -f *.ms2 $heavyName
else
	echo "Copying ms2 files to "$heavyName
	cp *.ms2 $heavyName
fi
echo "Moving ms2 files to "$lightName
mv *.ms2 $lightName

#copy params files
cp $heavyParams $heavyName
cp $lightParams $lightName

if $qsubAll ; then
	cd "$wd"
	for d in $heavyName $lightName ; do
		cd $d
		if $qsubAllForce ; then
			bash ~/scripts/qsubmit.sh -f
		else
			bash ~/scripts/qsubmit.sh
		fi
		cd ..
	done
fi

echo "Sucess!"
