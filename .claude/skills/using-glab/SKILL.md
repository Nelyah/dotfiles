---
name: using-glab
description: Reference for using the glab CLI to interact with GitLab CI/CD pipelines
  and merge requests. Use when checking pipeline status, viewing job logs, creating
  or reviewing MRs, approving, commenting, or merging.
---
# Using glab CLI

Run `glab` commands via the Bash tool. Omit the MR `<id>` to target the MR for the current branch.

## Merge Requests

### Reading MR state

```bash
glab mr list                                    # List open MRs
glab mr list --draft                            # Only drafts
glab mr list --reviewer=@me                     # Assigned to you for review
glab mr list --label=bug --target-branch=main   # Filter by label and target
glab mr view 123                                # View MR details
glab mr view 123 --comments                     # Include discussion thread
glab mr view 123 --output json                  # JSON output (includes diff_refs SHAs)
glab mr diff 123                                # View code changes
glab mr approvers 123                           # List eligible approvers and approval status
glab mr issues 123                              # Get related issues
```

### Creating and updating MRs

```bash
# Create MR
glab mr create --title "Add feature" \
  --description "Details here" \
  --assignee user1 \
  --reviewer user2 \
  --label feature \
  --target-branch main \
  --draft \
  --remove-source-branch \
  --squash-before-merge

# Create MR from an issue (auto-creates branch)
glab mr for 42 --target-branch main --with-labels

# Update MR metadata
glab mr update 123 --title "New title"
glab mr update 123 --reviewer user1,user2
glab mr update 123 --label add-label --unlabel remove-label
glab mr update 123 --ready                      # Mark draft as ready
```

### Review workflow

```bash
glab mr approve 123                             # Approve MR
glab mr approve 123 --sha <commit-sha>          # Approve specific commit
glab mr revoke 123                              # Revoke your approval
glab mr note 123 --message "Looks good"         # Add comment
glab mr checkout 123                            # Check out MR branch locally
glab mr checkout 123 --branch my-local-branch   # Custom local branch name
```

For **inline diff comments** on specific lines, use the API:

```bash
# First get diff_refs from MR JSON
glab mr view 123 --output json | jq '.diff_refs'

# Then post an inline comment
glab api projects/:id/merge_requests/123/discussions \
  -X POST \
  -f "body=Comment text" \
  -f "position[base_sha]=<base>" \
  -f "position[head_sha]=<head>" \
  -f "position[start_sha]=<start>" \
  -f "position[position_type]=text" \
  -f "position[new_path]=path/to/file.py" \
  -f "position[new_line]=42"
```

### Merging and lifecycle

```bash
glab mr merge 123                               # Merge
glab mr merge 123 --squash                      # Squash merge
glab mr merge 123 --squash --squash-message "feat: message"
glab mr merge 123 --auto-merge                  # Merge when pipeline succeeds
glab mr merge 123 --rebase --remove-source-branch
glab mr rebase 123                              # Rebase source onto target
glab mr close 123                               # Close without merging
glab mr reopen 123                              # Reopen closed MR
```

## CI/CD Pipelines

### Checking pipeline status

```bash
glab ci status                                  # Current branch pipeline
glab ci status --branch feature-x               # Specific branch
glab ci list                                    # List recent pipelines
glab ci list --status failed                    # Filter: running, success, failed, pending
glab ci list --output json                      # JSON output
glab ci get                                     # Get current pipeline as JSON
glab ci get --branch main --with-job-details    # With full job info
glab ci get --pipeline-id 456 --with-variables  # Specific pipeline with variables
```

### Running and managing pipelines

```bash
glab ci run                                     # Trigger pipeline on current branch
glab ci run --branch main                       # Trigger on specific branch
glab ci run --variables KEY1=val1               # With CI variables
glab ci trigger <job-name>                      # Trigger a manual job
glab ci retry <job-name>                        # Retry a failed job
glab ci cancel job <job-name>                   # Cancel a running job
glab ci cancel pipeline                         # Cancel entire pipeline
```

### Debugging failures

```bash
glab ci trace <job-name>                        # View job logs
glab ci trace <job-name> --pipeline-id 456      # Specific pipeline
glab ci artifact <job-name>                     # Download job artifacts
glab ci artifact <job-name> --path ./output     # Download to specific path
```

### CI config validation

```bash
glab ci lint                                    # Validate .gitlab-ci.yml
glab ci lint --include-jobs                     # Also validate expanded jobs
glab ci config compile                          # View fully expanded config (includes resolved)
```

## Common Workflows

### Investigate a failing pipeline

1. `glab ci status` — identify which pipeline is failing
2. `glab ci get --with-job-details` — find the failed job name
3. `glab ci trace <job-name>` — read the failure logs
4. Fix the code, push, then `glab ci status` to verify

### Review and approve an MR

1. `glab mr view 123 --comments` — read description, metadata, and discussion
2. `glab mr diff 123` — review the code changes
3. `glab mr note 123 --message "feedback"` — leave feedback
4. `glab mr approve 123` — approve when satisfied

### Create MR with pipeline check

1. `glab mr create --title "..." --description "..." --draft` — create as draft
2. `glab ci status` — monitor pipeline
3. `glab mr update --ready` — mark ready for review when CI passes

## API Fallback

Use `glab api` for operations without a dedicated subcommand:

```bash
glab api <endpoint>                             # GET request
glab api <endpoint> -X POST -f key=value        # POST with form data
glab api <endpoint> --paginate                  # Auto-paginate results
```
