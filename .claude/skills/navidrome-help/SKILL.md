---
name: navidrome-help
description: >
  Navidrome GitHub issues and discussions assistant.

  Use this skill when answering complicated Navidrome questions that may have
  already been discussed by developers or users.

  Sources:
  - https://github.com/navidrome/navidrome/issues
  - https://github.com/navidrome/navidrome/discussions

  Use this skill for:
  - debugging unusual Navidrome behavior
  - configuration problems
  - feature limitations or known issues
  - upgrade or migration problems
  - undocumented behavior
  - implementation discussions by maintainers

  Do NOT use for basic Navidrome questions or installation instructions.
---

# Navidrome GitHub Issues & Discussions Skill

This skill searches Navidrome GitHub Issues and Discussions to find existing answers, workarounds, or maintainer explanations.

## How to use this skill

1. Search Issues via Github API:
```WebFetch https://api.github.com/search/issues?q=scanner+repo:navidrome/navidrome```
Replace scanner with a relevant keyword such as: `playlist`, `transcoding`, `cover`, `auth`, `library`, `scan`, `docker`, etc.

2. Search Discussions via GitHub API:
```WebFetch https://api.github.com/repos/navidrome/navidrome/discussions```
Filter by keywords in JSON results to locate relevant discussions.

3. Fetch individual issue or discussion:
```WebFetch https://api.github.com/repos/navidrome/navidrome/issues/<issue-number>```
```WebFetch https://api.github.com/repos/navidrome/navidrome/discussions/<discussion-id>```

## Investigation strategy

1. Search issues and discussions using relevant keywords
2. Identify threads with maintainer responses or confirmed solutions
3. Read the full thread for context and workarounds

## Expected output

When using this skill:
1. Reference the issue or discussion number
2. Summarize the maintainer or community explanation
3. Include links to the relevant threads
4. Mention workarounds or recommended solutions if present