
function absPath {
	if [ -d "$1" ]; then
		( cd "$1"; echo $(dirs -l +0))
	else
		( cd "$(dirname "$1")"; d=$(dirs -l +0); echo "${d%/}/${1##*/}" )
	fi
}


#displays usage information and exits program
function usage {
	echo -e "\nusage: cimsetup [-d <dirrectory>] [-c] [-l]\n"
	echo -e "\t[--lightFname <dir_name>]\t[--heavyFname <dir_name>]"
	exit
}

#checks that $1 is not empty or a flag
function isArg {
	if [[ $1 == -* ]] || [[ -z "$1" ]] ; then
		usage
	fi
}

wd=$(pwd)
copymzXML=false
linkMzXMLs=true
heavyFname="heavy"
lightFname="light"
dtaFname="dta"
destDir=$wd

#get args
while ! [[ -z "$1" ]] ; do
	case $1 in
		"-d")
			shift
			isArg "$1"
			destDir=$(absPath "$1") ;;
		"-c")
			copymzXML=true ;;
		"-l")
			shift
			isArg "$1"
			if [ "$1" == "1" ] ; then
				linkMzXMLs=true
			elif [ "$1" == "0" ] ; then
				linkMzXMLs=false
			else
				echo "$1 is an invalid option for -l"
				exit
			fi
			;;
		"--heavyFname")
			shift
			isArg "$1"
			heavyFname="$1" ;;
		"--lightFname")
			shift
			isArg "$1"
			lightFname="$1" ;;
		"-h")
			usage ;;
		*)
			echo "$1 is an invalid arg."
			exit
	esac
	shift
done

if ! [[ -f $wd/$heavyFname/DTASelect-filter.txt ]] ; then
	echo "DTAselect-filter files could not be found. Exiting..."
	exit
fi

#check if dest dir exists and make it if it does not
if ! [[ -d $destDir ]] ; then
	echo "Generating $destDir"
	mkdir $destDir
fi
if ! [[ -d $destDir/$dtaFname ]] ; then
	mkdir $destDir/$dtaFname
fi

cd $wd
f=$(ls *_01.mzXML)
len=${#f}
fname=${f::len-9}
echo "Adding: $fname"
# for s in $heavyFname $lightFname ; do
# 	cd $s
# 	cp DTASelect-filter.txt $destDir/$dtaFname/"DTASelect-filter_"$fname"_"$s".txt"
# 	cd ..
# done
cd $heavyFname
cp DTASelect-filter.txt $destDir/$dtaFname/"DTASelect-filter_"$fname"_heavy.txt"
cd $wd
cd $lightFname
cp DTASelect-filter.txt $destDir/$dtaFname/"DTASelect-filter_"$fname"_light.txt"
cd $wd

if $copymzXML ; then
	if $linkMzXMLs ; then
		ln -f $wd/*.mzXML $destDir
	else
		cp $wd/*.mzXML $destDir
	fi
fi

