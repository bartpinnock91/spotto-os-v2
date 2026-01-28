# Jira Workflow

> Last updated: 2026-01-21

Shared workflow across all products.

## Issue Types

### Commonly Used

| Type | Description |
|------|-------------|
| Epic | Large initiative containing multiple issues |
| New Feature | New functionality to be built |
| Improvement | Enhancement to existing functionality |
| Bug | Defect or issue to fix |
| Task | Technical or non-user-facing work |

### Special Types (rare)

| Type | Description |
|------|-------------|
| Project | Project-level tracking |
| Showstopper | Critical blocker requiring immediate attention |
| Security Breach | Security-related incident |

### Not Used

| Type | Notes |
|------|-------|
| Story | Don't use - use New Feature or Improvement instead |
| Sub-task | Don't use |

## Statuses

| Status | Category | Description |
|--------|----------|-------------|
| Functional Analysis | To Do | New issues, requirements being defined |
| Technical Analysis | To Do | Technical design/spike in progress |
| To Do | To Do | Ready but not prioritized |
| Open | To Do | Opened but not started |
| Blocked | To Do | Cannot proceed, waiting on dependency |
| On Hold | To Do | Paused, waiting for external input |
| Test Failed | To Do | QA found issues, needs rework |
| In Progress | In Progress | Actively being worked on |
| Ready for Test | Done | Development complete, awaiting QA |
| QA Testing in Progress | In Progress | QA actively testing |
| Resolved | Done | Verified and completed |
| Closed | Done | Fully completed and closed |
| Declined | Done | Not going to be implemented |

## Transitions

Transitions move issues between statuses. The available transitions depend on the current status.

### From Functional Analysis
| Transition | ID | Target Status |
|------------|-----|---------------|
| Technical Analysis required | 21 | Technical Analysis |
| Request estimation | 171 | Estimation |
| Declined | 231 | Declined |

### From Technical Analysis
| Transition | ID | Target Status |
|------------|-----|---------------|
| Request estimation | 31 | Estimation |
| More info needed | 221 | Functional Analysis |
| Declined | 241 | Declined |

### From In Progress
| Transition | ID | Target Status |
|------------|-----|---------------|
| Finished work | 81 | Ready for Test |
| Can't continue | 71 | Blocked |
| I'm blocked | 291 | Blocked |

### From Blocked
| Transition | ID | Target Status |
|------------|-----|---------------|
| Can continue | 281 | In Progress |

### From Ready for Test
| Transition | ID | Target Status |
|------------|-----|---------------|
| Start testing | 91 | QA Testing in Progress |
| Cannot test | 261 | Blocked |

### From QA Testing in Progress
| Transition | ID | Target Status |
|------------|-----|---------------|
| Test Successful | 101 | Resolved |
| Test Failed | 111 | Test Failed |

### From Test Failed
| Transition | ID | Target Status |
|------------|-----|---------------|
| Restart work | 121 | In Progress |

### From Resolved
| Transition | ID | Target Status |
|------------|-----|---------------|
| Confirmed | 141 | Closed |
| Confirmed | 61 | Closed |

> **Note:** The transition ID varies by issue type. Standard issues use ID 141, while Showstopper issues use ID 61.

## Priorities

| Priority | ID |
|----------|-----|
| Highest | 1 |
| High | 2 |
| Medium | 3 |
| Low | 4 |
| Lowest | 5 |

## Notes

- New stories default to "Functional Analysis" status
- The workflow follows: FA → TA → Estimation → Ready for Dev → In Progress → Ready for Test → QA Testing in Progress → Resolved → Closed
- Issues can be Declined at various stages
- Blocked status can be entered from In Progress when dependencies arise
