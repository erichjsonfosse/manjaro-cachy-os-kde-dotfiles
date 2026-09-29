# Antigravity CLI (`agy`) Tool Mapping

Skills speak in generic actions ("dispatch a subagent", "create a todo", "read a file", "run a command", "ask user"). On the Antigravity CLI (`agy`) and Antigravity IDE, these resolve to the native tools below.

## Action-to-Tool Mapping Table

| Action skills request                                | Antigravity CLI equivalent            | Notes                                                                                                                                                               |
|------------------------------------------------------|---------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Dispatch a subagent**                              | `invoke_subagent`                     | Pass `Subagents: [...]`. Built-in `TypeName`: `self` (inherits parent full capabilities, write tools, shell commands) or `research` (read-only tools).              |
| **Subagent communication**                           | `send_message`                        | Send message to running subagent via its `conversationId`. Reactive wakeup: parent automatically resumes on response; no polling loop.                              |
| **Manage subagents**                                 | `manage_subagents`                    | Actions: `list` (inspect active subagents), `kill` / `kill_all`.                                                                                                    |
| **Define custom subagent**                           | `define_subagent`                     | Defines specialized subagents with custom tools and system prompts for the conversation.                                                                            |
| **Task tracking** ("create a todo", "mark complete") | **Task Artifact** via `write_to_file` | Save markdown checklist to artifact directory with `ArtifactMetadata`. Update with `replace_file_content`. **Not** `manage_task`.                                   |
| **Read a file**                                      | `view_file`                           | Slice viewing with `AbsolutePath`, `StartLine`, `EndLine`.                                                                                                          |
| **Edit an existing file**                            | `replace_file_content`                | Single contiguous replacement with `TargetFile`, `Instruction`, `TargetContent`, `ReplacementContent`, `StartLine`, `EndLine`. Repeat calls for non-adjacent edits. |
| **Create a new file**                                | `write_to_file`                       | Writes whole file with `TargetFile`, `CodeContent`, `Description`, `Overwrite`.                                                                                     |
| **Run commands / tests**                             | `run_command`                         | Execute in shell with `CommandLine`, `Cwd`, `WaitMsBeforeAsync`. Never use `cd` across calls; set `Cwd` directly.                                                   |
| **User decision / options menu**                     | `ask_question`                        | Native interactive modal for multi-choice selections. For simple yes/no, output normal text.                                                                        |
| **Background process management**                    | `manage_task`                         | Controls background commands/tasks (`list`, `status`, `kill`, `send_input`).                                                                                        |
| **Timers / Cron schedules**                          | `schedule`                            | Sets one-shot timers or recurring cron triggers. Never run background `sleep`.                                                                                      |

---

## Task Tracking via Artifacts

Antigravity has **no dedicated checklist tool** (`manage_task` manages background shell processes — `list`/`kill`/`status`/`send_input` — it is *not* a todo checklist).

When a skill says to create a todo list, track tasks, or maintain a progress ledger:
1. **Create a Task Artifact** using `write_to_file`:
   - Store the artifact in the conversation artifact directory: `<appDataDir>/brain/<conversation-id>/<task_name>.md`.
   - Provide valid `ArtifactMetadata`:
     ```json
     {
       "TargetFile": "/path/to/artifact/directory/task_checklist.md",
       "Overwrite": true,
       "CodeContent": "# Task List\n\n- [ ] Task 1: Scaffolding\n- [ ] Task 2: Core implementation\n- [ ] Task 3: Tests\n",
       "Description": "Create task progress checklist",
       "ArtifactMetadata": {
         "Summary": "Task checklist tracking implementation progress",
         "UserFacing": true,
         "RequestFeedback": false
       }
     }
     ```
   *(Note: Do not pass `IsArtifact` or `ArtifactMetadata.ArtifactType`, as these are not valid schema properties in Antigravity).*
2. **Update progress as you go** using `replace_file_content`:
   - Replace `- [ ]` with `- [x]` when a task completes.
   - For multiple edits across the checklist, execute sequential calls to `replace_file_content` (there is no `multi_replace_file_content` tool).
3. **Keep it current**: Re-read the artifact before starting subsequent steps as context grows.

---

## Subagent Dispatch and Execution

When skills like `subagent-driven-development` or `dispatching-parallel-agents` instruct you to launch subagents:

### 1. Invocation Syntax
Use `invoke_subagent`:
```json
{
  "Subagents": [
    {
      "TypeName": "self",
      "Role": "Implementer",
      "Prompt": "Detailed task instructions...",
      "Model": "inherit",
      "Workspace": "inherit"
    }
  ]
}
```

### 2. Built-in Agent Types
- **`self`**: Inherits the parent agent's full tool suite (including file writing, bash commands, tests). Use this for implementers, fixers, and reviewers who need to run `git` or verification commands.
- **`research`**: Read-only agent with search and file-reading tools. Does not have file writing or shell execution. Suitable for pure research or non-interactive audits.
- **Custom types**: Can be created dynamically during the session using `define_subagent`.

### 3. Model Tiers
- `"inherit"` (default): Uses the parent session's configured model.
- `"pro"`: For deep reasoning, complex architectural decisions, or whole-branch code reviews.
- `"flash"`: For standard implementations, quick fixes, or intermediate scoped reviews.
- `"flash_lite"`: For lightweight, mechanical tasks.

### 4. Workspace Isolation
- `"inherit"` (default): Shares current workspace directory.
- `"branch"`: Clones/branches an isolated workspace from parent.
- `"share"`: Shares the parent repository's object store (similar to `git worktree`), allowing independent branching without duplicating storage.

### 5. Parallel Dispatch
To dispatch multiple subagents concurrently (as required by `dispatching-parallel-agents`), pass multiple objects in the `Subagents` array of a single `invoke_subagent` call:
```json
{
  "Subagents": [
    { "TypeName": "self", "Role": "Test 1 Fixer", "Prompt": "Fix agent-tool-abort..." },
    { "TypeName": "self", "Role": "Test 2 Fixer", "Prompt": "Fix batch-completion..." }
  ]
}
```

### 6. Reactive Wakeup (No Polling)
In Antigravity, the messaging system automatically wakes up the parent agent whenever a background task or subagent finishes or sends a message.
- **Never poll or sleep in a loop waiting for subagents.**
- After dispatching or messaging a subagent, simply stop calling tools to yield control. You will be notified automatically when output arrives.

---

## Interactive User Queries (`ask_question`)

When a skill requires presenting options or asking a user decision (e.g., in `brainstorming`, `writing-plans`, or `finishing-a-development-branch`):
- **Structured Choices / Approaches / Approvals**: Use `ask_question` with selectable options. On Antigravity CLI (`agy`), this renders an interactive keyboard-driven TUI selector (arrow keys, space to select, enter to submit) directly in the terminal. On Antigravity IDE, it renders an interactive modal dialog.
- **Context-Aware Recommendations**: When one option clearly dominates or is the standard path, prefix it with `(Recommended)` and list it first. When presenting neutral branching options where user intent governs (such as PR vs keep vs merge in `finishing-a-development-branch`), present options neutrally without a forced recommendation.
- **Open-ended Inquiry**: For broad or conversational questions, output standard visible markdown text in the chat.

---

## Workspace Visuals & Documentation

In Antigravity CLI, developers frequently run the CLI inside or alongside their preferred IDE:
- **Specifications & Plans**: Store validated design specs in `documentation/specs/YYYY-MM-DD-HHMM-<topic>-design.md` and implementation plans in `documentation/plans/YYYY-MM-DD-HHMM-<feature>.md`.
- **Architecture & Sequence Diagrams**: Write standard GitHub-flavored Markdown containing Mermaid fenced code blocks (`flowchart`, `sequenceDiagram`, `stateDiagram-v2`, `classDiagram`) directly in the workspace documentation.
- **Clickable File Links**: Always output file links using GitHub-style markdown syntax (`[spec.md](file:///path/to/spec.md)`) so the developer can click to open and preview rendered Markdown and Mermaid diagrams directly in their IDE.
- **Zero Daemon Overhead**: Never launch external HTTP/WebSocket browser daemons; leverage workspace files and IDE previewing.

---

## Skills and Rules Locations in Antigravity

- **Global user skills**: `~/.agents/skills/` (preferred) or `~/.gemini/antigravity-cli/skills/`
- **Project skills**: `.agents/skills/` (in repository root)
- **Plugin discovery**: `~/.agents/plugins/<plugin_name>/` (preferred) or `~/.gemini/config/plugins/<plugin_name>/`
- **Plugin rules**: `<plugin_name>/rules/AGENTS.md` (or `rules/GEMINI.md`)
