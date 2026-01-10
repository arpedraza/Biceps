# Contributing to Bicep Infrastructure Solution

Thank you for your interest in contributing to this Bicep infrastructure solution!

## How to Contribute

### Reporting Issues

1. Check if the issue already exists
2. Provide clear description and reproduction steps
3. Include error messages and logs
4. Specify versions (Azure CLI, Bicep, etc.)

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/my-new-feature
   ```

3. **Make your changes**
   - Follow existing code style
   - Add comments and documentation
   - Update README if needed

4. **Test your changes**
   ```bash
   # Validate Bicep templates
   az bicep build --file applications/step/main.bicep
   
   # Test deployment in dev environment
   ./scripts/deployment/deploy.sh -a step -e dev -v
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new module for X"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/my-new-feature
   ```

7. **Submit a pull request**

## Coding Standards

### Bicep Templates

1. **File Organization**
   - One resource type per module
   - Clear parameter definitions
   - Comprehensive outputs

2. **Naming Conventions**
   ```bicep
   // Use descriptive parameter names
   param virtualNetworkName string
   
   // Use clear variable names
   var subnetId = subnet.id
   
   // Use Azure naming conventions
   var vmName = 'vm-${applicationName}-${environment}'
   ```

3. **Documentation**
   ```bicep
   @description('Clear description of parameter')
   param parameterName string
   
   @description('Clear description of output')
   output outputName string = resource.property
   ```

4. **Validation**
   ```bicep
   @allowed([
     'dev'
     'test'
     'uat'
     'prod'
   ])
   param environment string
   
   @minLength(3)
   @maxLength(24)
   param storageAccountName string
   ```

### Parameter Files

1. **Use .bicepparam format** (not JSON)
2. **Include comments** explaining non-obvious settings
3. **Reference files** using `loadTextContent()`
4. **Environment-specific** values only

### Shell Scripts

1. **Use bash** for compatibility
2. **Add error handling**: `set -e`
3. **Include help text**: `-h, --help`
4. **Validate inputs** before processing
5. **Use colors** for output clarity

## Module Development

### Creating a New Module

1. **Create module directory**
   ```bash
   mkdir modules/mynewmodule
   ```

2. **Create module file**
   ```bash
   touch modules/mynewmodule/resource.bicep
   ```

3. **Add module structure**
   ```bicep
   // Module header with description
   // Parameters with validation
   // Resource definition
   // Outputs
   ```

4. **Create README**
   ```bash
   touch modules/mynewmodule/README.md
   ```

5. **Document the module**
   - Purpose and use cases
   - Parameters and their defaults
   - Outputs and their uses
   - Usage examples

### Module Checklist

- [ ] Clear parameter definitions
- [ ] Parameter validation with decorators
- [ ] Comprehensive inline documentation
- [ ] All outputs documented
- [ ] README.md with examples
- [ ] Tested in isolation
- [ ] Tested in application context

## Testing

### Before Submitting

1. **Validate all Bicep templates**
   ```bash
   ./scripts/validation/validate-all.sh
   ```

2. **Test deployment**
   ```bash
   # Test in dev environment
   ./scripts/deployment/deploy.sh -a step -e dev -v
   ```

3. **Test what-if**
   ```bash
   ./scripts/deployment/deploy.sh -a step -e dev -w
   ```

4. **Clean up test resources**
   ```bash
   az group delete --name rg-step-dev-eus --yes
   ```

## Commit Messages

Use conventional commit format:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Examples:
```
feat: add monitoring module for VM diagnostics
fix: correct NSG rule priority in dev environment
docs: update README with deployment instructions
refactor: simplify parameter passing in compute module
```

## Pull Request Process

1. **Update documentation** for any changes
2. **Add tests** if applicable
3. **Validate all templates** before submitting
4. **Link related issues** in PR description
5. **Wait for review** from maintainers
6. **Address feedback** promptly

## Questions or Problems?

- Review existing documentation
- Check closed issues for similar problems
- Open a new issue with details

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
