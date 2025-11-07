# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Korean-language educational repository for a 3-hour n8n workflow automation seminar. The content is training material designed to teach business users how to implement workflow automation using n8n, covering basics through advanced AI integration.

## Content Structure

The README.md serves as the complete seminar guide with the following sections:

1. **Part 1 (0:00-0:20)**: n8n fundamentals and environment setup
2. **Part 2 (0:20-1:00)**: Basic workflows and Google Sheets integration
3. **Part 3 (1:00-1:40)**: Web scraping and data processing automation
4. **Part 4 (1:40-2:20)**: AI nodes and intelligent automation
5. **Part 5 (2:20-3:00)**: Real-world use cases and Q&A

## Language and Audience

- **Primary Language**: Korean (한국어)
- **Target Audience**: Non-technical business users (기획자, 운영자, etc.)
- **Technical Level**: Beginner to intermediate, no coding background assumed

## Content Guidelines

When editing or adding to this repository:

1. **Maintain Korean Language**: All instructional content should be in Korean to match the target audience
2. **Preserve Structure**: The README follows a strict time-based agenda format - maintain this when adding content
3. **Code Examples**: JavaScript/JSON code snippets should include Korean comments explaining their purpose
4. **Practical Focus**: All examples should be real-world applicable scenarios (sales tracking, customer analysis, inventory management, etc.)

## Workflow Examples

The seminar includes complete n8n workflow implementations for:

- **Google Sheets Integration**: Real-time sales data synchronization with automatic notifications
- **Web Scraping**: Competitor price monitoring with change detection
- **AI Email Processing**: Automated sentiment analysis, categorization, and response generation
- **Business Dashboards**: Multi-source data aggregation with AI-powered insights
- **Smart Inventory**: Demand forecasting and automatic reorder suggestions
- **Marketing Automation**: Lead scoring and personalized nurturing campaigns

## Technical Patterns

Common patterns used throughout the examples:

- **Webhook triggers** for real-time data ingestion
- **Schedule triggers** using cron syntax (e.g., `0 9 * * *` for daily 9am)
- **IF nodes** for conditional branching based on business logic
- **Code nodes** for complex JavaScript data transformations
- **OpenAI nodes** for AI-powered analysis and generation
- **Google Sheets nodes** for data storage and dashboard updates

## Testing Workflow Examples

When creating new examples:

1. Provide curl commands for testing webhooks
2. Include sample input/output JSON structures
3. Show expected results clearly formatted
4. Add error handling for production scenarios

## Practice Module Structure

**NEW (2025-11-07)**: The repository now includes hands-on practice modules with downloadable materials for self-study:

### Module Organization

```
01-basics/          # n8n fundamentals (Hello World, webhooks)
02-google-sheets/   # Sheets integration (sales tracker, customer grading)
03-web-scraping/    # Web scraping (price monitoring, pagination)
04-ai-automation/   # AI integration (sentiment analysis, content generation)
05-use-cases/       # Real-world projects (5 comprehensive business scenarios)
```

Each module contains:
- `README.md` - Step-by-step Korean tutorial
- `data/` - Sample data files for practice
- `scripts/` - Test scripts in 4 languages (Bash, PowerShell, Node.js, Python)
- `workflows/` - n8n workflow JSON files (ready to import)
- `solutions/` - Complete implementation examples
- `advanced/` - Real data collection guides (Gmail API, Google Analytics, etc.)

### Cross-Platform Support

All test scripts are provided in 4 versions to support diverse learners:
- **Bash** (`.sh`) - Linux/macOS users
- **PowerShell** (`.ps1`) - Windows users
- **Node.js** (`.js`) - JavaScript developers
- **Python** (`.py`) - Python developers

Example naming: `test-hello-world.sh`, `test-hello-world.ps1`, `test-hello-world.js`, `test-hello-world.py`

### Advanced Guides

Several modules include `advanced/` folders with production-ready implementations:

- **02-google-sheets/advanced/**: Gmail API integration, Google Analytics data collection
- **03-web-scraping/advanced/**: JavaScript rendering, bot detection bypass, authentication
- **04-ai-automation/advanced/**: Function Calling, multi-step analysis, cost optimization

### File Intelligence System (Module 05)

The most comprehensive project is the File Intelligence System (`05-use-cases/file-intelligence/`):

**Purpose**: Monitor shared folders (Google Drive, OneDrive, NAS) and automatically:
- Summarize new documents with AI
- Detect similar filenames and compare versions
- Notify via multiple channels (Email, Slack, Teams)
- Support GPT-4, Claude, and Gemini models

**Documentation Structure**:
- `README.md` (6,000+ lines) - Complete technical implementation guide
- `OVERVIEW.md` (1,100+ lines) - User-friendly introduction with quick start
- `scripts/similarity-calculator.js` - Standalone filename similarity tool (Levenshtein + Jaccard)
- `scripts/test-file-upload.py` - Google Drive test file uploader

**Key Technical Features**:
- Polling vs Webhook monitoring approaches
- Advanced filename similarity algorithms
- AI prompting techniques (JSON Mode, Few-Shot Learning)
- Multi-model comparison and cost analysis

## Future Improvement Plans

**⚠️ IMPORTANT**: This repository is in active development. Major improvements are planned for 2-3 weeks from 2025-11-07.

### Primary Goal

Make the content **easier and more specific** for beginners. Current structure is complete but needs:

1. **More visual aids** - Screenshots, diagrams, flowcharts (minimum 5 per module)
2. **Clearer error handling** - Common errors with copy-paste solutions
3. **Better onboarding** - "Prerequisites", "What you'll learn", "Success checklist"
4. **Granular steps** - Break down complex processes (especially API setup)
5. **Real data examples** - More realistic Korean business scenarios

### Detailed TODO List

See `TODO.md` in the repository root for the complete checklist. Key priorities:

**High Priority**:
- Add 20+ screenshots to Google Cloud Console setup guide
- Create TROUBLESHOOTING.md (cross-module error solutions)
- Add FAQ.md (pricing, legal concerns, next steps)
- Split file-intelligence/README.md into 7 separate files (currently too long)

**Medium Priority**:
- Add "Expected completion time" to each project
- Create difficulty ratings (⭐~⭐⭐⭐⭐⭐)
- Enhance script comments for absolute beginners
- Add environment check functions to all scripts

**Enhancement Areas by Module**:

1. **01-basics**: Add n8n interface screenshots, execution result examples
2. **02-google-sheets**: Google API setup with 20+ screen captures, credential file placement guide
3. **03-web-scraping**: Browser DevTools tutorial, CSS selector video/GIF
4. **04-ai-automation**: API cost calculator, prompt engineering tips, token optimization
5. **05-use-cases**: Split large files, add learning path flowchart

### Documents to Create

When returning to improve this repository, create these new files:

- `PREREQUISITES.md` - What learners need before starting each module
- `TROUBLESHOOTING.md` - OS-specific issues, network problems, API errors
- `FAQ.md` - Pricing questions, legal concerns, where to learn more
- `GLOSSARY.md` - Korean/English term dictionary for beginners
- `RESOURCES.md` - External learning resources, communities, documentation links

### Working with TODO.md

When continuing work on this repository:

1. **Read TODO.md first** - Contains complete improvement checklist
2. **Focus on user perspective** - Think like someone seeing n8n for the first time
3. **Test error scenarios** - Intentionally break things to document solutions
4. **Update TODO.md** - Check off completed items and add new discoveries

### Key Principle

> "더 쉽게, 더 구체적으로" (Easier and more specific)
>
> Every explanation should be understandable by someone with zero automation experience.
> Every example should be copy-paste executable.
> Every error should have a documented solution.

## Maintenance Notes

- The `.history/` directory contains edit history (VSCode extension)
- `.vscode/settings.json` contains editor theme preferences
- Root now includes `TODO.md` for tracking future improvements
- `PRACTICE.md` (6,600+ lines) provides overall learning roadmap
- Each module is self-contained but follows consistent structure
- Test scripts require respective runtime (bash, PowerShell, node, python)
- Advanced guides may require additional API credentials (Google, OpenAI, Anthropic)
