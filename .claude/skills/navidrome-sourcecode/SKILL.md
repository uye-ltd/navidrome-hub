---
name: navidrome-sourcecode
description: >
  Navidrome source code assistant for inspecting implementation details in the
  Navidrome project.

  Repository: https://github.com/navidrome/navidrome (master branch).

  Use this skill when answering requires reading Navidrome source code, such as:
  - debugging Navidrome behavior
  - explaining how a feature works internally
  - understanding API endpoints
  - investigating database models or business logic
  - tracing request handling or background jobs
  - implementing custom features or patches

  Do NOT use for installation help or general/basic Navidrome questions.
---

# Navidrome Source Code Skill

Inspect Navidrome source code directly via GitHub API or code search. This avoids fetching HTML blob pages and broken raw URLs.

Repository root: `https://github.com/navidrome/navidrome/tree/master`

## How to use this skill

1. Discover repository structure dynamically using GitHub API:
```WebFetch https://api.github.com/repos/navidrome/navidrome/contents/```

2. Navigate deeper into directories as needed:
```WebFetch https://api.github.com/repos/navidrome/navidrome/contents/<directory>```
Replace <directory> with a subdirectory from the API results, e.g., `server`, `server/api`, `server/model`.

3. Search the repository for relevant keywords if the file location is unknown:
```WebFetch https://api.github.com/search/code?q=scanner+repo:navidrome/navidrome```
Replace scanner with a relevant keyword such as: `playlist`, `cover`, `subsonic`, `auth`, `library`, `transcoding`, etc.

4. Fetch the raw file for inspection only after confirming the path:
```WebFetch https://raw.githubusercontent.com/navidrome/navidrome/master/<path-to-file>```

## Investigation Strategy

When analyzing a feature:
1. Locate relevant code via repository listing or search
2. Fetch the file containing the implementation
3. Trace logic between: handlers, services, models, persistence layer
4. Explain how the implementation works

## Expected Output

When using this skill:
1. Reference specific files
2. Explain how the code works
3. Include function names and relevant logic
4. Provide links to the original files when helpful
