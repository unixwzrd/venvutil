#!/bin/bash

[ -L "${BASH_SOURCE[$((${#BASH_SOURCE[@]} -1))]}" ] \
        && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[$((${#BASH_SOURCE[@]} -1))]}")\
        || THIS_SCRIPT="${BASH_SOURCE[$((${#BASH_SOURCE[@]} -1))]}"
MY_NAME="$(basename "${THIS_SCRIPT}")"

# Check for the correct number of arguments
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 directory_name"
  exit 1
fi

# Define Warehouse path
WAREHOUSE_LOCATION="/Volumes/ExtraSpace00/Warehouse"

object=$1
# Get the full path of the directory
object_location=$(realpath "${object}")
# Get the directory name
object_name=$(basename "${object}")
# Get the current directory
# current_directory=$(pwd)

# Define the new Warehouse directory path
warehouse_location="${WAREHOUSE_LOCATION}/${object_location#*"${HOME}"}"

case ${MY_NAME} in
    "warehouse")
        direction="to"
        destination_directory="${warehouse_location}"
        source_directory="${object_location}"
        ;;
    "recall")
        direction="from"
        destination_directory="${object_location}"
        source_directory="${warehouse_location}"
        ;;
    *)
        echo "Unknown script name: ${MY_NAME}"
        exit 1
        ;;
esac


echo "mkdir -p ${destination_directory}"

# Move the directory to Warehouse
echo "(cd ${source_directory}; tar cvf - $object_name ) | ( cd ${destination_directory}; tar xvf - )"

echo "rm -rf ${source_directory}/${object_name}"
echo "ln -s ${destination_directory}/${object_name} ${source_directory}/${object_name}"

echo "Directory \`${object_name}\` moved ${direction} Warehouse and symlink created."
