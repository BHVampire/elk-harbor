# Contributing to ElkHarbor

Thank you for considering contributing to ElkHarbor! Your contributions help make this project better for everyone.

## How to Contribute

There are many ways to contribute to ElkHarbor:

- Reporting bugs and issues
- Suggesting new features or enhancements
- Improving documentation
- Submitting code changes
- Sharing your experience using the project

## Development Process

### Issues

- Before creating a new issue, please check if a similar issue already exists
- Use clear and descriptive titles for issues
- Include as much relevant information as possible
- If reporting a bug, include steps to reproduce, expected behavior, and actual behavior

### Pull Requests

1. Fork the repository
2. Create a new branch for your changes
3. Make your changes following the coding style
4. Add or update tests as appropriate
5. Ensure all tests pass
6. Update documentation to reflect your changes
7. Submit a pull request

### Commit Message Guidelines

Good commit messages make the project history more readable and help with generating changelogs. Please follow these guidelines:

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests when relevant

Example:
```
Add SQL Server monitoring dashboard template

This adds a predefined dashboard for SQL Server monitoring with
panels for key performance metrics and query performance.

Resolves #42
```

## Code Style Guidelines

- For YAML files: Use 2 spaces for indentation
- For Docker, Ansible, and Terraform files: Follow official style guides
- Keep configuration files clean and well-commented

## Documentation

Documentation improvements are always welcome! Here are some guidelines:

- Use clear and simple language
- Add examples whenever possible
- Update README.md when adding significant features
- Add screenshots for UI-related changes or dashboards

## Testing

- For Docker components: Test that containers start and communicate properly
- For Ansible playbooks: Test on fresh Windows instances
- For Terraform configurations: Test plan and apply cycles
- For configuration files: Validate syntax and functionality

## Scope

We welcome contributions that:
- Improve monitoring capabilities
- Enhance automation and deployment tools
- Add support for additional environments
- Improve documentation and examples
- Fix bugs and issues

### Priority Areas for Contribution

We're particularly interested in contributions for:

1. **Industry-Specific Examples**:
   - Pre-configured templates for different industries
   - Custom dashboards tailored to specific business domains
   - Specialized Logstash filters for different transaction types

2. **Integration Examples**:
   - CI/CD pipeline configurations
   - Kubernetes deployment examples with Helm
   - Additional cloud provider configurations beyond Hetzner

3. **Documentation Improvements**:
   - Tutorials for first-time ELK Stack users
   - Migration guides from other monitoring solutions
   - Best practices for specific deployment scenarios

## License

By contributing to ElkHarbor, you agree that your contributions will be licensed under the same MIT License that covers the project.

Thank you for your contributions!