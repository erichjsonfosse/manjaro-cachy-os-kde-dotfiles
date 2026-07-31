gh-cli-get-pr-review-comments() {
  # Check if a PR number was provided
  if [[ -z "$1" ]]; then
    echo "Error: Missing PR number."
    echo "Usage: gh-cli-get-pr-review-comments <PR_ID>"
    return 1
  fi

  local pr_number="$1"

  # Run the GraphQL query
  gh api graphql -F owner=":owner" -F name=":repo" -F pr="$pr_number" -f query='
  query($name: String!, $owner: String!, $pr: Int!) {
    repository(owner: $owner, name: $name) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            isResolved
            path
            comments(first: 1) {
              nodes {
                author { login }
                body
                url
              }
            }
          }
        }
      }
    }
  }' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | "File: \(.path)\n[\(.comments.nodes[0].author.login)] \(.comments.nodes[0].url)\n\(.comments.nodes[0].body)\n"'
}
