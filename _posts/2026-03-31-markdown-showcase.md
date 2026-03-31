---
title: Markdown Showcase
date: 2026-03-31 12:00:00 -0600
categories: [Homelab, Blog]
tags: [markdown, jekyll, chirpy]
toc: true
---

## Text Formatting

**Bold**, *italic*, ~~strikethrough~~, and `inline code`.

## Code Blocks
```bash
docker ps | grep jekyll
```
```yaml
services:
  jekyll:
    image: ruby:3.3-alpine
    ports:
      - "4000:4000"
```

## Callout Boxes

> **Tip**
> This is a tip box. Great for highlighting important info.
{: .prompt-tip }

> **Warning**
> Watch out for this!
{: .prompt-warning }

> **Danger**
> This will break things.
{: .prompt-danger }

> **Info**
> Just some useful info.
{: .prompt-info }

## Tables

| Service | IP | Port |
|---|---|---|
| Coolify | 192.168.60.33 | 8000 |
| Jekyll | 192.168.60.253 | 4000 |
| TrueNAS | 192.168.60.10 | 80 |

## Task List

- [x] Install Coolify
- [x] Deploy Jekyll
- [x] Set up auto-deploy
- [ ] Write first real post
- [ ] Configure _config.yml

## Images

![Alt text](/path/to/image.jpg){: .shadow }

## Footnotes

This is a sentence with a footnote.[^1]

[^1]: This is the footnote content.