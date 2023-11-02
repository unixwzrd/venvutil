# Function Documentation

- [Function Documentation](#function-documentation)
  - [Function: \_\_next\_step](#function-__next_step)
  - [Function: \_\_strip\_space](#function-__strip_space)
  - [Function: \_\_zero\_pad](#function-__zero_pad)
  - [Function: \_set\_venv\_vars](#function-_set_venv_vars)
  - [Function: benv](#function-benv)
  - [Function: cact](#function-cact)
  - [Function: ccln](#function-ccln)
  - [Function: dact](#function-dact)
  - [Function: denv](#function-denv)
  - [Function: do\_help](#function-do_help)
  - [Function: general\_help](#function-general_help)
  - [Function: help\_scripts](#function-help_scripts)
  - [Function: lastenv](#function-lastenv)
  - [Function: lenv](#function-lenv)
  - [Function: nenv](#function-nenv)
  - [Function: pact](#function-pact)
  - [Function: pop\_stack](#function-pop_stack)
  - [Function: pop\_venv](#function-pop_venv)
  - [Function: push\_stack](#function-push_stack)
  - [Function: push\_venv](#function-push_venv)
  - [Function: renv](#function-renv)
  - [Function: snum](#function-snum)
  - [Function: source\_util\_script](#function-source_util_script)
  - [Function: specific\_function\_help](#function-specific_function_help)
  - [Function: vdsc](#function-vdsc)
  - [Function: vnum](#function-vnum)
  - [Function: vpfx](#function-vpfx)


## Function: __next_step


__next_step - Increment a given sequence number by 1 and pad it with a zero if needed.

- **Purpose**:
  - Increment a given sequence number by 1 and pad it with a zero if needed.
- **Usage**: 
  - __next_step "[0-99]"
- **Scope**: Local. Modifies no global variables.
- **Input Parameters**: 
  1. `sequenceNum` (integer) - The sequence number to increment. Must be between 00 and 99.
- **Output**: 
  - The next sequence number as a string, zero-padded if necessary.
- **Exceptions**: 
  - Returns an error code 22 if the sequence number is not between 00 and 99. Error 22 means "Invalid Argument".


## Function: __strip_space


__strip_space - Remove leading and trailing whitespaces from the input string.

- **Purpose**:
  - Remove leading and trailing whitespaces from the input string.
- **Usage**: 
  - __strip_space "string"
- **Input Parameters**: 
  1. `str` (string) - The string from which to remove leading and trailing whitespaces.
- **Output**: 
  - A new string with whitespaces removed from both ends.
- **Exceptions**: None


## Function: __zero_pad


__zero_pad - Pad a given number with a leading zero if it's a single-digit number.

- **Purpose**:
  - Pad a given number with a leading zero if it's a single-digit number.
- **Usage**: 
  - __zero_pad "nn"
- **Input Parameters**: 
  1. `num` (integer) - The number to pad. Can be single or double-digit.
- **Output**: 
  - The padded number as a string.
  - If no number is specified, it will default to 00.
- **Exceptions**: None


## Function: _set_venv_vars


## Function: benv


benv - Create a New Base Virtual Environment

- **Purose**:
  - Create a new base conda virtual environment and activate it.
- **Usage**: 
  - benv ENV_NAME [EXTRA_OPTIONS]
- **Input Parameters**: 
  1. `ENV_NAME` (string) - The name of the new environment to create.
  2. `EXTRA_OPTIONS` (string, optional) - Additional options to pass to `conda create`.
- **Output**: 
  - Creates and activates the new environment.
- **Exceptions**: 
  - Errors during environment creation are handled by conda.


## Function: cact


cact - Change active VENV

- **Purose**:
   - Change the active virtual environment.
- **Usage**: 
   -  cact VENV_NAME
- **Input Parameters**: 
   1. `VENV_NAME` (string) - The name of the virtual environment to activate.
- **Output**: 
   - Messages indicating the deactivation and activation process.
   - If unsuccessful, prints an error message to STDERR and returns with status code 1.
- **Exceptions**: None


## Function: ccln


ccln - Clone the current VENV and increment the sequence number.

- **Purpose**:
  - Clone the current virtual environment and increment its sequence number.
- **Usage**: 
  - ccln [DESCRIPTION]
- **Input Parameters**: 
  1. `DESCRIPTION` (optional string) - A description for the new virtual environment.
- **Output**: 
  - Creates and activates a clone of the current environment with an incremented sequence number.
- **Exceptions**: 
  - None. If no description is provided, the description of the current VENV is used.


## Function: dact


dact - Deactivate the current VENV

- **Purose**:
  - Deactivate the currently active conda virtual environment.
- **Usage**: 
  - dact
- **Input Parameters**: 
  - None
- **Output**: 
  - Deactivates the current virtual environment.
  - Prints a message indicating the deactivated environment.
- **Exceptions**: 
  - If no environment is currently activated, conda will display an appropriate message.


## Function: denv


 denv - Delete a Specified Virtual Environment

- **Purose**:
  - Delete a specified conda virtual environment.
- **Usage**: 
  - denv ENV_NAME
- **Input Parameters**: 
  1. `ENV_NAME` (string) - The name of the environment to be deleted.
- **Output**: 
  - Removes the specified environment.
- **Exceptions**: 
  - If no environment name is provided, an error message is displayed.
  - Errors during deletion are handled by conda.


## Function: do_help


do_help - Dispatch help information based on the given subcommand.

- **Purpose**:
  - Serve as the main dispatcher for generating help information.
- **Usage**: 
  - do_help "subcommand"
- **Scope**:
  - Global
- **Input Parameters**: 
  1. `subcommand` (string) - The specific help topic or function name.
- **Output**: 
  - Appropriate help information based on the subcommand.
- **Exceptions**: 
  - None


## Function: general_help


general_help - Display general help options for the 'help' command.

- **Purpose**:
  - Provide an overview of the available help commands.
- **Usage**: 
  - general_help
- **Scope**:
  - Global
- **Input Parameters**: 
  - None
- **Output**: 
  - Lists the general help commands available.
- **Exceptions**: 
  - None


## Function: help_scripts


help_scripts - List sourced scripts and their purpose.

- **Purpose**:
  - Display a list of sourced scripts.
- **Usage**: 
  - help_scripts
- **Scope**:
  - Global
- **Input Parameters**: 
  - None
- **Output**: 
  - Lists the names of the sourced scripts.
- **Exceptions**: 
  - None


## Function: lastenv


lastenv - Retrieve the Last Environment with a Given Prefix

- **Purose**:
  - Return the last conda virtual environment that starts with a given prefix.
- **Usage**: 
  - lastenv PREFIX
- **Input Parameters**: 
   1. `PREFIX` (string) - The prefix for the environment names you want to match.
- **Output**: 
  - The last conda environment that starts with the given prefix.
- **Exceptions**: 
  - If no environments match the prefix, the output will be empty.


## Function: lenv


lenv - List All Current VENVs

- **Purose**:
 - List all the currently available conda virtual environments.
- **Usage**: 
    lenv
- **Input Parameters**: 
    None
- **Output**: 
    - A list of all existing conda virtual environments.
- **Exceptions**: 
    - If no environments are available, the output from `conda info -e` will indicate this.


## Function: nenv


nenv - Create a New Virtual Environment in a Series

- **Purose**:
  - Create a new conda virtual environment in a series identified by a prefix. Resets and starts the sequence number from "00".
- **Usage**: 
  - nenv PREFIX [EXTRA_OPTIONS]
- **Input Parameters**: 
  1. `PREFIX` (string) - The prefix to identify the series of environments.
  2. `EXTRA_OPTIONS` (string, optional) - Additional options to pass to the environment creation.
- **Output**: 
  - Creates and activates the new environment with sequence number "00".
- **Exceptions**: 
  - Errors during environment creation are handled by conda.


## Function: pact


pact - Switch to the Previous Active VENV

- **Purose**:
  - Deactivate the current virtual environment and activate the previously active one.
- **Usage**: 
  - pact
- **Input Parameters**: 
  - None
- **Output**: 
  - Deactivates the current environment and activates the previous one.
  - Prints messages to indicate the switch.
- **Exceptions**: 
  - If no previous environment is stored, an error message will be displayed.


## Function: pop_stack


pop_stack - Pop a value from a named stack.

- **Purpose**:
  - Pop a value from a named stack.
- **Usage**: 
  - pop_stack "stack_name"
- **Scope**:
  - Local. However, the stack name can be a global variable, making the stack globally accessible.
- **Input Parameters**: 
  1. `stack_name` (string) - The name of the stack array.
- **Output**: 
  - Removes and returns the top element from the named stack.
- **Exceptions**: 
  - Returns an error message and error code 1 if the stack is empty.


## Function: pop_venv


## Function: push_stack


push_stack - Push a value onto a named stack.

- **Purpose**:
  - Push a value onto a named stack.
- **Usage**: 
  - push_stack "stack_name" "value"
- **Scope**:
  - Local. However, the stack name can be a global variable, making the stack globally accessible.
- **Input Parameters**: 
  1. `stack_name` (string) - The name of the stack array.
  2. `value` - The value to push onto the stack.
- **Output**: 
  - Modifies the named stack by adding a new element.
- **Exceptions**: None.


## Function: push_venv


## Function: renv


renv - Revert to Previous Virtual Environment

- **Purose**:
  - Deactivate the current active environment, delete it, and then re-activate the previously active environment.
- **Usage**: 
  - renv
- **Input Parameters**: 
  - None
- **Output**: 
  - Removes the current environment and reverts to the previous one.
- **Exceptions**: 
  - Errors during deactivation or deletion are handled by conda.


## Function: snum


snum - Force set the VENV Sequence number.

- **Purpose**:
  - Force set the VENV Sequence number.
- **Usage**: 
  - snum NN
- **Input Parameters**: 
  1. `NN` (integer) - The VENV Sequence number to set. Must be a numeric value between 00 and 99.
- **Output**: 
  - Sets the global variable `__VENV_NUM` to the zero-padded sequence number.
  - Prints an error message to STDERR and returns with status code 1 if unsuccessful.
- **Exceptions**: None


## Function: source_util_script


source_util_script - Source a utility script by its name.

- **Purpose**:
   - Sources a utility script given its name. The script must reside in the directory specified by the global variable MY_BIN.
- **Usage**: 
    - source_util_script "script_name"
- **Input Parameters**: 
    1. `script_name` (string) - The name of the utility script to source.
- **Output**: 
    - Sourcing of the utility script. 
- **Exceptions**: 
    - Exits with code 1 if the script is not found in the directory specified by MY_BIN.


## Function: specific_function_help


specific_function_help - Provide detailed documentation for a given function.

- **Purpose**:
  - Display documentation for a specific function.
- **Usage**: 
  - specific_function_help "function_name"
- **Scope**:
  - Global
- **Input Parameters**: 
  1. `function_name` (string) - The name of the function.
- **Output**: 
  - Displays the documentation for the given function.
- **Exceptions**: 
  - Displays general help if the function is unknown.


## Function: vdsc


vdsc - Return the current VENV description.

- **Purose**:
  - Return the current VENV description.
- **Usage**: 
  - vdsc
- **Input Parameters**: 
  - None
- **Output**: 
  - Prints the current VENV description to STDOUT.
  - Prints an error message to STDERR and returns with status code 1 if unsuccessful.
- **Exceptions**:
   1  No value set.


## Function: vnum


vnum - Return the current VENV sequence number.

- **Purose**:
  - Return the current VENV sequence number.
- **Usage**: 
  - vnum
- **Input Parameters**: 
  - None
- **Output**: 
  - Prints the current VENV sequence number to STDOUT.
  - Prints an error message to STDERR and returns with status code 1 if unsuccessful.
- **Exceptions**:
   1  No value set.


## Function: vpfx


vpfx - Return the current VENV prefix.

- **Purose**:
  - Return the current VENV prefix.
- **Usage**: 
  - vpfx
- **Input Parameters**: 
  - None
- **Output**: 
  - Prints the current VENV prefix to STDOUT.
  - Prints an error message to STDERR and returns with status code 1 if unsuccessful.
- **Exceptions**:
   1  No value set.

