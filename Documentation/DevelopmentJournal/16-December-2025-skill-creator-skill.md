## Date
16 December 2025

### Project / Branch
sportsbook-ios / single_code

### Goals for this session
- Research Claude Code skills feature
- Create a meta skill that teaches Claude how to create new skills

### Achievements
- [x] Researched Claude Code skills via web search and official documentation
- [x] Learned SKILL.md format, frontmatter requirements, and folder structure
- [x] Created `skill-creator` skill at `~/.claude/skills/skill-creator/SKILL.md`
- [x] Skill includes complete template, workflow, best practices, and anti-patterns

### Issues / Bugs Hit
- None

### Key Decisions
- Placed skill in personal location (`~/.claude/skills/`) rather than project (`.claude/skills/`) per user preference
- Medium complexity level: includes optional enhancements (REFERENCE.md, resources/, scripts) but doesn't go deep into advanced scripting
- No references to existing project skills to keep it generic and reusable

### Experiments & Notes
- Skills are **model-invoked** (Claude decides when to use them based on description) vs slash commands which are **user-invoked**
- Description field is critical - max 200 chars, Claude uses it to decide when to invoke
- Skills are composable - Claude can use multiple skills together automatically
- Storage locations: `~/.claude/skills/` (personal) or `.claude/skills/` (project/team)

### Useful Files / Links
- [skill-creator SKILL.md](~/.claude/skills/skill-creator/SKILL.md)
- [Agent Skills - Claude Blog](https://claude.com/blog/skills)
- [How to Create Custom Skills - Help Center](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills)
- [anthropics/skills GitHub Repository](https://github.com/anthropics/skills)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)

### Next Steps
1. Test the skill by asking Claude to create a new skill
2. Consider adding more example skills to the personal skills folder
3. Potentially create project-specific skills for common iOS workflows
