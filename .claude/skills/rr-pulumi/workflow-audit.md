# Workflow Audit for rr-pulumi

## ✓ Passed

- Development Workflow section exists (line 22)
- Numbered workflow steps present (7 steps)
- Checklists included in key steps:
  - Step 1 "Plan Infrastructure" has 6 planning checkboxes
  - Step 5 "Preview and Deploy" has 6 pre-deployment verification checkboxes
- Plan-Validate-Execute pattern present:
  - Planning: Step 1 (Plan Infrastructure)
  - Implementation: Steps 2-4 (Project Setup, Define Resources, Configuration)
  - Validation: Step 5 (Preview and Deploy), Step 6 (Testing)
  - CI/CD: Step 7 (CI/CD Integration)
- Conditional workflows present in deployment section
- Good reference to external patterns and examples
- Testing section includes automated testing patterns

## ✗ Missing/Needs Improvement

- Step 2 (Project Setup) lacks checklist format
- Step 3 (Define Resources) no validation checklist
- Step 4 (Configuration) missing verification steps
- Step 5 deployment commands lack step-by-step checklist
- Step 6 (Testing) has example code but no workflow checklist
- Step 7 (CI/CD Integration) only has example, no setup checklist
- No explicit rollback procedures
- No failure recovery workflows
- Missing "if preview shows unexpected changes" conditional
- No post-deployment verification checklist
- No state backup workflow

## Recommendations

1. **Add checklist to Step 2 (Project Setup)**:

   ```markdown
   ### 2. Project Setup

   **Create new project:**

   - [ ] Choose appropriate template for cloud provider
   - [ ] Run `pulumi new <template>` to initialize project
   - [ ] Review generated project structure
   - [ ] Initialize git repository for infrastructure code
   - [ ] Create `.gitignore` for Pulumi state files

   **Initialize stacks:**

   - [ ] Create dev stack: `pulumi stack init dev`
   - [ ] Create staging stack: `pulumi stack init staging`
   - [ ] Create prod stack: `pulumi stack init prod`
   - [ ] Set default stack: `pulumi stack select dev`
   - [ ] Verify stack list: `pulumi stack ls`
   ```

2. **Add validation to Step 3 (Define Resources)**:

   ```markdown
   ### Resource Definition Checklist

   - [ ] Resources follow naming conventions
   - [ ] Tags applied consistently (Environment, ManagedBy)
   - [ ] Outputs exported for cross-stack references
   - [ ] Dependencies explicitly defined where needed
   - [ ] Security groups configured with least privilege
   - [ ] Encryption enabled on all storage resources
   - [ ] Type safety verified (no `any` types)
   ```

3. **Add verification to Step 4 (Configuration)**:

   ```markdown
   ### Configuration Validation

   - [ ] All required config values set for stack
   - [ ] Secrets encrypted with `--secret` flag
   - [ ] Configuration values match environment (dev/prod)
   - [ ] Sensitive values not committed to git
   - [ ] Config documented in README or comments
   - [ ] Test config retrieval in code
   ```

4. **Convert Step 5 to detailed workflow**:

   ```markdown
   ### 5. Preview and Deploy

   **Pre-deployment validation:**

   - [ ] Run `pulumi preview` to review changes
   - [ ] Verify resource counts match expectations
   - [ ] Check operations: creates (green), updates (yellow), deletes (red)
   - [ ] Review configuration values are correct
   - [ ] Ensure secrets are encrypted
   - [ ] Verify security group rules and access policies
   - [ ] Confirm correct stack selected (dev/staging/prod)

   **Deployment:**

   - [ ] Review preview output one final time
   - [ ] Run `pulumi up` to deploy
   - [ ] Monitor deployment progress
   - [ ] If errors occur, review error messages and fix
   - [ ] After success, verify outputs: `pulumi stack output`
   - [ ] Monitor logs: `pulumi logs --follow`

   **Post-deployment verification:**

   - [ ] Test deployed resources manually
   - [ ] Verify connectivity and access
   - [ ] Check monitoring/logging is working
   - [ ] Document any manual steps required
   - [ ] Update documentation with outputs
   ```

5. **Add Testing workflow checklist**:

   ```markdown
   ### 6. Testing

   **Test infrastructure deployments:**

   - [ ] Write integration tests using Automation API
   - [ ] Test resource creation with temporary stacks
   - [ ] Verify outputs match expected values
   - [ ] Test destroy and cleanup procedures
   - [ ] Run tests in CI pipeline
   - [ ] Clean up test resources after completion
   ```

6. **Add CI/CD setup checklist**:

   ```markdown
   ### 7. CI/CD Integration

   **GitHub Actions setup:**

   - [ ] Add PULUMI_ACCESS_TOKEN to secrets
   - [ ] Add cloud provider credentials to secrets
   - [ ] Create workflow file in `.github/workflows/`
   - [ ] Configure preview on PR, deploy on merge
   - [ ] Test workflow with sample PR
   - [ ] Add branch protection rules
   - [ ] Document CI/CD process in README
   ```

7. **Add rollback procedures**:

   ```markdown
   ### Rollback Procedures

   **If deployment fails:**

   - Run `pulumi cancel` to stop ongoing operation
   - Review error logs: `pulumi stack output --show-secrets`
   - Fix infrastructure code
   - Run `pulumi preview` again before retry
   - If needed, manually clean up partial resources in cloud console

   **If deployment succeeds but is wrong:**

   - Export current state: `pulumi stack export > backup.json`
   - Revert code changes: `git revert <commit>`
   - Run `pulumi preview` to see rollback changes
   - Run `pulumi up` to apply rollback
   - If that fails, restore state: `pulumi stack import < backup.json`
   ```

8. **Add state management workflow**:

   ```markdown
   ### State Management Best Practices

   - [ ] Backup state before major changes: `pulumi stack export > state-backup.json`
   - [ ] Use Pulumi Cloud or S3 backend for team collaboration
   - [ ] Enable state versioning and encryption
   - [ ] Document state location in README
   - [ ] Never edit state files manually
   - [ ] Use `pulumi refresh` to sync state with cloud
   ```

9. **Add conditional error handling**:
   - "If preview shows unexpected deletes, STOP and investigate"
   - "If deployment fails, review logs before retrying"
   - "If state is corrupted, restore from backup"
   - "If resources already exist, use `pulumi import`"
