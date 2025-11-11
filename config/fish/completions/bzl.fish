# Fish completions for bzl (Bazel wrapper)

# Helper function to get bazel targets
function __fish_bzl_get_targets
    # Get the current token being completed
    set -l token (commandline -ct)

    # Determine workspace root and current package for relative path handling
    set -l current_dir (pwd)
    set -l workspace_root ""
    set -l search_dir $current_dir
    while test "$search_dir" != "/"
        if test -f "$search_dir/WORKSPACE" -o -f "$search_dir/WORKSPACE.bazel" -o -f "$search_dir/MODULE.bazel"
            set workspace_root $search_dir
            break
        end
        set search_dir (dirname $search_dir)
    end

    set -l current_pkg ""
    if test -n "$workspace_root"
        set current_pkg (string replace "$workspace_root/" "" -- $current_dir)
        if test "$current_pkg" = "$workspace_root"
            set current_pkg ""
        end
    end

    # If token starts with //, it's an absolute target
    if string match -qr '^//' -- $token
        # Extract package path and target prefix
        set -l pkg_path (string replace -r ':.*$' '' -- $token)
        set -l target_prefix (string match -r '[^:]*$' -- $token)

        # If there's a colon, complete targets within that package
        if string match -q '*:*' -- $token
            set -l query_result (bzl query "$pkg_path:*" 2>/dev/null)
            if test $status -eq 0
                printf '%s\n' $query_result
            end
        else
            # Complete package paths
            # Try to list all packages starting with this prefix
            set -l dir_path (string replace '//' '' -- $pkg_path)
            if test -z "$dir_path"
                set dir_path "."
            end

            # Find BUILD files and suggest packages
            find "$dir_path" -maxdepth 3 \( -name "BUILD.bazel" -o -name "BUILD" \) 2>/dev/null | while read -l build_file
                set -l package_dir (dirname $build_file)
                # Convert to bazel package format
                if test "$package_dir" = "."
                    echo "//:all"
                else
                    set -l pkg_name (string replace -r '^\./?' '' -- $package_dir)
                    echo "//$pkg_name:"
                    echo "//$pkg_name:all"
                end
            end
        end
    # If token contains colon but no //, it's a relative target
    else if string match -q '*:*' -- $token
        set -l pkg (string replace -r ':.*$' '' -- $token)

        # If pkg is empty (user typed ":target"), use current package
        if test -z "$pkg"
            set pkg $current_pkg
        # pkg is relative to current directory, make it absolute from workspace root
        else if test -n "$current_pkg"
            set pkg "$current_pkg/$pkg"
        end

        # Try to query targets in this package
        set -l query_result (bzl query "//$pkg:*" 2>/dev/null)
        if test $status -eq 0
            # Determine replacement prefix for relative completion
            set -l replacement ""
            if not string match -q ':*' -- $token
                # User typed "path:", keep the path part
                set replacement (string replace -r ':.*$' '' -- $token)
            end

            # Replace package prefix in all results
            for target in $query_result
                echo (string replace -r '^//[^:]*' "$replacement" -- $target)
            end
        end
    # If token looks like a path (contains /), try to complete it (relative to current dir)
    else if string match -q '*/*' -- $token
        # Determine search directory
        set -l search_dir "$token"
        if not test -d "$token"
            set search_dir (dirname "$token")
        end

        # Find BUILD files and suggest packages
        find "$search_dir" -maxdepth 2 \( -name "BUILD.bazel" -o -name "BUILD" \) 2>/dev/null | while read -l build_file
            set -l package_dir (dirname $build_file)
            set -l pkg_name (string replace -r '^\./?' '' -- $package_dir)
            echo "$pkg_name:"
            echo "$pkg_name:all"
        end
    else
        # Complete common target patterns
        echo "//..."
        echo ":all"
        echo "..."
        # Try to find targets in current directory
        if test -f "BUILD.bazel" -o -f "BUILD"
            set -l query_result (bzl query "//$current_pkg:*" 2>/dev/null)
            if test $status -eq 0
                # Show as relative targets ":target"
                for target in $query_result
                    echo (string replace -r '^//[^:]*' '' -- $target)
                end
            end
        end
    end
end

# Helper function to check if current command needs target completion
function __fish_bzl_needs_targets
    set -l cmd (commandline -opc)

    # Check if any of the target-needing commands are in the command line
    for target_cmd in build test run query cquery aquery coverage mobile-install print_action fetch
        if contains -- $target_cmd $cmd
            return 0
        end
    end
    return 1
end

# Main bzl commands (no file completion)
complete -c bzl -f

# Command completions
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "analyze-profile" -d "Analyzes build profile data"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "aquery" -d "Queries the action graph"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "build" -d "Builds the specified targets"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "canonicalize-flags" -d "Canonicalizes bazel options"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "clean" -d "Removes output files"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "coverage" -d "Generates code coverage report"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "cquery" -d "Queries targets with configurations"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "dump" -d "Dumps internal state"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "fetch" -d "Fetches external repositories"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "help" -d "Prints help for commands"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "info" -d "Displays runtime info"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "license" -d "Prints software license"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "mobile-install" -d "Installs targets to mobile devices"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "mod" -d "Queries Bzlmod dependency graph"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "print_action" -d "Prints command line for compiling"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "query" -d "Executes dependency graph query"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "run" -d "Runs the specified target"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "shutdown" -d "Stops the bazel server"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "sync" -d "Syncs workspace repositories"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "test" -d "Builds and runs test targets"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "vendor" -d "Fetches external repos into vendor dir"
complete -c bzl -n "not __fish_seen_subcommand_from analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -a "version" -d "Prints version information"

# Target completions for commands that need them
complete -c bzl -n "__fish_seen_subcommand_from build test run query cquery aquery coverage mobile-install print_action fetch; and __fish_bzl_needs_targets" -a "(__fish_bzl_get_targets)"

# Common flag completions for build, test, run
set -l build_cmds build test run coverage

# Job control
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l jobs -s j -d "Number of parallel jobs"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l keep_going -s k -d "Continue after build errors"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l nokeep_going -d "Stop on first error"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l loading_phase_threads -d "Threads for loading phase"

# Compilation and build options
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l config -d "Use specified bazelrc config"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l compilation_mode -s c -a "fastbuild dbg opt" -d "Compilation mode"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l cpu -d "Target CPU architecture"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l platforms -d "Target platforms"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l check_up_to_date -d "Only check if targets are up-to-date"

# Verbosity and output
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds query cquery aquery" -l curses -a "yes no auto" -d "Use terminal control codes"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds query cquery aquery" -l color -a "yes no auto" -d "Use colored output"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l announce_rc -d "Announce rc options"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noannounce_rc -d "Don't announce rc options"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l show_progress -d "Show progress messages"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noshow_progress -d "Hide progress messages"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l show_timestamps -d "Show timestamps in messages"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noshow_timestamps -d "Hide timestamps"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l progress_in_terminal_title -d "Show progress in terminal title"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noprogress_in_terminal_title -d "Don't show progress in title"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l verbose_failures -d "Show verbose error messages"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noverbose_failures -d "Show brief error messages"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l subcommands -s s -d "Display subcommands during build"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l nosubcommands -d "Don't display subcommands"

# Strategy and execution
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l spawn_strategy -d "Strategy for spawning actions"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l strategy -d "Strategy for specific mnemonics"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l strategy_regexp -d "Strategy by regex filter"

# Sandbox options
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l sandbox_base -d "Sandbox base directory"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l sandbox_tmpfs_path -d "Tmpfs path in sandbox"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l experimental_use_hermetic_linux_sandbox -d "Use hermetic Linux sandbox"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noexperimental_use_hermetic_linux_sandbox -d "Don't use hermetic sandbox"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l sandbox_explicit_pseudoterminal -d "Use explicit pseudoterminal"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l nosandbox_explicit_pseudoterminal -d "No explicit pseudoterminal"

# Worker options
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l worker_max_instances -d "Max instances per worker"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l worker_quit_after_build -d "Quit workers after build"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noworker_quit_after_build -d "Keep workers after build"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l worker_sandboxing -d "Enable worker sandboxing"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noworker_sandboxing -d "Disable worker sandboxing"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l worker_verbose -d "Verbose worker output"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noworker_verbose -d "Brief worker output"

# Test-specific options
complete -c bzl -n "__fish_seen_subcommand_from test coverage" -l test_output -a "summary errors all streamed" -d "Test output mode"
complete -c bzl -n "__fish_seen_subcommand_from test coverage" -l test_filter -d "Filter tests by name"
complete -c bzl -n "__fish_seen_subcommand_from test coverage" -l test_timeout -d "Test timeout"
complete -c bzl -n "__fish_seen_subcommand_from test coverage" -l test_tag_filters -d "Filter tests by tags"
complete -c bzl -n "__fish_seen_subcommand_from test coverage" -l test_size_filters -a "small medium large enormous" -d "Filter tests by size"
complete -c bzl -n "__fish_seen_subcommand_from test coverage" -l runs_per_test -d "Number of times to run each test"
complete -c bzl -n "__fish_seen_subcommand_from test coverage" -l flaky_test_attempts -d "Attempts for flaky tests"
complete -c bzl -n "__fish_seen_subcommand_from test coverage" -l test_arg -d "Additional test arguments"
complete -c bzl -n "__fish_seen_subcommand_from test coverage" -l cache_test_results -d "Cache test results (default)"
complete -c bzl -n "__fish_seen_subcommand_from test coverage" -l nocache_test_results -d "Don't cache test results"
complete -c bzl -n "__fish_seen_subcommand_from test coverage" -l test_keep_going -d "Continue testing after failures"

# Query-specific options
complete -c bzl -n "__fish_seen_subcommand_from query cquery aquery" -l output -a "label label_kind minrank maxrank package location graph xml proto textproto" -d "Output format"
complete -c bzl -n "__fish_seen_subcommand_from query cquery aquery" -l order_output -a "no deps full auto" -d "Order output"
complete -c bzl -n "__fish_seen_subcommand_from query cquery aquery" -l noorder_output -d "Don't order output"
complete -c bzl -n "__fish_seen_subcommand_from query cquery aquery" -l null -d "Use null separator"

# Clean options
complete -c bzl -n "__fish_seen_subcommand_from clean" -l expunge -d "Remove entire output base"
complete -c bzl -n "__fish_seen_subcommand_from clean" -l expunge_async -d "Asynchronous expunge"
complete -c bzl -n "__fish_seen_subcommand_from clean" -l async -d "Async clean"

# Help completions - suggest all commands
complete -c bzl -n "__fish_seen_subcommand_from help" -a "analyze-profile aquery build canonicalize-flags clean coverage cquery dump fetch help info license mobile-install mod print_action query run shutdown sync test vendor version" -d "Command"
complete -c bzl -n "__fish_seen_subcommand_from help" -a "startup_options" -d "JVM startup options"
complete -c bzl -n "__fish_seen_subcommand_from help" -a "target-syntax" -d "Target syntax help"
complete -c bzl -n "__fish_seen_subcommand_from help" -a "info-keys" -d "Info command keys"

# Info keys completions
complete -c bzl -n "__fish_seen_subcommand_from info" -l show_make_env -d "Include make environment"
complete -c bzl -n "__fish_seen_subcommand_from info" -a "bazel-bin bazel-genfiles bazel-testlogs output_base output_path execution_root workspace release server_pid server_log" -d "Info key"

# Dump options
complete -c bzl -n "__fish_seen_subcommand_from dump" -a "skylark memory action_cache" -d "Dump type"

# Remote execution and caching
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_cache -d "Remote cache endpoint"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_executor -d "Remote execution endpoint"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_download_outputs -a "all minimal toplevel" -d "Download outputs mode"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_download_all -d "Download all outputs"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_download_minimal -d "Download minimal outputs"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_download_toplevel -d "Download toplevel outputs"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_accept_cached -d "Accept remote cached results"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noremote_accept_cached -d "Don't accept cached results"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_upload_local_results -d "Upload local results to cache"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noremote_upload_local_results -d "Don't upload local results"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_local_fallback -d "Fall back to local on failure"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noremote_local_fallback -d "No local fallback"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_timeout -d "Remote execution timeout"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_retries -d "Remote execution retries"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_header -d "Remote execution header"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_instance_name -d "Remote instance name"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l remote_cache_compression -d "Enable cache compression"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noremote_cache_compression -d "Disable cache compression"

# Build Event Protocol (BES) options
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l bes_backend -d "Build event service backend"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l bes_results_url -d "Base URL for build results"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l bes_timeout -d "BES upload timeout"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l bes_lifecycle_events -d "Publish lifecycle events"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l nobes_lifecycle_events -d "Don't publish lifecycle"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l build_event_json_file -d "Write build events to JSON"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l build_event_binary_file -d "Write build events to binary"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l build_event_text_file -d "Write build events to text"

# Build flags
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l define -d "Assign value to build variable"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l disk_cache -d "Disk cache directory"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l repository_cache -d "Repository cache directory"

# Workspace flags
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds fetch sync" -l override_repository -d "Override repository location"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds fetch sync" -l distdir -d "Additional directories for downloads"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds fetch sync" -l repo_env -d "Repository environment variable"

# Logging and profiling
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l profile -d "Write JSON profile to file"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l memory_profile -d "Write memory profile to file"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l logging -d "Logging level (0-6)"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l heap_dump_on_oom -d "Dump heap on OOM"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l noheap_dump_on_oom -d "Don't dump heap on OOM"

# Mod command completions
complete -c bzl -n "__fish_seen_subcommand_from mod; and not __fish_seen_subcommand_from graph deps show_repo show_extension" -a "graph" -d "Show dependency graph"
complete -c bzl -n "__fish_seen_subcommand_from mod; and not __fish_seen_subcommand_from graph deps show_repo show_extension" -a "deps" -d "Show dependencies"
complete -c bzl -n "__fish_seen_subcommand_from mod; and not __fish_seen_subcommand_from graph deps show_repo show_extension" -a "show_repo" -d "Show repository details"
complete -c bzl -n "__fish_seen_subcommand_from mod; and not __fish_seen_subcommand_from graph deps show_repo show_extension" -a "show_extension" -d "Show extension details"

# Mod subcommand options
complete -c bzl -n "__fish_seen_subcommand_from mod; and __fish_seen_subcommand_from deps" -l output -a "text graph json" -d "Output format"
complete -c bzl -n "__fish_seen_subcommand_from mod; and __fish_seen_subcommand_from graph" -l output -a "text graph" -d "Output format"

# Global boolean flags (common negation pattern)
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l watchfs -d "Enable filesystem watching"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds" -l nowatchfs -d "Disable filesystem watching"

# Run-specific options
complete -c bzl -n "__fish_seen_subcommand_from run" -l run -d "Execute the target (default)"
complete -c bzl -n "__fish_seen_subcommand_from run" -l norun -d "Build but don't execute"
complete -c bzl -n "__fish_seen_subcommand_from run" -l script_path -d "Write run script to file"

# Fetch/sync options
complete -c bzl -n "__fish_seen_subcommand_from fetch sync vendor" -l repository_disable_download -d "Disable repository downloads"
complete -c bzl -n "__fish_seen_subcommand_from fetch sync vendor" -l norepository_disable_download -d "Enable repository downloads"
complete -c bzl -n "__fish_seen_subcommand_from vendor" -l vendor_dir -d "Vendor directory path"

# Bzlmod options
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds fetch sync" -l enable_bzlmod -d "Enable Bzlmod (default)"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds fetch sync" -l noenable_bzlmod -d "Disable Bzlmod"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds fetch sync" -l enable_workspace -d "Enable WORKSPACE file"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds fetch sync" -l noenable_workspace -d "Disable WORKSPACE file"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds fetch sync" -l lockfile_mode -a "off update refresh error" -d "Lockfile mode"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds fetch sync" -l registry -d "Bzlmod registry URL"
complete -c bzl -n "__fish_seen_subcommand_from $build_cmds fetch sync" -l override_module -d "Override module with path"

# Version and help options (global)
complete -c bzl -l help -d "Show help"
complete -c bzl -l version -d "Show version"
complete -c bzl -l long -s l -d "Show detailed help"
complete -c bzl -l short -d "Show brief help"
