#!/usr/bin/env zsh

# ANSI colour codes
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Colour

# This gets the location of the folder where the script is run from. 
SCRIPT_DIR=${0:a:h}
cd "$SCRIPT_DIR"

# Get CPU architecture
ARCH=$(uname -m)

# Introduction
introduction() {
	echo "\n${PURPLE}This script is for extracting the game data for:"
	echo "${GREEN}War1gus${PURPLE}: Warcraft: Orcs and Humans${NC}"
	echo "${GREEN}Wargus${PURPLE}: Warcraft II${NC}"
	#echo "${GREEN}Stargus${PURPLE}: Starcraft${RED} Starcraft is currently not playable${NC}"
	
	echo "\n${PURPLE}It can extract the original game data from a GoG installer${NC}"
	echo "${PURPLE}It also works if the game data is already extracted${NC}\n"
	
	echo "${PURPLE}It should be run from the same folder as the game data along with the War1gus or Wargus app${NC}\n"
	
	echo "${PURPLE}The following game data files are supported:"
	echo "${GREEN}Warcraft${PURPLE}: ${NC}DATA${PURPLE} folder and ${NC}WAR1.BIN"
	echo "${GREEN}Warcraft${PURPLE}: ${NC}setup_warcraft_orcs__humans_1.2_(28330).exe${PURPLE} GoG Installer${NC}\n"
	echo "${GREEN}Warcraft II${PURPLE}: ${NC}Support${PURPLE} folder and ${NC}Install.mpq"
	echo "${GREEN}Warcraft II${PURPLE}: ${NC}setup_warcraft_ii_2.02_v5_(78104).exe${PURPLE} and ${NC}.bin${PURPLE} GoG Installer${NC}"
	#echo "${GREEN}Starcraft${PURPLE}: ${NC}INSTALL.EXE"
	
	echo "\n${GREEN}Homebrew${PURPLE} and the ${GREEN}Xcode command-line tools${PURPLE} are required${NC}"
	echo "${PURPLE}If they are not present you will be prompted to install them${NC}\n"
}

# Check for homebrew installation
homebrew_check() {
	echo "${PURPLE}Checking for Homebrew...${NC}"
	if ! command -v brew &> /dev/null; then
		if [[ "${ARCH}" == "arm64" ]]; then 
  			echo "${PURPLE}Homebrew not found. Installing Homebrew for Apple Silicon...${NC}"
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
			(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> $HOME/.zprofile
			eval "$(/opt/homebrew/bin/brew shellenv)"
		elif [[ "${ARCH}" == "x86_64" ]]; then 
   			echo "${PURPLE}Homebrew not found. Installing Homebrew for Intel Macs...${NC}"
			/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
			(echo; echo 'eval "$(/usr/local/bin/brew shellenv)"') >> $HOME/.zprofile
			eval "$(/usr/local/bin/brew shellenv)"
   		else 
     			echo "${RED}Could not evaluate platform architecture${NC}"
			exit 1
		fi
		
		# Check for errors
		if [ $? -ne 0 ]; then
			echo "${RED}There was an issue installing Homebrew${NC}"
			echo "${PURPLE}Quitting script...${NC}"	
			exit 1
		fi
	else
		echo -e "${PURPLE}Homebrew found. Updating Homebrew...${NC}"
		brew update
	fi
}

# Function for checking for an individual dependency
dependency_check() {
	if [ -d "$(brew --prefix)/opt/$1" ]; then
		echo -e "${GREEN}Found $1. Checking for updates...${NC}"
		brew upgrade $1
	else
		echo -e "${PURPLE}Did not find $1. Installing...${NC}"
		brew install $1
	fi
}

setup_target_dir() {
	APP_SUPP=~/Library/Application\ Support/Stratagus
	if [ ! -d $APP_SUPP ]; then
		mkdir $APP_SUPP
	fi
	
	destination_dir=$APP_SUPP/$1
	if [ -d $destination_dir ]; then
		echo "\n${PURPLE}Destination directory ${GREEN}$1${PURPLE} already exists...${NC}"
		echo "${PURPLE}Would you like to overwrite the existing game data folder?${NC}"
		echo "${RED}Warning: This cannot be undone${NC}"
		overwrite_menu $1
	else 
		mkdir $destination_dir
	fi
}

verify_data() {
	
	if [[ $1 = war1gus ]]; then
		if [[ -a War1gus.app ]]; then
			echo "${PURPLE}Found War1gus.app...${NC}"
			xattr -cr War1gus.app
			if [[ -a "setup_warcraft_orcs__humans_1.2_(28330).exe" ]]; then
				echo "${PURPLE}Found GoG Installer for Warcraft 1...${NC}"
				dependency_check innoextract
				dependency_check timidity
				extract_war1gus
			elif [[ -a WAR1.BIN && -d DATA ]]; then
				echo "${PURPLE}Found DATA folder & WAR1.BIN from Warcraft 1...${NC}"
				dependency_check timidity
				extract_war1gus
			fi
		else
			echo "${PURPLE}Could not find War1gus app...${NC}"
			echo "${PURPLE}Please download it an place it in the same folder as this script and the game data${NC}"
			exit 1
		fi
	elif [[ $1 = wargus ]]; then
		if [[ -a Wargus.app ]]; then
			echo "${PURPLE}Found Wargus.app...${NC}"
			xattr -cr Wargus.app
			if [ -a "setup_warcraft_ii_2.02_v5_(78104).exe" ]; then
				echo "${PURPLE}Found GoG Installer for Warcraft 2...${NC}"
				dependency_check innoextract
				extract_wargus
			elif [[ -a Install.mpq && -d Support ]]; then
				echo "${PURPLE}Found Support folder & Install.mpq from Warcraft 2...${NC}"
				extract_wargus
			fi
		else
			echo "${PURPLE}Could not find War1gus app...${NC}"
			echo "${PURPLE}Please download it an place it in the same folder as this script and the game data${NC}"
			exit 1
		fi
	fi
}


extract_war1gus() {	
	echo "${PURPLE}Copying resources from app bundle...${NC}"	
	cp -R War1gus.app/Contents/Resources/campaigns War1gus.app/Contents/Resources/contrib War1gus.app/Contents/Resources/maps War1gus.app/Contents/Resources/shaders War1gus.app/Contents/Resources/scripts $destination_dir
	
	echo "${PURPLE}Copying game data...${NC}"
	if [[ -a "setup_warcraft_orcs__humans_1.2_(28330).exe" ]]; then
		gog_installer=true
		innoextract setup_warcraft_orcs__humans_1.2_\(28330\).exe -d extracted
		mv extracted/DATA .
		mv extracted/WAR1.BIN .
		rm -rf extracted	
	fi
	
	echo "${PURPLE}Launching extraction tool...${NC}"	
	War1gus.app/Contents/MacOS/war1tool -m -v . $destination_dir
	
	if [[ $gog_installer = true ]]; then
		rm -rf DATA
		rm WAR1.BIN
	fi
}


extract_wargus() {	
	echo "${PURPLE}Copying resources from source...${NC}"	
	cp -R Wargus.app/Contents/MacOS/campaigns Wargus.app/Contents/MacOS/contrib Wargus.app/Contents/MacOS/maps Wargus.app/Contents/MacOS/shaders Wargus.app/Contents/MacOS/scripts $destination_dir
	
	echo "${PURPLE}Copying game data...${NC}"
	if [[ -a "setup_warcraft_ii_2.02_v5_(78104).exe" ]]; then
		gog_installer=true
		innoextract setup_warcraft_ii_2.02_v5_\(78104\).exe -d extracted
		mv extracted/Support .
		mv extracted/Install.mpq .
		rm -rf extracted
	fi
	
	echo "${PURPLE}Launching extraction tool...${NC}"	
	Wargus.app/Contents/MacOS/wartool -v -r . $destination_dir
	
	if [[ $gog_installer = true ]]; then
		rm -rf Support
		rm Install.mpq
	fi
}

extract_stargus() {	
	echo "${PURPLE}Copying resources from Stargus app...${NC}"	
	cp -R Stargus.app/Contents/MacOS/contrib Stargus.app/Contents/MacOS/scripts $destination_dir
	cp Stargus.app/Contents/MacOS/mpqlist.txt $destination_dir/mpqlist.txt
	
	#cp INSTALL.EXE Stargus.app/Contents/MacOS
	
	echo "${PURPLE}Launching extraction tool...${NC}"	
	Stargus.app/Contents/MacOS/startool -v -s . $destination_dir	
	
	#rm Stargus.app/Contents/MacOS/INSTALL.EXE
}

selection_menu() {
	PS3='Which game would you like to extract the data for? '
	OPTIONS=(
		"War1gus"
		"Wargus"
		"Quit")
	select opt in $OPTIONS[@]
	do
		case $opt in
			"War1gus")
				setup_target_dir data.War1gus
				homebrew_check
				dependency_check ffmpeg
				verify_data war1gus
				finish_menu
				break
				;;
			"Wargus")
				setup_target_dir data.Wargus
				homebrew_check
				dependency_check ffmpeg
				verify_data wargus
				finish_menu
				break
				;;
			"Quit")
				echo "${RED}Quitting${NC}"
				exit 0
				;;
			*) echo "\"$REPLY\" is not one of the options...";;
		esac
	done
}

finish_menu() {
	# Ask the user to select which game to build
	PS3='Do you want to extract data for another game?: '
	OPTIONS=(
		"Yes"
		"No")
	select opt in $OPTIONS[@]
	do
		case $opt in
			"Yes")
				selection_menu
				break
				;;
			"No")
				exit 0
				;;
			*) 
				echo "\"$REPLY\" is not one of the options..."
				echo "Enter the number of the option and press enter to select"
				;;
		esac
	done
}

overwrite_menu() {
	# If a game data folder already exists, give an option to delete or quit
	PS3='Do you want to overwrite the existing game data?: '
	OPTIONS=(
		"Yes"
		"No")
	select opt in $OPTIONS[@]
	do
		case $opt in
			"Yes")
				echo "${PURPLE}Deleting ${GREEN}$1${PURPLE}...${NC}"
				rm -rf $APP_SUPP/$1
				mkdir $APP_SUPP/$1
				break
				;;
			"No")
				finish_menu
				exit 0
				;;
			*) 
				echo "\"$REPLY\" is not one of the options..."
				echo "Enter the number of the option and press enter to select"
				;;
		esac
	done
}

# Main
introduction
selection_menu
