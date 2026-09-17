# CI failure policy

Failures are classified from logs. One rerun on the same exact SHA is allowed only for upstream transient or infrastructure failure. Code defects, test defects, security-boundary failures, and unknown failures are not automatically rerun. Code/test defects are fixed on the same pull-request branch and analysis/tests/security gates are never weakened to obtain green status.
