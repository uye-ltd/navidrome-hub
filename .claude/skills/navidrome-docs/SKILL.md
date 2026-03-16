---
name: navidrome-docs
description: >
  Navidrome documentation assistant. Use this skill whenever the user or an agent needs 
  to look up Navidrome configuration options, environment variables, Docker setup instructions, 
  or any other Navidrome docs topic.
  Covers all subpages of https://www.navidrome.org/docs/ including installation,
  configuration, features, library management, integrations, administration, and
  developer docs. 
  
  Trigger on any question about how to configure, deploy, or operate
  Navidrome — even if the user doesn't say "docs" explicitly.
---

# Navidrome Documentation Skill

This skill helps you retrieve and reference Navidrome documentation 

## How to use this skill

1. **For configuration options / environment variables** — use `WebFetch` with URL https://www.navidrome.org/docs/usage/configuration/options/. It contains the full config table (all `ND_*` env vars) and is the most commonly needed reference.

2. **For any other docs page** — use `WebFetch` with URL from https://www.navidrome.org/docs/ and its children. Pages are plain HTML; extract the relevant section and answer from the content.
