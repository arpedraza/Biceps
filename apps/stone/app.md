# App template

Copy this folder to `/apps/<your-app-name>/`.

- Keep only the environments you need (test/uat/prod)
- Update each environment's `env.bicepparam`
- Add VMs to `inventory.json`

Deletion:
- Removing a VM from `inventory.json` will plan a deletion in what-if.
- Deletions require manual approval in the main pipeline.
