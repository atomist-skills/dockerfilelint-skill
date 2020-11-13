#! /bin/bash
# Set up and run dockerfilelint
#
# Copyright © 2020 Atomist, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

declare Pkg=dockerfilelint
declare Version=0.3.0

set -o pipefail

# print message to stdout prefixed by package name.
# usage: msg MESSAGE
function msg () {
	echo "$Pkg: $*"
}

# print message to stderr prefixed by package name.
# usage: err MESSAGE
function err () {
	msg "$*" 1>&2
}

# write status to output location.
# usage: status [CODE [REASON [VISIBILITY]]]
function status () {
	local code=$1
	if [[ $code ]]; then
		shift
	else
		code=0
	fi
	local reason=$1
	if [[ $reason ]]; then
		shift
		if [[ $code -eq 0 ]]; then
			msg "$reason"
		else
			err "$reason"
		fi
	else
		reason="dockerfilelint successful"
	fi
	local visibility=$1
	if [[ $visibility ]]; then
		shift
	else
		visibility=normal
	fi
	local status_file=${ATOMIST_STATUS:-/atm/output/status.json}
	local status_contents
	printf -v status_contents '{"code":%d,"reason":"%s","visibility":"%s"}' \
		   "$code" "$reason" "$visibility"
	if ! echo "$status_contents" > "$status_file"; then
		err "Failed to write status to $status_file"
		return 1
	fi
}

# usage: main "$@"
function main () {
	# extract skill configuration from the incoming event payload
	local payload=${ATOMIST_PAYLOAD:-/atm/payload.json}
	local config path slug url
	config=$( < "$payload" \
		  jq -r '.skill.configuration.parameters[] | select( .name == "config" ) | .value' )
	if [[ $? -ne 0 ]]; then
		status 1 "Failed to extract config parameter from payload"
		return 1
	fi
	path=$( < "$payload" \
		  jq -r '.skill.configuration.parameters[] | select( .name == "path" ) | .value' )
	if [[ $? -ne 0 || ! $path ]]; then
		status 1 "Failed to extract path parameter from payload"
		return 1
	fi
	slug=$( < "$payload" jq -r '"\(.data.Push[0].repo.owner)/\(.data.Push[0].repo.name)"' )
	if [[ $? -ne 0 || ! $slug ]]; then
		err "Failed to extract repository owner and name from payload"
	fi

	# bail out early if Dockerfile path does not exist
	if [[ ! -f $path ]]; then
		status 0 "Dockerfile does not exist in $slug: $path" hidden
		return 0
	fi

	msg "Running dockerfilelint on $slug/$path"

	# prepare command arguments
	local homedir=${ATOMIST_HOME:-/atm/home}
	local config_file=$homedir/.dockerfilelintrc
	if [[ $config && ! -f "$config_file" ]]; then
		if ! echo "$config" > "$config_file"; then
			status 1 "Failed to create dockerfilelint configuration file: $config_file"
			return 1
		fi
	fi

	local outdir=${ATOMIST_OUTPUT_DIR:-/atm/output}

	# make the problem matcher available to the runtime
	local matchers_dir=${ATOMIST_MATCHERS_DIR:-$outdir/matchers}
	if mkdir -p "$matchers_dir"; then
		local matcher=/app/dockerfilelint.matcher.js
		if ! cp "$matcher" "$matchers_dir"; then
			err "Failed to copy $matcher to $matchers_dir"
		fi
	else
		err "Failed to create matcher output directory: $matchers_dir"
	fi

	local output_file=$outdir/dockerfilelint.json
	dockerfilelint --json "$path" > "$output_file"
	local rv=$?
	if [ $rv -eq 0 ]; then
		status 0 "No lint issues found in $slug/$path"
		return 0
	elif [ $rv -eq 1 ]; then
		status 1 "Lint issues found in $slug/$path"
		return 1
	else
		status "$rv" "Unknown dockerfilelint exit code for $slug/$path"
		return $rv
	fi
}

main "$@"
