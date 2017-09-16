package org.bazile.jenkins.python;

import hudson.*;
import hudson.model.*;
import hudson.tasks.BuildWrapperDescriptor;
import jenkins.model.Jenkins;
import jenkins.tasks.SimpleBuildWrapper;
import org.jenkinsci.Symbol;
import org.kohsuke.stapler.DataBoundConstructor;

import java.io.IOException;

public class PythonBuildWrapper extends SimpleBuildWrapper {
    private final String installationName;

    @DataBoundConstructor
    public PythonBuildWrapper(String installationName) {
        this.installationName = installationName;
    }

    public String getInstallationName() {
        return installationName;
    }

    @Override
    public void setUp(Context context, Run<?, ?> run, FilePath filePath, Launcher launcher, TaskListener taskListener, EnvVars environment) throws IOException, InterruptedException {
        Node node = Computer.currentComputer().getNode();

        PythonInstallation installation = getInstallation()
                .forNode(node, taskListener)
                .forEnvironment(environment);

        String pythonHome = Util.fixNull(installation.getHome());

        // HACK -- is there a recommended way to prepend a path?
        context.env("PATH", String.format("%s/bin:%s", pythonHome, environment.get("PATH")));
    }

    private PythonInstallation getInstallation() {
        for (PythonInstallation i : ((DescriptorImpl)getDescriptor()).getInstallations()) {
            if (i.getName().equals(installationName)) {
                return i;
            }
        }
        return null;
    }

    @Symbol("python")
    @Extension
    public static final class DescriptorImpl extends BuildWrapperDescriptor {

        @Override
        public boolean isApplicable(AbstractProject<?, ?> item) {
            return true;
        }

        @Override
        public String getDisplayName() {
            return "Set up Python virtual environment in workspace";
        }

        public PythonInstallation[] getInstallations() {
            return Jenkins
                    .getActiveInstance()
                    .getDescriptorByType(PythonInstallation.DescriptorImpl.class)
                    .getInstallations();
        }
    }
}
