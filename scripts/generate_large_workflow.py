from jinja2 import Environment, FileSystemLoader


def render_template(template_path, output_path, context):
    # Create a Jinja2 environment with the specified template path
    env = Environment(loader=FileSystemLoader('.'))

    # Load the template
    template = env.get_template(template_path)

    # Render the template with the provided context
    output_content = template.render(context)

    # Write the output to the specified file
    with open(output_path, 'w') as output_file:
        output_file.write(output_content)


if __name__ == "__main__":
    # Specify the template file, output file, and context data
    template_path = 'scripts/large_workflow.yml'
    output_path = '.github/workflows/large-workflow.yml'
    context = {'num_jobs': 1024}

    # Render the template and write to the output file
    render_template(template_path, output_path, context)
