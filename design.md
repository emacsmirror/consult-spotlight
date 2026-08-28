# consult-spotlight design

## Overview

`consult-spotlight` connects Consult's asynchronous completion UI to the macOS
`mdfind` command. User input is converted into a command, executed through
Consult's process pipeline, displayed as file candidates, and opened with the
normal Emacs or Embark file actions.

## Modules

- `consult-spotlight.el` contains configuration, command construction, the
  asynchronous Consult integration, preview support, and Embark actions.
- `test/consult-spotlight-test.el` contains the regression test for the boundary
  between the command builder and Consult's asynchronous candidate collection.

## Main functions

### `consult-spotlight`

The interactive entry point. It validates that `mdfind` is available, resolves
the requested search directories, builds a prompt and command builder, asks
Consult for a selection, and opens the selected file.

### `consult-spotlight--builder`

Creates the input-to-command function used by Consult. For each minibuffer
input, it combines configured `mdfind` arguments, directory restrictions, and
the query, and returns the command together with Consult's highlighting
function.

### `consult-spotlight--read`

Turns the command builder into a candidate source with
`consult--process-collection`, then invokes `consult--read` with file preview,
history, and category metadata. The process-collection boundary is essential:
passing the builder directly makes Consult interpret the command and internal
highlighting closure as candidate values.

### `consult-spotlight-open-in-browser`

Converts the selected file to a file URL when necessary and opens it with the
configured default browser. It is registered as an Embark file action when the
corresponding option is enabled.

## Data flow

1. `consult-spotlight` resolves directories and creates a builder.
2. `consult-spotlight--read` wraps the builder in Consult's asynchronous process
   pipeline.
3. `mdfind` output lines become file candidate strings.
4. Consult previews candidates and returns the selected path.
5. Emacs opens the path, or Embark dispatches another file action.
