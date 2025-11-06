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

## Maintenance Notes

- The `.history/` directory contains edit history (VSCode extension)
- `.vscode/settings.json` contains editor theme preferences
- No dependencies or build process - this is documentation only
- Repository uses standard Node.js .gitignore but no actual Node project exists yet
