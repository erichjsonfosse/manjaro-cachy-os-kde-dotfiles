#!/usr/bin/env python3
import json
import sys
import os
import argparse

# Keys we absolutely want to strip out of the Preferences file
BLACKLIST_KEYS = {
    'accessibility',
    'account_info',
    'account_store_backup_password_cleaning_last_timestamp',
    'account_tracker_service_last_update',
    'active_days',
    'apps',
    'app_banner',
    'autocomplete',
    'autofill',
    'background_password_check',
    'background_tracing',
    'browser.last_redirect_origin',
    'chained_commands',
    'client_hints',
    'client_id',
    'commerce_daily_metrics_last_update_time',
    'context_dialogs',
    'custom_handlers',
    'daily_metrics',
    'default_apps_install_state',
    'device_id_salt',
    'devtools',
    'dual_layer_user_pref_store',
    'enterprise',
    'enterprise_profile_guid',
    'events',
    'exit_type',
    'exited_cleanly',
    'expiration_time',
    'extensions',
    'fedcm_idp_signin',
    'filtered_service_worker_events',
    'first_install_time',
    'gaia_cookie',
    'gcm',
    'geolocation',
    'google',
    'google_services',
    'high_efficiency',
    'https_upgrade_navigations',
    'ignored_protocol_handlers',
    'in_product_help',
    'keystore_canary',
    'language_model_counters',
    'last_chrome_version',
    'last_known_google_url',
    'last_open_timestamp',
    'last_reporting_timestamp',
    'last_reporting_timestamp_v4',
    'last_update',
    'last_update_time',
    'media',
    'media_engagement',
    'media_router',
    'metrics',
    'notification_interactions',
    'notifications',
    'ntp',
    'oauth_signed_in_origins',
    'password_hash_data_list',
    'password_manager',
    'permission_autoblocking_data',
    'persistent_notifications',
    'pinned_tabs',
    'printing',
    'privacy_sandbox',
    'profile',
    'profile_highlight_color',
    'profile_network_context_service',
    'profile_store_backup_password_cleaning_last_timestamp',
    'protection',
    'protocol_handler',
    'registered_protocol_handlers',
    'reporting',
    'safebrowsing',
    'safety_hub',
    'safe_browsing',
    'saved_tab_groups',
    'schedule_to_flush_to_disk',
    'session',
    'session_recovery',
    'sessions',
    'settings',
    'signin',
    'site_search_settings',
    'size',
    'ssl_cert_decisions',
    'startup',
    'storage_computation_last_update',
    'sync',
    'syncing_theme_prefs_migrated_to_non_syncing',
    'tab_search',
    'telemetry',
    'timestamp',
    'tokens',
    'total_passwords_available_for_account',
    'total_passwords_available_for_profile',
    'translate_accepted_count',
    'translate_denied_count_for_language',
    'translate_recent_target',
    'translate_recent_targets',
    'translate_site_blacklist',
    'updateclientdata',
    'updateclientlastupdatecheckerror',
    'updateclientlastupdatecheckerrorcategory',
    'updateclientlastupdatecheckerrorextracode1',
    'webkit',
    'web_apps',
    'welcome',
    'window_placement',
    'window_placement_popup',
}

def sanitize_node(node, home_dir, placeholder):
    if isinstance(node, dict):
        cleaned = {}
        for key, value in node.items():
            if key in BLACKLIST_KEYS:
                continue
            child_cleaned = sanitize_node(value, home_dir, placeholder)
            # Omit empty dictionary objects
            if isinstance(child_cleaned, dict) and not child_cleaned:
                continue
            cleaned[key] = child_cleaned
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

    # Pre-purge specific configuration blocks
    if 'vivaldi' in data and 'workspaces' in data['vivaldi']:
        del data['vivaldi']['workspaces']

    if 'extensions' in data:
        if 'settings' in data['extensions']:
            for ext_id in list(data['extensions']['settings'].keys()):
                if ext_id != 'ahfgeienlihckogmohjhadlkjgocpleb':
                    del data['extensions']['settings'][ext_id]
        if 'commands' in data['extensions']:
            data['extensions']['commands'] = {}
            
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
