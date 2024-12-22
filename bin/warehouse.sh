#!/usr/bin/env bash

[ -L "${BASH_SOURCE[$((${#BASH_SOURCE[@]} -1))]}" ] \
        && THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[$((${#BASH_SOURCE[@]} -1))]}")\
        || THIS_SCRIPT="${BASH_SOURCE[$((${#BASH_SOURCE[@]} -1))]}"
MY_NAME="$(basename "$0")"

# Check for the correct number of arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 directory_name"
    exit 1
fi

# Define Warehouse path
WAREHOUSE_LOCATION="${ARCHIVE:-/Volumes/ExtraSpace00/Warehouse}"

object=$1
# Get the full path of the directory
current_directory=$(pwd)
object_location="$(dirname ${object})"
# Handle special cases for current directory
if [ "${object_location}" = "/." ] || [ "${object_location}" = "./" ] || [ "${object_location}" = "." ]; then
    object_location="${current_directory}"
else
    # Set the object location relative to the current directory
    object_location="${object_location:-"${current_directory}"}"
fi
# Get the directory name
object_name=$(basename "${object}")

object_type="Directory"

# Define the new Warehouse directory path
warehouse_location="${WAREHOUSE_LOCATION}"

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

# `recall` is just the reverse operation as `warehouse`.We need to check to see the source object 
# is not a link, and the destination object. is not a link. If they are we are in a pathological situation.
if [ -L "${destination_directory}/${object_name}" -a -L "${source_directory}/${object_name}" ]; then
    echo "Error \`${object_name}\` is a link in the source and destination. You probably ned to restore from a backup."
    exit 1
fi

if [ -L "${destination_directory}/${object_name}" ]; then
    rm -f "${destination_directory}/${object_name}"
    object_type="Link"
    unlinked=true
fi

# Move the directory to Warehouse with error checking
(cd "${source_directory}" && tar cf - "${object_name}") | \
    (cd "${destination_directory}" && tar xf -) 
# shellcheck disable=SC2206
tar_exit=(${PIPESTATUS[*]})
echo "Status ${tar_exit[*]}"

if [ ${tar_exit[0]} -ne 0  ] || [ ${tar_exit[1]} -ne 0 ]; then
    echo "Error: tar operation failed (exit codes: ${tar_exit[0]}, ${tar_exit[1]})"
    echo "Source tar exit code: ${tar_exit[0]}"
    echo "Destination tar exit code: ${tar_exit[1]}"
    if [ "${unlinked}" = true ]; then
        ln -sf "${destination_directory}/${object_name}" "${object_name}"
        echo "symlink restored, files not moved."
    else
        echo "No symlink, files not moved."
    fi
    exit 2
fi

# Only proceed with removal and symlink if tar was successful
rm -rf "${source_directory}/${object_name}"
ln -s "${destination_directory}/${object_name}" "${source_directory}/${object_name}"

echo "${object_type} '${object_name}' moved ${direction} to ${destination_directory} and symlink created."
