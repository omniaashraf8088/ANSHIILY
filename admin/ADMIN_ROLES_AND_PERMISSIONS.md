# ANSHIILY Admin Roles & Permissions (RBAC)

The ANSHIILY Admin platform enforces a 5-tier role-based access control system:

| Role | Hierarchy Level | Capabilities & Access Scope |
|---|---|---|
| **SUPER_ADMIN** | Level 5 (Highest) | Full system control. Can invite/remove administrators, change system configurations, delete database records, execute database migrations, view financials and revenue. |
| **ADMIN** | Level 4 | Operations and user management. Can moderate users, adjust credit balances, toggle PRO memberships, inspect storage buckets, and monitor system health. |
| **CONTENT_MANAGER** | Level 3 | Creative asset management. Can create and edit categories, publish new templates, manage default multi-layer JSON layouts, and feature designs. |
| **SUPPORT** | Level 2 | Customer technical support. Can search users, inspect error logs and generation jobs, grant promotional or compensatory generation credits. |
| **ANALYST** | Level 1 | Read-only business intelligence. Can view dashboards, AI generation speed and latency trends, and export aggregated reports without mutation permissions. |

