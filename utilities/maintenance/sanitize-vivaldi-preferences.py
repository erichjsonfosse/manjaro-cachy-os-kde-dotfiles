#!/usr/bin/env python3
import json
import sys
import os
import argparse

# Keys we absolutely want to strip out of the Preferences file
BLACKLIST_KEYS = {
    'account_info', 'google_services', 'signin', 'tokens', 'sync',
    'window_placement', 'exited_cleanly', 'exit_type', 'session',
    'session_recovery', 'metrics', 'telemetry', 'background_tracing',
    'reporting', 'browser.last_redirect_origin', 'media.device_id_salt',
    'profile_highlight_color', 'client_id', 'last_known_google_url',
    'autofill'
}

def sanitize_node(node, home_dir, placeholder):
    if isinstance(node, dict):
        cleaned = {}
        for key, value in node.items():
            if key in BLACKLIST_KEYS:
                continue
            cleaned[key] = sanitize_node(value, home_dir, placeholder)
        return cleaned
    
    elif isinstance(node, list):
        return [sanitize_node(item, home_dir, placeholder) for item in node]
    
    elif isinstance(node, str):
        # Replace occurrences of absolute home directory with the placeholder
        if home_dir and home_dir in node:
            node = node.replace(home_dir, placeholder)
        return node
        
    return node

def main():
    parser = argparse.ArgumentParser(description="Sanitize a Chromium/Vivaldi Preferences file for sharing in dotfiles.")
    parser.add_argument("-i", "--input", help="Path to raw Preferences file (default: stdin)", default="-")
    parser.add_argument("-o", "--output", help="Path to save sanitized file (default: stdout)", default="-")
    parser.add_argument("-u", "--user-home", help="Absolute path to the home directory to sanitize (default: current user's home)", default=os.path.expanduser("~"))
    parser.add_argument("-p", "--placeholder", help="Placeholder to use for the home directory path (default: __USER_HOME__)", default="__USER_HOME__")
    
    args = parser.parse_args()
    
    # 1. Read Input
    if args.input == "-":
        try:
            data = json.load(sys.stdin)
        except json.JSONDecodeError as e:
            sys.stderr.write(f"Error: Invalid JSON from stdin: {e}\n")
            sys.exit(1)
    else:
        if not os.path.exists(args.input):
            sys.stderr.write(f"Error: Input file '{args.input}' does not exist.\n")
            sys.exit(1)
        try:
            with open(args.input, "r", encoding="utf-8") as f:
                data = json.load(f)
        except Exception as e:
            sys.stderr.write(f"Error reading file '{args.input}': {e}\n")
            sys.exit(1)
            
    # 2. Sanitize Node
    # Normalize home_dir to make sure it doesn't have trailing slash
    home_dir = args.user_home.rstrip("/")
    sanitized_data = sanitize_node(data, home_dir, args.placeholder)
    
    # 3. Write Output
    if args.output == "-":
        json.dump(sanitized_data, sys.stdout, indent=2, sort_keys=True)
        sys.stdout.write("\n")
    else:
        try:
            # Ensure parent directories of output file exist
            parent_dir = os.path.dirname(os.path.abspath(args.output))
            os.makedirs(parent_dir, exist_ok=True)
            with open(args.output, "w", encoding="utf-8") as f:
                json.dump(sanitized_data, f, indent=2, sort_keys=True)
            print(f"✅ Successfully sanitized preferences saved to: {args.output}")
        except Exception as e:
            sys.stderr.write(f"Error writing file '{args.output}': {e}\n")
            sys.exit(1)

if __name__ == "__main__":
    main()
