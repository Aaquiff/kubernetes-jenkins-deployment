import jenkins.model.Jenkins;
WorkflowJob job = Jenkins.instance.createProject(WorkflowJob, 'my-pipeline')
