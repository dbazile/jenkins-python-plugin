package org.bazile.python;

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
        System.out.println("inside pbw setUp");

        Node node = Computer.currentComputer().getNode();

        PythonInstallation installation = getInstallation()
                .forNode(node, taskListener)
                .forEnvironment(environment);

        String ldLibraryPath = Util.fixNull(installation.getHome()) + "/lib";

        if (environment.containsKey("LD_LIBRARY_PATH")) {
            ldLibraryPath += ":" + environment.get("LD_LIBRARY_PATH");
        }

        context.env("LD_LIBRARY_PATH", ldLibraryPath);
        context.env("XLD_LIBRARY_PATH", ldLibraryPath);
        context.env("XLDX_LIBRARY_PATH", ldLibraryPath);
        context.env("XLDX_LIBRAXRY_PATH", ldLibraryPath);
        context.env("YO_WTFO", "dafuq");
        environment.overrideAll(context.getEnv());

        System.out.printf("\n\n----\nEnvironment:\n%s\n----\n\n", environment.toString());
        System.out.printf("\n\n----\nContext Environment:\n%s\n----\n\n", context.getEnv());

        System.out.println("TODO -- create virtualenv?");
        System.out.println("TODO -- LD_LIBRARY_PATH?");
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
