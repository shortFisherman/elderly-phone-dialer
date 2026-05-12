# Project Notes — phone_call2.0

## Tool Call Limitations

When writing long content (hundreds of lines), tool calls (Write, Edit, Bash) may intermittently fail with `required parameter is missing`. The cause appears to be a serialization bug in the tool call chain, not a hard character limit.

**Workaround:** Break long content into smaller chunks. Write each chunk to a separate file via Write, then concatenate with Bash `cat`. Append to the target file via Edit with short, unique `old_string` → `new_string` replacements.

