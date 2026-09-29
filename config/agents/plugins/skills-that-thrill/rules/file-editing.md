# File Operations & Editing Rules

## General Directives
- **PRESERVE AND MODIFY:** Always update, patch, or edit existing files in place. Never recreate, overwrite, or replace an existing file completely unless explicitly instructed to do so.
- **INCREMENTAL CHANGES:** Use precise diffs, targeted edits, or incremental updates rather than full-file replacements. Keep untouched code, structure, and comments intact.
- **DO NOT DESTROY:** Do not strip out existing imports, types, comments, helper functions, or business logic when modifying a file.

## Safe Refactoring Protocol
1. **Read First:** Read the entire target file to understand context and existing code style before making changes.
2. **Apply Diffs/Patches:** Insert or update only the specific functions, blocks, or variables required by the task.
3. **Verify Integrity:** Ensure all pre-existing code that is not directly related to the modification remains functional and unchanged.

## Explicit Overwrite Exemption
- File recreation is **STRICTLY FORBIDDEN** unless the user prompt includes explicit trigger phrases such as `"overwrite"`, `"rewrite from scratch"`, or `"replace completely"`.
